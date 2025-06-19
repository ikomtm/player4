#include <ebur128.h>
#include <stdio.h>

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

EXPORT double compute_lufs(const char* path) {
    // Здесь реализуйте чтение файла и расчет LUFS через libebur128
    // Верните LUFS (например, -18.5)
    // Для примера — всегда -18.0
    return -23.0;
}