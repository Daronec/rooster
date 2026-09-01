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
