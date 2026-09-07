import 'dart:core' as ffi;
import 'dart:core';
import 'dart:ffi' as ffi;
import 'dart:io' as io;

/// Загрузка native LLM library.
final class LlmLibraryLoader {
  /// Загрузить native library для текущей платформы.
  static ffi.DynamicLibrary load() {
    if (io.Platform.isAndroid) {
      try {
        final lib = ffi.DynamicLibrary.open('libllm_bridge.so');
        // Проверяем, что библиотека содержит нужные функции
        try {
          lib.lookupFunction<
              ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Char>),
              ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Char>)>('llm_init');
        } on ffi.ArgumentError {
          throw Exception(
            'Native library loaded but llm_init function not found. '
            'The library may be compiled in STUB mode. '
            'Check if llama.cpp submodule is initialized: git submodule update --init --recursive',
          );
        }
        return lib;
      } on Exception {
        throw Exception(
          'Native library libllm_bridge.so not found. '
          'Make sure llama.cpp is built and included in APK.',
        );
      }
    }
    if (io.Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    }
    throw UnsupportedError('LLM not supported on this platform');
  }
}
