all:
	nasm -f bin boot.asm -o boot.img

run: all
	qemu-system-x86_64 -drive format=raw,file=boot.img

clean:
	rm -f boot.img
