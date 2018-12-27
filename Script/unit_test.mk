#
# unit_test.mk
#

build_dir = $(BUILD_DIR)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)
test_exec = $(build_dir)/UnitTest

all:
	$(test_exec) 2>&1 | tee $(build_dir)/UnitTest.log
	diff $(build_dir)/UnitTest.log ../Test/UnitTest/UnitTest.log.OK

