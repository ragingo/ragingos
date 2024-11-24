/**
 * @file main.cpp
 *
 * カーネル本体のプログラムを書いたファイル．
 */

#include <cstdint>
#include <cstddef>
#include <cstdio>

#include <deque>
#include <limits>
#include <numeric>
#include <vector>

#include "frame_buffer_config.hpp"
#include "memory_map.hpp"
#include "ui/graphics.hpp"
#include "mouse.hpp"
#include "font.hpp"
#include "ui/console.hpp"
#include "pci.hpp"
#include "logger.hpp"
#include "drivers/usb/xhci/xhci.hpp"
#include "interrupt.hpp"
#include "asmfunc.h"
#include "segment.hpp"
#include "paging.hpp"
#include "memory_manager.hpp"
#include "ui/window.hpp"
#include "ui/layer.hpp"
#include "message.hpp"
#include "timer.hpp"
#include "drivers/acpi.hpp"
#include "keyboard.hpp"
#include "task.hpp"
#include "terminal.hpp"
#include "fat.hpp"
#include "syscall.hpp"
#include "uefi.hpp"
#include "irqflags.hpp"

__attribute__((format(printf, 1, 2))) int printk(const char* format, ...) {
    va_list ap;
    int result;
    char s[1024];

    va_start(ap, format);
    result = vsprintf(s, format, ap);
    va_end(ap);

    console->PutString(s);
    return result;
}

alignas(16) uint8_t kernel_main_stack[1024 * 1024];

// デスクトップの右下（タスクバーの右端）に現在時刻を表示する
void TaskWallclock(uint64_t task_id, int64_t data) {
    native_irq_disable();
    Task& task = task_manager->CurrentTask();
    auto clock_window = std::make_shared<Window>(
        8 * 10, 16 * 2, screen_config.pixel_format);
    const auto clock_window_layer_id = layer_manager->NewLayer()
                                           .SetWindow(clock_window)
                                           .SetDraggable(false)
                                           .Move(ScreenSize() - clock_window->Size() - Vector2D<int> { 4, 8 })
                                           .ID();
    layer_manager->UpDown(clock_window_layer_id, 2);
    native_irq_enable();

    auto draw_current_time = [&]() {
        EFI_TIME t;
        uefi_rt->GetTime(&t, nullptr);

        FillRectangle(*clock_window->Writer(),
                      { 0, 0 }, clock_window->Size(), { 0, 0, 0 });

        char s[64];
        sprintf(s, "%04d-%02d-%02d", t.Year, t.Month, t.Day);
        WriteString(*clock_window->Writer(), { 0, 0 }, s, { 255, 255, 255 });
        sprintf(s, "%02d:%02d:%02d", t.Hour, t.Minute, t.Second);
        WriteString(*clock_window->Writer(), { 0, 16 }, s, { 255, 255, 255 });

        Message msg { Message::kLayer, task_id };
        msg.arg.layer.layer_id = clock_window_layer_id;
        msg.arg.layer.op = LayerOperation::Draw;

        native_irq_disable();
        task_manager->SendMessage(1, msg);
        native_irq_enable();
    };

    draw_current_time();
    timer_manager->AddTimer(
        Timer { timer_manager->CurrentTick(), 1, task_id });

    while (true) {
        native_irq_disable();
        auto msg = task.ReceiveMessage();
        if (!msg) {
            task.Sleep();
            native_irq_enable();
            continue;
        }
        native_irq_enable();

        if (msg->type == Message::kTimerTimeout) {
            draw_current_time();
            timer_manager->AddTimer(
                Timer { msg->arg.timer.timeout + kTimerFreq, 1, task_id });
        }
    }
}

extern "C" void KernelMainNewStack(
    const FrameBufferConfig& frame_buffer_config_ref,
    const MemoryMap& memory_map_ref,
    const acpi::RSDP& acpi_table,
    void* volume_image,
    EFI_RUNTIME_SERVICES* rt) {
    MemoryMap memory_map { memory_map_ref };
    uefi_rt = rt;

    InitializeGraphics(frame_buffer_config_ref);
    InitializeConsole();

    printk("Welcome to ragingos!\n");
    SetLogLevel(kDebug);

    InitializeSegmentation();
    InitializePaging();
    InitializeMemoryManager(memory_map);
    InitializeTSS();
    InitializeInterrupt();

    fat::Initialize(volume_image);
    InitializeFont();
    InitializePCI();

    InitializeLayer();
    layer_manager->Draw({ { 0, 0 }, ScreenSize() });

    acpi::Initialize(acpi_table);
    InitializeLAPICTimer();

    InitializeSyscall();

    InitializeTask();
    Task& main_task = task_manager->CurrentTask();

    usb::xhci::Initialize();
    InitializeKeyboard();
    InitializeMouse();

    app_loads = new std::map<fat::DirectoryEntry*, AppLoadInfo>;
    task_manager->NewTask()
        .InitContext(TaskTerminal, 0)
        .Wakeup();

    task_manager->NewTask()
        .InitContext(TaskWallclock, 0)
        .Wakeup();

    char str[128];

    while (true) {
        native_irq_disable();
        auto msg = main_task.ReceiveMessage();
        if (!msg) {
            main_task.Sleep();
            native_irq_enable();
            continue;
        }

        native_irq_enable();

        switch (msg->type) {
        case Message::kInterruptXHCI:
            usb::xhci::ProcessEvents();
            break;
        case Message::kTimerTimeout:
            break;
        case Message::kKeyPush:
            if (msg->arg.keyboard.press && msg->arg.keyboard.keycode == 59 /* F2 */) {
                task_manager->NewTask()
                    .InitContext(TaskTerminal, 0)
                    .Wakeup();
            } else {
                auto act = active_layer->GetActive();
                native_irq_disable();
                auto task_it = layer_task_map->find(act);
                native_irq_enable();
                if (task_it != layer_task_map->end()) {
                    native_irq_disable();
                    task_manager->SendMessage(task_it->second, *msg);
                    native_irq_enable();
                } else {
                    printk("key push not handled: keycode %02x, ascii %02x\n",
                           msg->arg.keyboard.keycode,
                           msg->arg.keyboard.ascii);
                }
            }
            break;
        case Message::kLayer:
            ProcessLayerMessage(*msg);
            native_irq_disable();
            task_manager->SendMessage(msg->src_task, Message { Message::kLayerFinish });
            native_irq_enable();
            break;
        default:
            Log(kError, "Unknown message type: %d\n", msg->type);
        }
    }
}

extern "C" void __cxa_pure_virtual() {
    while (1) __asm__("hlt");
}
