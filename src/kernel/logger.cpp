#include "logger.hpp"

#include <cstddef>
#include <cstdio>

#include "ui/console.hpp"

// LLVM18 コンパイルエラー回避
#define va_start(ap, param) __builtin_va_start(ap, param)
#define va_end(ap) __builtin_va_end(ap)
#define va_arg(ap, type) __builtin_va_arg(ap, type)

namespace {
    LogLevel log_level = kWarn;
}

extern Console* console;

void SetLogLevel(LogLevel level) {
    log_level = level;
}

int Log(LogLevel level, const char* format, ...) {
    if (level > log_level) {
        return 0;
    }

    va_list ap;
    int result;
    char s[1024];

    va_start(ap, format);
    result = vsprintf(s, format, ap);
    va_end(ap);

    console->PutString(s);
    return result;
}
