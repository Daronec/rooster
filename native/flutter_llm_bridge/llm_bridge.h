#pragma once

#ifdef __cplusplus
extern "C" {
#endif

// Инициализация модели. Возвращает handle или NULL при ошибке.
// model_path — путь к GGUF файлу модели.
void* llm_init(const char* model_path);

// Генерация ответа.
// prompt — входной текст.
// max_tokens — максимальное количество токенов ответа.
// temperature — креативность (0.0–2.0).
// result —[out] указатель на буфер (вызвать llm_free_result для освобождения).
// Возвращает 0 при успехе, -1 при ошибке.
int llm_generate(void* handle, const char* prompt, int max_tokens,
                 float temperature, char** result);

// Освобождение модели.
void llm_free(void* handle);

// Освобождение результата генерации.
void llm_free_result(char* result);

// Информация о модели.
const char* llm_get_info(void* handle);

#ifdef __cplusplus
}
#endif
