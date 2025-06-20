import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef ComputeLufsNative = Double Function(Pointer<Utf8> path);
typedef ComputeLufs = double Function(Pointer<Utf8> path);

class EbuR128 {
  static late final DynamicLibrary _lib;
  static late final ComputeLufs _computeLufs;

  static void init() {
    if (Platform.isWindows) {
      _lib = DynamicLibrary.open('ebur128.dll');
    } else if (Platform.isMacOS) {
      _lib = DynamicLibrary.open('libebur128.dylib');
    } else if (Platform.isLinux || Platform.isAndroid) {
      _lib = DynamicLibrary.open('libebur128.so');
    } else {
      throw UnsupportedError('Platform not supported');
    }
    _computeLufs = _lib
        .lookup<NativeFunction<ComputeLufsNative>>('compute_lufs')
        .asFunction();
  }

  static double computeLufs(String filePath) {
    final ptr = filePath.toNativeUtf8();
    final lufs = _computeLufs(ptr);
    malloc.free(ptr);
    return lufs;
  }
  Future<double?> computeEbuR128Gain(String filePath) async {
    try {
      // Инициализация библиотеки EBU R128
      EbuR128.init();

      // Вычисление LUFS для указанного файла
      final lufs = EbuR128.computeLufs(filePath);
      if (lufs.isNaN) {
        throw Exception('Failed to compute LUFS for $filePath');
      }

      // Целевой уровень, например -23 LUFS
      const targetLufs = -23.0;
      final gainDb = targetLufs - lufs;
      return gainDb;
    } catch (e) {
      print('EBU R128 error: $e');
      return null;
    }
  }
}