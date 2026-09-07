#include "llm_bridge.h"
#include <cstring>
#include <cstdio>
#include <string>
#include <memory>
#include <vector>
#include <mutex>
#include <android/log.h>

// Include llama.cpp headers
#include <llama.h>

#define LOG_TAG "LLM_BRIDGE"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Структура для хранения состояния LLM
struct LlmContext {
    llama_model* model = nullptr;
    llama_context* ctx = nullptr;
    const llama_vocab* vocab = nullptr;
    bool initialized = false;
    std::string model_info;
    std::string last_error;
    std::mutex generate_mutex;
};

extern "C" {

void* llm_init(const char* model_path) {
    if (!model_path) {
        LOGE("ERROR: model_path is null");
        return nullptr;
    }
    
    LOGI("Loading model from: %s", model_path);
    
    // Check if file exists and has correct magic
    FILE* f = fopen(model_path, "rb");
    if (!f) {
        LOGE("ERROR: Cannot open file: %s", model_path);
        return nullptr;
    }
    
    char magic[4];
    if (fread(magic, 1, 4, f) != 4) {
        LOGE("ERROR: Cannot read file header");
        fclose(f);
        return nullptr;
    }
    fclose(f);
    
    LOGI("File magic: %.4s (expected: GGUF)", magic);
    if (magic[0] != 'G' || magic[1] != 'G' || magic[2] != 'U' || magic[3] != 'F') {
        LOGE("ERROR: Invalid GGUF magic number");
        return nullptr;
    }
    
    auto* context = new LlmContext();
    
    try {
        // Load model
        llama_model_params model_params = llama_model_default_params();
        context->model = llama_model_load_from_file(model_path, model_params);
        
        if (!context->model) {
            LOGE("ERROR: Failed to load model from %s", model_path);
            LOGE("This usually means GGUF format version mismatch.");
            LOGE("Expected: GGUF v2/v3, Got: check model file version");
            delete context;
            return nullptr;
        }
        
        LOGI("Model loaded successfully");
        
        // Get vocab
        context->vocab = llama_model_get_vocab(context->model);
        
        // Create context
        llama_context_params ctx_params = llama_context_default_params();
        ctx_params.n_ctx = 2048;
        ctx_params.n_batch = 512;
        ctx_params.n_threads = 4;
        ctx_params.n_threads_batch = ctx_params.n_threads;
        
        context->ctx = llama_init_from_model(context->model, ctx_params);
        
        if (!context->ctx) {
            fprintf(stderr, "[llm_bridge] ERROR: Failed to create llama context\n");
            llama_model_free(context->model);
            delete context;
            return nullptr;
        }
        
        context->initialized = true;
        
        // Get model info
        int64_t n_params = llama_model_n_params(context->model);
        
        char info_buf[256];
        snprintf(info_buf, sizeof(info_buf), 
                 "Llama - %lld params, n_ctx=%d",
                 (long long)n_params, 
                 llama_n_ctx(context->ctx));
        context->model_info = info_buf;
        
        LOGI("Model info: %s", info_buf);
        LOGI("LLM initialized successfully!");
        
        return static_cast<void*>(context);
        
    } catch (const std::exception& e) {
        LOGE("EXCEPTION during init: %s", e.what());
        if (context->ctx) llama_free(context->ctx);
        if (context->model) llama_model_free(context->model);
        delete context;
        return nullptr;
    }
}

int llm_generate(void* handle, const char* prompt, int max_tokens,
                 float temperature, char** result) {
    if (!handle || !prompt || !result) {
        LOGE("ERROR: Invalid parameters");
        return -1;
    }
    
    auto* context = static_cast<LlmContext*>(handle);
    if (!context || !context->ctx || !context->model || !context->vocab) {
        LOGE("ERROR: Context not initialized");
        return -1;
    }
    
    std::lock_guard<std::mutex> lock(context->generate_mutex);
    
    try {
        LOGI("Generating response... (max_tokens=%d, temp=%.2f)", max_tokens, temperature);
        
        // Tokenize prompt
        int prompt_len = static_cast<int>(strlen(prompt));
        int max_tokens_input = prompt_len + 100;
        std::vector<llama_token> tokens(max_tokens_input);
        int n_tokens = llama_tokenize(context->vocab, prompt, prompt_len, tokens.data(), max_tokens_input, true, true);
        
        if (n_tokens < 0) {
            n_tokens = -n_tokens;
            tokens.resize(n_tokens);
            n_tokens = llama_tokenize(context->vocab, prompt, prompt_len, tokens.data(), n_tokens, true, true);
        }
        
        if (n_tokens <= 0) {
            LOGE("ERROR: Tokenization failed");
            return -1;
        }
        
        LOGI("Tokenized %d tokens", n_tokens);
        
        // Create batch
        llama_batch batch = llama_batch_get_one(tokens.data(), n_tokens);
        
        // Decode
        int result_code = llama_decode(context->ctx, batch);
        if (result_code != 0) {
            LOGE("ERROR: llama_decode failed with %d", result_code);
            return -1;
        }
        
        // Generate tokens
        std::vector<llama_token> generated;
        int n_eval = 0;
        
        for (int i = 0; i < max_tokens && n_eval < n_tokens; i++) {
            // Get logits for last position
            const float* logits = llama_get_logits_ith(context->ctx, n_eval);
            
            int n_vocab = llama_vocab_n_tokens(context->vocab);
            
            // Greedy sampling
            llama_token best_token = -1;
            float max_logit = -1e30f;
            
            for (int j = 0; j < n_vocab; j++) {
                if (logits[j] > max_logit) {
                    max_logit = logits[j];
                    best_token = j;
                }
            }
            
            if (best_token < 0) {
                LOGE("ERROR: Invalid token selected");
                break;
            }
            
            generated.push_back(best_token);
            
            // Prepare next token
            llama_batch batch_next = llama_batch_get_one(&best_token, 1);
            result_code = llama_decode(context->ctx, batch_next);
            if (result_code != 0) {
                LOGE("ERROR: Decode failed at token %d", i);
                break;
            }
            
            n_eval++;
        }
        
        // Decode generated tokens to string
        std::string output;
        for (llama_token token : generated) {
            std::vector<char> buf(128);
            int len = llama_token_to_piece(context->vocab, token, buf.data(), buf.size(), 0, false);
            if (len > 0) {
                output.append(buf.data(), len);
            }
        }
        
        LOGI("Generated: %s", output.c_str());
        
        // Return result
        *result = static_cast<char*>(malloc(output.size() + 1));
        strcpy(*result, output.c_str());
        
        return 0;
        
    } catch (const std::exception& e) {
        LOGE("EXCEPTION during generate: %s", e.what());
        return -1;
    }
}

void llm_free(void* handle) {
    if (handle) {
        auto* context = static_cast<LlmContext*>(handle);
        if (context->ctx) {
            llama_free(context->ctx);
            context->ctx = nullptr;
        }
        if (context->model) {
            llama_model_free(context->model);
            context->model = nullptr;
        }
        context->vocab = nullptr;
        delete context;
    }
}

void llm_free_result(char* result) {
    if (result) {
        free(result);
    }
}

const char* llm_get_info(void* handle) {
    if (!handle) {
        return "No model loaded";
    }
    
    auto* context = static_cast<LlmContext*>(handle);
    return context->model_info.c_str();
}

} // extern "C"
