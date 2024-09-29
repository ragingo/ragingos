static inline void native_irq_enable() {
    asm volatile("sti" : : : "memory");
}

static inline void native_irq_disable() {
    asm volatile("cli" : : : "memory");
}
