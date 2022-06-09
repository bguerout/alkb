.DEFAULT_GOAL := default

clean:
	rm -r build/

prepare:
	bash tasks.sh get_kernel_package
	bash tasks.sh configure_package

package:
	cd build/package && makepkg -s

modprobed: prepare
	bash tasks.sh apply_patches modprobed
	$(MAKE) build

default: prepare package
