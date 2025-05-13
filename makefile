build:
	nasm -f bin boot.asm -o boot.img

run: build
	qemu-system-x86_64 -drive format=raw,file=boot.img

clean:
	rm -f boot.img
