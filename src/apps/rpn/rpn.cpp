#include <cstring>
#include <cstdlib>

int stack_ptr;
long stack[100];

long Pop() {
    long value = stack[stack_ptr];
    --stack_ptr;
    return value;
}

void Push(long value) {
    ++stack_ptr;
    stack[stack_ptr] = value;
}

extern "C" int main(int argc, char** argv) {
    stack_ptr = -1;

    // nm -C ./build/kernel/kernel.elf | grep printk
    //reinterpret_cast<int (*)(const char*)>(0x0000000000110f50)("hello\n");

    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "+") == 0) {
            long b = Pop();
            long a = Pop();
            Push(a + b);
        } else if (strcmp(argv[i], "-") == 0) {
            long b = Pop();
            long a = Pop();
            Push(a - b);
        } else {
            long a = atol(argv[i]);
            Push(a);
        }
    }
    if (stack_ptr < 0) {
        return 0;
    }
    while (1) {
    }
    //return static_cast<int>(Pop());
}
