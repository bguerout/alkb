.DEFAULT_GOAL := build

include .env
export $(shell sed 's/=.*//' .env)

clean:
	rm -rf build/

prepare:
	bash tasks.sh checkout_linux_repo
	bash tasks.sh configure_package

build: prepare
	bash tasks.sh build

modprobed: prepare
	bash tasks.sh apply_patches modprobed
	bash tasks.sh build

install:
	pacman -U dist/*.tar.zst
