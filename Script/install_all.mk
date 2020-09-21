# install_all.mk

build_mk = ../../Script/build.mk

all:
	(cd CoconutData/Project     && make -f $(build_mk))
	(cd CoconutDatabase/Project && make -f $(build_mk))
	(cd CoconutShell/Project    && make -f $(build_mk))
	
