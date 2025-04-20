ASM=nasm

SRC_DIR=src
BUILD_DIR=build

all: run

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/boot.bin: $(SRC_DIR)/boot.asm
	$(ASM) $(SRC_DIR)/boot.asm -f bin -o $(BUILD_DIR)/boot.bin

$(BUILD_DIR)/main.img: $(BUILD_DIR)/boot.bin
	cp $(BUILD_DIR)/boot.bin $(BUILD_DIR)/boot.img
	truncate -s 1440k $(BUILD_DIR)/boot.img

run: $(BUILD_DIR)/boot.img
	qemu-system-x86_64 -drive format=raw,file=$(BUILD_DIR)/boot.img
