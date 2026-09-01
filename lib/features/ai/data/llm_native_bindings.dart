import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

/// FFI bindings к native LLM library.
final class LlmNativeBindings {
  LlmNativeBindings(ffi.DynamicLibrary library) {
    // Android: libllm_bridge.so
    // iOS: libllm_bridge.dylib
    _llmInit = library
        .lookup<
        ffi.NativeFunction<
            ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Char>)>>(
        'llm_init')
        .asFunction<ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Char>)>();

    _llmGenerate = library
        .lookup<
        ffi.NativeFunction<
            ffi.Int32 Function(
                ffi.Pointer<ffi.Void>,
                ffi.Pointer<ffi.Char>,
                ffi.Int32,
                ffi.Double,
                ffi.Pointer<ffi.Pointer<ffi.Char>>,
                )
        >>('llm_generate')
        .asFunction<int Function(
        ffi.Pointer<ffi.Void>,
        ffi.Pointer<ffi.Char>,
        int,
        double,
        ffi.Pointer<ffi.Pointer<ffi.Char>>,
        )>();

    _llmFree = library
        .lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
        'llm_free')
        .asFunction<void Function(ffi.Pointer<ffi.Void>)>();

    _llmFreeResult = library
        .lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>(
        'llm_free_result')
        .asFunction<void Function(ffi.Pointer<ffi.Char>)>();

    _llmGetInfo = library
        .lookup<
        ffi.NativeFunction<
            ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Void>)>>(
        'llm_get_info')
        .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Void>)>();
  }

  late final ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Char>) _llmInit;
  late final int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Char>,
      int,
      double,
      ffi.Pointer<ffi.Pointer<ffi.Char>>,
      ) _llmGenerate;
  late final void Function(ffi.Pointer<ffi.Void>) _llmFree;
  late final void Function(ffi.Pointer<ffi.Char>) _llmFreeResult;
  late final ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Void>) _llmGetInfo;

  /// Инициализация модели.
  Future<ffi.Pointer<ffi.Void>?> init(String modelPath) async {
    final pointer = modelPath.toNativeUtf8().cast<ffi.Char>();
    try {
      final handle = _llmInit(pointer);
      return handle;
    } finally {
      calloc.free(pointer);
    }
  }

  /// Генерация ответа.
  Future<String?> generate(ffi.Pointer<ffi.Void> handle,
      String prompt, {
        int maxTokens = 256,
        double temperature = 0.7,
      }) async {
    final resultPtr = calloc<ffi.Pointer<ffi.Char>>();
    final promptPointer = prompt.toNativeUtf8().cast<ffi.Char>();
    try {
      final status = _llmGenerate(
        handle,
        promptPointer,
        maxTokens,
        temperature,
        resultPtr,
      );

      if (status != 0 || resultPtr.value == ffi.Pointer.fromAddress(0)) {
        return null;
      }
      final result = _pointerToString(resultPtr.value);
      return result;
    } finally {
      _llmFreeResult(resultPtr.value);
      calloc.free(resultPtr);
      calloc.free(promptPointer);
    }
  }

  /// Получить информацию о модели.
  String getInfo(ffi.Pointer<ffi.Void> handle) {
    final infoPtr = _llmGetInfo(handle);
    return _pointerToString(infoPtr);
  }

  /// Освободить модель.
  void dispose(ffi.Pointer<ffi.Void> handle) {
    _llmFree(handle);
  }

  /// Convert a null-terminated char pointer to Dart String.
  String _pointerToString(ffi.Pointer<ffi.Char> ptr) {
    final bytes = <int>[];
    int i = 0;
    while (ptr[i] != 0) {
      bytes.add(ptr[i]);
      i++;
    }
    return utf8.decode(bytes);
  }
}
