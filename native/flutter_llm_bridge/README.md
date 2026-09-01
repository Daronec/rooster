# Native LLM Bridge

## Описание

Этот каталог содержит C/C++ bridge для интеграции llama.cpp с Flutter через FFI.

## Структура

```
flutter_llm_bridge/
├── llm_bridge.h          # C header для FFI
├── llm_bridge.cpp        # C++ implementation (stub)
├── CMakeLists.txt        # CMake build configuration
└── README.md             # Этот файл
```

## Сборка для Android

### Требования

- Android NDK r26+
- CMake 3.22+
- llama.cpp (опционально, для реальной работы)

### Шаг 1: Клонирование llama.cpp

```bash
cd C:/Work/rooster/native
mkdir llama_cpp
cd llama_cpp
git clone --depth 1 https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
git checkout b3339
```

### Шаг 2: Сборка

После клонирования llama.cpp, просто запустите сборку через Flutter:

```bash
flutter build apk --debug
```

CMake автоматически соберёт `libllm_bridge.so` для arm64-v8a.

### Шаг 3: Проверка

Проверьте, что библиотека собрана:
```
android/app/build/intermediates/cmake/debug/obj/arm64-v8a/libllm_bridge.so
```

## STUB Mode

Если llama.cpp не клонирован, bridge соберётся в STUB mode:
- Модель инициализируется, но использует заглушку вместо реальной LLM
- Подходит для тестирования Flutter кода без native модели
- В логах будет: "STUB MODE"

## Интеграция с Flutter

Bridge экспортирует следующие C-функции:

| Функция | Описание |
|---------|----------|
| `llm_init()` | Инициализация модели из GGUF файла |
| `llm_generate()` | Генерация ответа на prompt |
| `llm_free()` | Освобождение модели |
| `llm_free_result()` | Освобождение результата |
| `llm_get_info()` | Информация о модели |

## Troubleshooting

### Ошибка сборки CMake
- Убедитесь, что NDK установлен: `sdkmanager --list_installed`
- Проверьте путь к NDK в `local.properties`: `ndk.path=/path/to/android-ndk-r26`

### Ошибка "llama.cpp not found"
- Bridge соберётся в STUB mode
- Для реальной LLM: клонируйте llama.cpp как описано выше

### Ошибка native library not found
- Проверьте, что `libllm_bridge.so` есть в APK
- Запустите `flutter clean && flutter build apk`
