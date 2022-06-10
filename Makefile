.DEFAULT_GOAL := default
PACKAGE_NAME := "linux-custom"
PACKAGE_RELEASE_NUMBER := "1.1"

clean:
	rm -r build/

prepare:
	bash tasks.sh get_linux_package
	bash tasks.sh configure_package ${PACKAGE_NAME} ${PACKAGE_RELEASE_NUMBER}

package:
	bash tasks.sh build

modprobed: prepare
	bash tasks.sh apply_patches modprobed
	bash tasks.sh build

default: prepare package
