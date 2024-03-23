debug ?= 0 #isključiti dodavanjem debug=0 pri make-u, npr. $ make debug=0 run
source_folder ?= ./src/
build_folder ?= ./build/
resource_folder ?= ./resources/
verbose_resources ?= 0

CFLAGS   = -MMD -D DEBUG=$(debug)
CPPFLAGS = -MMD -D DEBUG=$(debug)
LDFLAGS = -O3
LDLIBS =

SOURCES_C   := $(shell find $(source_folder) -name '*.c') 
SOURCES_CPP := $(shell find $(source_folder) -name '*.cpp') 
OBJECTS := $(SOURCES_C:$(source_folder)%.c=$(build_folder)bin/%.o) $(SOURCES_CPP:$(source_folder)%.cpp=$(build_folder)bin/%.o)
HEADER_DEPENDENCY_RULES := $(OBJECTS:.o=.d)
RESOURCE_FOLDERS := $(patsubst %/,%,$(addprefix $(build_folder),$(shell find $(resource_folder) -type d)))
RESOURCE_FILES   :=                 $(addprefix $(build_folder),$(shell find $(resource_folder) -type f))

EXE := $(build_folder)main.exe
.DEFAULT_GOAL := $(EXE)
.PHONY: run
run: $(EXE)
	@cd $(build_folder)$(resource_folder) && ../../$(EXE)
$(EXE): $(OBJECTS) | $(RESOURCE_FILES) $(RESOURCE_FOLDERS)
	@echo "compiling main executable"
	@gcc $(CFLAGS)     -o $@ $(LDFLAGS) $(OBJECTS) $(LDLIBS)
$(build_folder)bin/%.o: $(source_folder)%.c
	@mkdir -p "$$(dirname "$@")"
	gcc $(CFLAGS)   -c -o $@ $<
$(build_folder)bin/%.o: $(source_folder)%.cpp
	@mkdir -p "$$(dirname "$@")"
	g++ $(CPPFLAGS) -c -o $@ $<

$(build_folder)bin/obrada/pobroji/pobroji.o: $(source_folder)obrada/pobroji/pobroji.c
	@echo "compiling specifically $@"
	@mkdir -p "$$(dirname "$@")"
	gcc $(CFLAGS) -c -o $@ $<

$(RESOURCE_FILES): | $(RESOURCE_FOLDERS)
$(build_folder)%/*: | $(build_folder)%
$(RESOURCE_FOLDERS):
ifneq ($(verbose_resources),0)
	@echo "create dir  $@"
endif
	@if [ ! -e "$@" ] || [ ! -d "$@" ] ; then mkdir $@ ; fi
# $(build_folder)$(resource_folder): $(resource_folder)
# 	mkdir -p $@
$(build_folder)$(resource_folder)%: $(resource_folder)%
ifneq ($(verbose_resources),0)
	@echo "create file $@ from $^"
endif
	@rm -rf $@
	@cp $^ $@


.PHONY: clean
clean:
	rm -rf $(build_folder)

-include $(HEADER_DEPENDENCY_RULES)
