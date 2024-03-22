debug ?= 0 #isključiti dodavanjem debug=0 pri make-u, npr. $ make debug=0 run
source_folder ?= ./src/
build_folder ?= ./build/

CFLAGS   = -MMD -D DEBUG=$(debug)
CPPFLAGS = -MMD -D DEBUG=$(debug)
LDFLAGS = -O3
LDLIBS =

SOURCES_C   := $(shell find $(source_folder) -name '*.c') 
SOURCES_CPP := $(shell find $(source_folder) -name '*.cpp') 
OBJECTS := $(SOURCES_C:$(source_folder)%.c=$(build_folder)%.o) $(SOURCES_CPP:$(source_folder)%.cpp=$(build_folder)%.o)
HEADER_DEPENDENCY_RULES := $(OBJECTS:.o=.d)

EXE := main.exe
.DEFAULT_GOAL := $(EXE)
$(EXE): $(OBJECTS)
	@echo "compiling main executable"
	@gcc $(CFLAGS)     -o $@ $(LDFLAGS) $(OBJECTS) $(LDLIBS)
$(build_folder)%.o: $(source_folder)%.c
	@mkdir -p "$$(dirname "$@")"
	gcc $(CFLAGS)   -c -o $@ $<
$(build_folder)%.o: $(source_folder)%.cpp
	@mkdir -p "$$(dirname "$@")"
	g++ $(CPPFLAGS) -c -o $@ $<

$(build_folder)obrada/pobroji/pobroji.o: $(source_folder)obrada/pobroji/pobroji.c
	@echo "compiling specifically $@"
	@mkdir -p "$$(dirname "$@")"
	gcc $(CFLAGS) -c -o $@ $<

.PHONY: clean
clean:
	rm -rf $(build_folder) $(EXE)

-include $(HEADER_DEPENDENCY_RULES)
