#=========修改修改成自己的项目地址，这个使用的是绝对路径=====
project_dir=/Users/putao/code/test/c/free-rtos-riscv
#=========

RISCV_PROJECT = ${project_dir}/RISC-V_RV32_QEMU_VIRT_GCC
OUTPUT_DIR :=${project_dir}/build
# 创建输出目录
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

IMAGE := RTOSDemo.elf

# The directory that contains the /source and /demo sub directories.
FREERTOS_ROOT = ${project_dir}

CC = riscv64-unknown-elf-gcc
LD = riscv64-unknown-elf-gcc
SIZE = riscv64-unknown-elf-size
MAKE = make

# Generate GCC_VERSION in number format
GCC_VERSION = $(shell $(CC) --version | grep ^$(CC) | sed 's/^.* //g' | awk -F. '{ printf("%d%02d%02d"), $$1, $$2, $$3 }')
GCC_VERSION_NEED_ZICSR = "110100"

CFLAGS += $(INCLUDE_DIRS) -fmessage-length=0 \
          -mabi=ilp32 -mcmodel=medlow -ffunction-sections -fdata-sections \
          -Wno-unused-parameter -nostartfiles -g3 -Os

ifeq ($(shell test $(GCC_VERSION) -ge $(GCC_VERSION_NEED_ZICSR) && echo true),true)
    CFLAGS += -march=rv32imac_zicsr
else
    CFLAGS += -march=rv32imac
endif
          
ifeq ($(PICOLIBC),1)
CFLAGS += --specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF 
else
CFLAGS += --specs=nano.specs -fno-builtin-printf
endif

LDFLAGS += -nostartfiles -Xlinker --gc-sections -Wl,-Map,$(OUTPUT_DIR)/RTOSDemo.map \
           -T${RISCV_PROJECT}/fake_rom.ld -march=rv32imac -mabi=ilp32 -mcmodel=medlow -Xlinker \
           --defsym=__stack_size=350 -Wl,--start-group -Wl,--end-group

ifeq ($(PICOLIBC),1)
LDFLAGS += --specs=picolibc.specs --oslib=semihost --crt0=minimal -DPICOLIBC_INTEGER_PRINTF_SCANF
else
LDFLAGS +=  -Wl,--wrap=malloc \
           -Wl,--wrap=free -Wl,--wrap=open -Wl,--wrap=lseek -Wl,--wrap=read -Wl,--wrap=write \
           -Wl,--wrap=fstat -Wl,--wrap=stat -Wl,--wrap=close -Wl,--wrap=link -Wl,--wrap=unlink \
           -Wl,--wrap=execve -Wl,--wrap=fork -Wl,--wrap=getpid -Wl,--wrap=kill -Wl,--wrap=wait \
           -Wl,--wrap=isatty -Wl,--wrap=times -Wl,--wrap=sbrk -Wl,--wrap=puts -Wl,--wrap=_malloc \
           -Wl,--wrap=_free -Wl,--wrap=_open -Wl,--wrap=_lseek -Wl,--wrap=_read -Wl,--wrap=_write \
           -Wl,--wrap=_fstat -Wl,--wrap=_stat -Wl,--wrap=_close -Wl,--wrap=_link -Wl,--wrap=_unlink \
           -Wl,--wrap=_execve -Wl,--wrap=_fork -Wl,--wrap=_getpid -Wl,--wrap=_kill -Wl,--wrap=_wait \
           -Wl,--wrap=_isatty -Wl,--wrap=_times -Wl,--wrap=_sbrk -Wl,--wrap=__exit -Wl,--wrap=_puts
endif

# -Wl,--wrap=_exit
#
# Kernel build.
#
KERNEL_DIR = $(FREERTOS_ROOT)/kernel
KERNEL_PORT_DIR += $(KERNEL_DIR)/portable/GCC/RISC-V
INCLUDE_DIRS += -I$(FREERTOS_ROOT)/include \
				-I$(KERNEL_PORT_DIR) \
				-I${project_dir}/RISC-V_RV32_QEMU_VIRT_GCC \
				-I$(KERNEL_PORT_DIR)/chip_specific_extensions/RV32I_CLINT_no_extensions
VPATH += $(KERNEL_DIR) $(KERNEL_PORT_DIR) $(KERNEL_DIR)/portable/MemMang
SOURCE_FILES += $(KERNEL_DIR)/tasks.c
SOURCE_FILES += $(KERNEL_DIR)/list.c
SOURCE_FILES += $(KERNEL_DIR)/queue.c
SOURCE_FILES += $(KERNEL_DIR)/timers.c
SOURCE_FILES += $(KERNEL_DIR)/event_groups.c
SOURCE_FILES += $(KERNEL_DIR)/stream_buffer.c
SOURCE_FILES += $(KERNEL_DIR)/portable/MemMang/heap_4.c
SOURCE_FILES += $(KERNEL_DIR)/portable/GCC/RISC-V/port.c
ASM_SOURCE_FILES += $(KERNEL_DIR)/portable/GCC/RISC-V/portASM.S

#
# Common demo files for the "full" build, as opposed to the "blinky" build -
# these files are build by all the FreeRTOS kernel demos.
#
RISCV_DEPENDENCY = ${FREERTOS_ROOT}/Common/Minimal
INCLUDE_DIRS += -I${FREERTOS_ROOT}/Common/include
VPATH += $(RISCV_DEPENDENCY)
SOURCE_FILES += ${RISCV_DEPENDENCY}/AbortDelay.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/BlockQ.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/blocktim.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/countsem.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/death.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/dynamic.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/EventGroupsDemo.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/GenQTest.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/integer.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/IntSemTest.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/MessageBufferAMP.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/MessageBufferDemo.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/PollQ.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/QPeek.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/QueueOverwrite.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/QueueSet.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/QueueSetPolling.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/recmutex.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/semtest.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/StaticAllocation.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/StreamBufferDemo.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/StreamBufferInterrupt.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/TaskNotify.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/TaskNotifyArray.c
SOURCE_FILES += ${RISCV_DEPENDENCY}/TimerDemo.c

#
# Application entry point.  main_blinky is self contained.  main_full builds
# the above common demo (and test) files too.
#

VPATH += ${RISCV_PROJECT}
INCLUDE_DIRS += -I${RISCV_PROJECT}
SOURCE_FILES +=  ${RISCV_PROJECT}/main.c
SOURCE_FILES +=  ${RISCV_PROJECT}/main_blinky.c
SOURCE_FILES +=  ${RISCV_PROJECT}/main_full.c
SOURCE_FILES +=  ${RISCV_PROJECT}/ns16550.c
SOURCE_FILES +=  ${RISCV_PROJECT}/riscv-virt.c
# Lightweight print formatting to use in place of the heavier GCC equivalent.
ifneq ($(PICOLIBC),1)
SOURCE_FILES += ${RISCV_PROJECT}/build/gcc/printf-stdarg.c
endif

#$(info ****************************)
ASM_SOURCE_FILES += ${RISCV_PROJECT}/start.S
ASM_SOURCE_FILES += ${RISCV_PROJECT}/RegTest.S
ASM_SOURCE_FILES += ${RISCV_PROJECT}/vector.S

$(info ********ASM_SOURCE_FILES is: $(ASM_SOURCE_FILES))


#Create a list of object files with the desired output directory path.
OBJS = $(SOURCE_FILES:%.c=%.o) $(ASM_SOURCE_FILES:%.S=%.o)
OBJS_NO_PATH = $(notdir $(OBJS))
OBJS_OUTPUT = $(OBJS_NO_PATH:%.o=$(OUTPUT_DIR)/%.o)

#Create a list of dependency files with the desired output directory path.
DEP_FILES := $(SOURCE_FILES:%.c=$(OUTPUT_DIR)/%.d) $(ASM_SOURCE_FILES:%.S=$(OUTPUT_DIR)/%.d)
DEP_FILES_NO_PATH = $(notdir $(DEP_FILES))
DEP_OUTPUT = $(DEP_FILES_NO_PATH:%.d=$(OUTPUT_DIR)/%.d)

all: $(OUTPUT_DIR) $(OUTPUT_DIR)/$(IMAGE)
run:all
	qemu-system-riscv32 -machine virt -kernel ${OUTPUT_DIR}/RTOSDemo.elf -serial mon:stdio -nographic -bios none
%.o : %.c
$(OUTPUT_DIR)/%.o : %.c $(OUTPUT_DIR)/%.d Makefile
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

%.o : %.S
$(OUTPUT_DIR)/%.o: %.S $(OUTPUT_DIR)/%.d Makefile
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

$(OUTPUT_DIR)/$(IMAGE): $(OBJS_OUTPUT) Makefile
	@echo ""
	@echo ""
	@echo "--- Final linking ---"
	@echo ""
	$(LD) $(OBJS_OUTPUT) $(LDFLAGS) -o $(OUTPUT_DIR)/$(IMAGE)
	$(SIZE) $(OUTPUT_DIR)/$(IMAGE)

$(DEP_OUTPUT):
include $(wildcard $(DEP_OUTPUT))

clean:
	rm -f $(OUTPUT_DIR)/$(IMAGE) $(OUTPUT_DIR)/*.o $(OUTPUT_DIR)/*.d $(OUTPUT_DIR)/*.map

#use "make print-[VARIABLE_NAME] to print the value of a variable generated by
#this makefile.
print-%  : ; @echo $* = $($*)

.PHONY: all clean


