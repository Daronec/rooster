# Внедрение Llama 3.2 (1B/3B) on-device в Rooster

> Полное руководство по добавлению локальной нейросети для решения простых задач прямо в приложении.

---

## Оглавление

1. [Обзор](#1-обзор)
2. [Выбор технологии](#2-выбор-технологии)
3. [Подготовка модели](#3-подготовка-модели)
4. [Android: интеграция через CMake + FFI](#4-android-интеграция-через-cmake--ffi)
5. [iOS: интеграция через Xcode + FFI](#5-ios-интеграция-через-xcode--ffi)
6. [Flutter: FFI binding](#6-flutter-ffi-binding)
7. [Domain: LLM Gateway](#7-domain-llm-gateway)
8. [UI: виджет чата с ИИ](#8-ui-виджет-чата-с-ии)
9. [Тестирование](#9-тестирование)
10. [Критерии приёмки](#10-критерии-приёмки)

---

## 1. Обзор

Llama 3.2 — легковесная модель от Meta, доступная в размерах 1B и 3B параметров. Подходит для:
- Классификации текста
- Извлечения сущностей
- Кратких ответов на вопросы
- Категоризации задач
- Исправления опечаток

### Цели

- Запускать модель **локально** на устройстве (без сервера).
- Минимальное потребление RAM: **~1.5 ГБ** для 1B, **~3 ГБ** для 3B.
- Время ответа: **2–10 секунд** на современных устройствах.
- Поддержка **Android** и **iOS**.

### Архитектурный подход

```
Presentation
  AIChatWidget (виджет чата)
        ↓
Domain
  ILocalLLMGateway (контракт)
        ↓
Data
  LocalLLMGatewayImpl (Dart FFI)
        ↓
Infrastructure
  llama.cpp (C/C++ native library)
```

---

## 2. Выбор технологии

### Сравнение подходов

| Технология | Android | iOS | Размер | Скорость | Сложность |
|------------|---------|-----|--------|----------|-----------|
| **llama.cpp FFI** ✅ | Да | Да | ~600 МБ (1B Q4) | ~5-15 ток/с | Средняя |
| MLC LLM | Да | Да | ~1 ГБ | ~15-30 ток/с | Высокая |
| TensorFlow Lite | Нет (LLM не поддерживает) | Нет | — | — | — |
| ONNX Runtime | Да | Да | ~600 МБ | ~3-8 ток/с | Средняя |
| Cloud API | Да | Да | 0 | Мгновенно | Зависимость от сервера |

**Выбор: llama.cpp через FFI**

Преимущества:
- Прямая поддержка формата GGUF (Llama 3.2).
- Оптимизирован под мобильные CPU.
- Открытый код, активная разработка.
- Один бэкенд для Android и iOS.

---

## 3. Подготовка модели

### Шаг 3.1. Скачивание модели

Формат: **GGUF** (Q4_K_M квантование — баланс размер/качество).

```bash
# 1B модель
huggingface-cli download meta-llama/Llama-3.2-1B-Instruct-GGUF \
  llama-3.2-1b-instruct-q4_k_m.gguf \
  --local-dir ./models

# 3B модель
huggingface-cli download meta-llama/Llama-3.2-3B-Instruct-GGUF \
  llama-3.2-3b-instruct-q4_k_m.gguf \
  --local-dir ./models
```

> Требуется одобрение доступа на [huggingface.co/meta-llama](https://huggingface.co/meta-llama).

### Шаг 3.2. Размеры моделей

| Модель | Формат | Размер | RAM |
|--------|--------|--------|-----|
| Llama 3.2 1B | Q4_K_M | ~0.8 ГБ | ~1.5 ГБ |
| Llama 3.2 1B | Q5_K_M | ~1.0 ГБ | ~2 ГБ |
| Llama 3.2 3B | Q4_K_M | ~2.0 ГБ | ~3 ГБ |
| Llama 3.2 3B | Q8_0 | ~3.5 ГБ | ~5 ГБ |

**Рекомендация**: начать с **1B Q4_K_M**.

### Шаг 3.3. Расположение в проекте

```
rooster/
├── models/
│   ├── llama-3.2-1b-instruct-q4_k_m.gguf  # Модель
│   └── README.md                           # Инструкция по загрузке
├── native/
│   ├── llama_cpp/                          # llama.cpp исходники
│   └── flutter_llm_bridge/                 # FFI bridge
```

---

## 4. Android: интеграция через CMake + FFI

### Шаг 4.1. Клонирование llama.cpp

```bash
cd native/llama_cpp
git clone --depth 1 https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
git checkout b3339  # стабильная версия
```

### Шаг 4.2. Настройка Android NDK

Файл: `android/ndk.config` (или через `local.properties`):

```properties
ndk.path=/path/to/android-ndk-r26
```

### Шаг 4.3. Сборка native библиотеки

Файл: `native/llama_cpp/build_android.sh`

```bash
#!/bin/bash
NDK=$ANDROID_NDK_HOME
API=24

# CPU features
ENABLE_NEON=ON
ENABLE_BLAS=OFF

cmake -B build \
  -DCMAKE_SYSTEM_NAME=Android \
  -DCMAKE_SYSTEM_VERSION=$API \
  -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
  -DCMAKE_ANDROID_NDK=$NDK \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLAMA_NATIVE=OFF \
  -DLLAMA_AVX=OFF \
  -DLLAMA_FMA=OFF \
  -DLLAMA_F16C=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DBUILD_SHARED_LIBS=ON

cmake --build build --config Release -j$(nproc)
```

### Шаг 4.4. Подключение в Gradle

Файл: `android/app/build.gradle.kts`

```kotlin
android {
    // ... существующая конфигурация

    defaultConfig {
        // ...
        externalNativeBuild {
            cmake {
                cppFlags += "-std=c++17"
                arguments += "-DANDROID_STL=c++_shared"
            }
        }
    }

    externalNativeBuild {
        cmake {
            path = file("../native/llama_cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    // Копируем GGUF модель в assets
    aaptOptions {
        noCompress("gguf")
    }
}
```

---

## 5. iOS: интеграция через Xcode + FFI

### Шаг 5.1. Создание Podfile

Файл: `ios/Podfile`

```ruby
platform :ios, '13.0'

use_frameworks!

target 'Runner' do
  pod 'Flutter'
  
  # llama.cpp через C++ framework
  pod 'llama-cpp', :path => '../native/llama_cpp/ios'
end
```

### Шаг 5.2. Настройка Xcode

1. Откройте `ios/Runner.xcworkspace`.
2. В **Build Phases** → **Link Binary With Libraries** добавьте:
   - `libllama.a` (из llama.cpp build)
3. В **Build Settings**:
   - **C++ Language Standard**: `C++17`
   - **C++ Standard Library**: `libc++`

### Шаг 5.3. Копирование модели

1. Добавьте `.gguf` файл в **Target → Runner → Copy Bundle Resources**.

---

## 6. Flutter: FFI binding

### Шаг 6.1. Установка зависимости

Файл: `pubspec.yaml`

```yaml
dependencies:
  # ... существующие
  ffi: ^3.0.0
  path_provider: ^2.1.5
```

### Шаг 6.2. Native FFI header

Файл: `native/flutter_llm_bridge/llm_bridge.h`

```c
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

// Инициализация модели. Возвращает handle или NULL при ошибке.
void* llm_init(const char* model_path);

// Генерация ответа.
// prompt — входной текст.
// max_tokens — максимальное количество токенов ответа.
// temperature — креативность (0.0–2.0).
// result —[out] указатель на буфер (вызвать llm_free_result для освобождения).
int llm_generate(void* handle, const char* prompt, int max_tokens, 
                 float temperature, char** result);

// Загрузка контекста (async).
int llm_load_context(void* handle, const char* context_path);

// Сохранение контекста.
int llm_save_context(void* handle, const char* context_path);

// Освобождение модели.
void llm_free(void* handle);

// Освобождение результата генерации.
void llm_free_result(char* result);

// Информация о модели.
const char* llm_get_info(void* handle);

#ifdef __cplusplus
}
#endif
```

### Шаг 6.3. Dart FFI binding

Файл: `lib/features/ai/data/llm_native_bindings.dart`

```dart
import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'package:ffi/ffi.dart';

/// FFI bindings к native LLM library.
final class LlmNativeBindings {
  LlmNativeBindings(ffi.DynamicLibrary library) {
    // Android: libllm_bridge.so
    // iOS: libllm_bridge.dylib
    _llmInit = library
        .lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>>('llm_init')
        .asFunction<ffi.Pointer<ffi.Char> Function(String)>();
    
    _llmGenerate = library
        .lookup<
            ffi.NativeFunction<
                ffi.Int32 Function(
                    ffi.Pointer<ffi.Void>,
                    ffi.Pointer<ffi.Char>,
                    ffi.Int32,
                    ffi.Float,
                    ffi.Pointer<ffi.Pointer<ffi.Char>>,
                )
            >>('llm_generate')
        .asFunction<int Function(
          ffi.Pointer<ffi.Void>,
          String,
          int,
          double,
          ffi.Pointer<ffi.Pointer<ffi.Char>>,
        )>();

    _llmFree = library
        .lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>('llm_free')
        .asFunction<void Function(ffi.Pointer<ffi.Void>)>();

    _llmFreeResult = library
        .lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>('llm_free_result')
        .asFunction<void Function(ffi.Pointer<ffi.Char>)>();

    _llmGetInfo = library
        .lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Void>)>>('llm_get_info')
        .asFunction<String Function(ffi.Pointer<ffi.Void>)>();
  }

  late final ffi.Pointer<ffi.Char> Function(String) _llmInit;
  late final int Function(
    ffi.Pointer<ffi.Void>,
    String,
    int,
    double,
    ffi.Pointer<ffi.Pointer<ffi.Char>>,
  ) _llmGenerate;
  late final void Function(ffi.Pointer<ffi.Void>) _llmFree;
  late final void Function(ffi.Pointer<ffi.Char>) _llmFreeResult;
  late final String Function(ffi.Pointer<ffi.Void>) _llmGetInfo;

  /// Инициализация модели.
  Future<ffi.Pointer<ffi.Void>?> init(String modelPath) async {
    final handle = _llmInit(modelPath.toNativeUtf8().cast());
    // Освобождаем temporary string
    final calloc = ffi.Calloc();
    calloc.free(modelPath.toNativeUtf8());
    return handle.cast<ffi.Void>();
  }

  /// Генерация ответа.
  Future<String?> generate(
    ffi.Pointer<ffi.Void> handle,
    String prompt, {
    int maxTokens = 256,
    double temperature = 0.7,
  }) async {
    ffi.Pointer<ffi.Char>? resultPtr;
    final status = _llmGenerate(handle, prompt.toNativeUtf8().cast(), maxTokens, temperature, resultPtr);
    if (status != 0 || resultPtr == nullptr) {
      return null;
    }
    final result = resultPtr.cast<ffi.Utf8>().toDartString();
    _llmFreeResult(resultPtr);
    return result;
  }

  /// Получить информацию о модели.
  String getInfo(ffi.Pointer<ffi.Void> handle) {
    return _llmGetInfo(handle);
  }

  /// Освободить модель.
  void dispose(ffi.Pointer<ffi.Void> handle) {
    _llmFree(handle);
  }
}
```

### Шаг 6.4. Загрузка native library

Файл: `lib/features/ai/data/llm_library_loader.dart`

```dart
import 'dart:ffi' as ffi;
import 'dart:io' as io;

/// Загрузка native LLM library.
final class LlmLibraryLoader {
  /// Загрузить native library для текущей платформы.
  static ffi.DynamicLibrary load() {
    if (io.Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libllm_bridge.so');
    }
    if (io.Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    }
    throw UnsupportedError('LLM not supported on this platform');
  }
}
```

---

## 7. Domain: LLM Gateway

### Шаг 7.1. Контракт

Файл: `lib/features/ai/domain/gateways/i_local_llm_gateway.dart`

```dart
/// Контракт для локальной LLM-модели.
abstract interface class ILocalLLMGateway {
  /// Инициализировать модель из файла.
  Future<void> initialize(String modelPath);

  /// Сгенерировать ответ на prompt.
  Future<String?> generate({
    required String prompt,
    int maxTokens,
    double temperature,
  });

  /// Проверить, инициализирована ли модель.
  bool get isInitialized;

  /// Информация о модели.
  String? get modelInfo;

  /// Освободить ресурсы.
  void dispose();
}
```

### Шаг 7.2. Реализация

Файл: `lib/features/ai/data/local_llm_gateway_impl.dart`

```dart
import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:rooster/features/ai/data/llm_native_bindings.dart';
import 'package:rooster/features/ai/data/llm_library_loader.dart';
import 'package:rooster/features/ai/domain/gateways/i_local_llm_gateway.dart';

/// Реализация LLM через llama.cpp FFI.
final class LocalLLMGatewayImpl implements ILocalLLMGateway {
  LlmNativeBindings? _bindings;
  ffi.Pointer<ffi.Void>? _handle;
  String? _modelInfo;

  @override
  bool get isInitialized => _handle != null && _handle!.address != 0;

  @override
  String? get modelInfo => _modelInfo;

  @override
  Future<void> initialize(String modelPath) async {
    final bindings = LlmNativeBindings(LlmLibraryLoader.load());
    final handle = await bindings.init(modelPath);
    if (handle == null || handle.address == 0) {
      throw Exception('Failed to load LLM model from $modelPath');
    }
    _bindings = bindings;
    _handle = handle;
    _modelInfo = bindings.getInfo(handle!);
  }

  @override
  Future<String?> generate({
    required String prompt,
    int maxTokens = 256,
    double temperature = 0.7,
  }) async {
    if (!isInitialized) {
      throw StateError('LLM not initialized');
    }
    return _bindings!.generate(
      _handle!,
      prompt,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }

  @override
  void dispose() {
    if (_handle != null && _handle!.address != 0) {
      _bindings!.dispose(_handle!);
      _handle = null;
      _bindings = null;
    }
  }
}
```

### Шаг 7.3. DI в AppScope

Файл: `lib/features/app/di/app_scope.dart` (добавить)

```dart
/// Локальная LLM-модель (опционально).
ILocalLLMGateway? get localLLMGateway;
```

---

## 8. UI: виджет чата с ИИ

### Шаг 8.1. Виджет AI Assistant

Файл: `lib/features/ai/presentation/screens/ai_chat/ai_chat_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/ai/domain/gateways/i_local_llm_gateway.dart';

/// Экран AI-ассистента.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Ассистент')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, i) => _MessageBubble(_messages.reversed.toList()[i]),
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Введите запрос...'),
            ),
          ),
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.send),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _messages.add(_Message(role: 'user', text: text));
    _controller.clear();
    setState(() => _isLoading = true);

    try {
      final llm = context.read<IAppScope>().localLLMGateway;
      if (llm == null) {
        _messages.add(_Message(role: 'assistant', text: 'LLM не доступна.'));
      } else {
        final prompt = _buildPrompt(text);
        final response = await llm.generate(prompt: prompt);
        _messages.add(_Message(role: 'assistant', text: response ?? 'Ошибка'));
      }
    } on Exception catch (e) {
      _messages.add(_Message(role: 'assistant', text: 'Ошибка: $e'));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _buildPrompt(String userText) {
    return '''Ты — полезный ассистент для управления задачами.
Ответь кратко и по делу.

Пользователь: $userText
Твой ответ:''';
  }
}

class _Message {
  _Message({required this.role, required this.text});
  final String role;
  final String text;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble(this.message);
  final _Message message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(message.text),
        ),
      ),
    );
  }
}
```

---

## 9. Тестирование

### Шаг 9.1. Unit-тесты

Файл: `test/features/ai/local_llm_gateway_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/ai/domain/gateways/i_local_llm_gateway.dart';

void main() {
  group('LocalLLMGatewayImpl', () {
    test('isInitialized returns false before init', () {
      // Нужно мокавать FFI
    });

    test('throws on generate before init', () async {
      // Тест
    });

    test('dispose frees resources', () async {
      // Тест
    });
  });
}
```

### Шаг 9.2. Сценарии тестирования

| Сценарий | Ожидаемый результат |
|----------|---------------------|
| Загрузка модели 1B Q4 | Успешная инициализация, ~1.5 ГБ RAM |
| Генерация простого запроса | Ответ за 2–10 сек |
| Модель не найдена | Исключение с понятным сообщением |
| Запуск на устройстве < 4 ГБ RAM | Предупреждение или отказ в загрузке |
| Модель 3B на устройстве 8 ГБ | Успешная работа |

---

## 10. Критерии приёмки

- [ ] llama.cpp собран для Android (arm64-v8a) и iOS.
- [ ] Модель Llama 3.2 1B Q4_K_M загружается и работает.
- [ ] Генерация ответа на текстовый запрос работает.
- [ ] UI виджет чата отображает диалог.
- [ ] Память не утекает при repeated generate.
- [ ] На Android 12+ работает без crash.
- [ ] На iOS 15+ работает без crash.
- [ ] Модель загружается из assets или cache-директории.
- [ ] Документация по обновлению модели актуальна.

---

## Альтернативы

Если llama.cpp не подходит:

| Альтернатива | Когда использовать |
|--------------|-------------------|
| **MLC LLM** | Нужна GPU-акселерация (Adreno Metal/Vulkan) |
| **ONNX Runtime Mobile** | Модель уже в ONNX формате |
| **Cloud API** | Требуется качество GPT-4, есть сервер |
| **Gemini Nano** | Только Android (TensorFlow Lite Model Maker) |

---

## Ссылки

- [llama.cpp GitHub](https://github.com/ggerganov/llama.cpp)
- [Llama 3.2 на HuggingFace](https://huggingface.co/meta-llama/Llama-3.2-1B-Instruct-GGUF)
- [Flutter FFI Guide](https://docs.flutter.dev/platform-integration/android/ffi-library)
- [GGUF Format](https://github.com/ggerganov/ggml/blob/master/docs/gguf.md)
- [Quantization Guide](https://blog.llamafactory.com/blog/quantization-guide/)
