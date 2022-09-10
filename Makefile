# var
MODULE = $(notdir $(CURDIR))
OS     = $(shell uname -o|tr / _)
NOW    = $(shell date +%d%m%y)
REL    = $(shell git rev-parse --short=4 HEAD)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
PEPS   = E26,E302,E305,E401,E402,E701,E702

# dir
CWD   = $(CURDIR)
TMP   = $(CWD)/tmp

# tool
CURL   = curl -L -o
CF     = clang-format
PY     = python3
PIP    = pip3
PEP    = autopep8

# src
Y  += $(MODULE).py
F  += lib/$(MODULE).ini
S  += $(Y) $(F)
C  += src/ovm.cpp
H  += inc/ovm.hpp
CP += tmp/ovm.parser.cpp tmp/ovm.lexer.cpp
HP += tmp/ovm.parser.hpp

# cfg
CFLAGS += -Iinc -Itmp -O0 -g2

lic: LICENSE
LICENSE:
	wget -c https://github.com/ponyatov/Fx/raw/dev/LICENSE
# all
.PHONY: all
all: $(Y) $(F)
	$(PY) $^

vm: bin/vm $(F)
	$^


# format
.PHONY: format
format: tmp/format_py tmp/format_cpp

tmp/format_py: $(Y)
	$(PEP) --ignore $(PEPS) -i $? && touch $@

tmp/format_cpp: $(C) $(H)
	$(CF) --style=google -i $? && touch $@

# rule
bin/vm: $(C) $(CP) $(H) $(HP)
	$(CXX) $(CFLAGS) -o $@ $(C) $(CP)

tmp/ovm.parser.cpp: src/ovm.yacc
	bison -o $@ $<
tmp/ovm.lexer.cpp: src/ovm.lex
	flex -o $@ $<

# doc
.PHONY: doxy
doxy: doxy.gen
	$(MAKE) doc
	rm -rf docs ; doxygen $< 1>/dev/null

.PHONY: doc
doc:
	rsync -rv ~/mdoc/$(MODULE)/* doc/$(MODULE)/

# install
.PHONY: install update updev
install update:
	sudo apt update
	sudo apt install -yu `cat apt.txt`
	pip3 install --user -U pip autopep8 pytest
	pip3 install --user -U -r requirements.txt

# merge
MERGE  = Makefile README.md doxy.gen $(S)
MERGE += apt.txt requirements.txt
MERGE += .vscode bin doc lib inc src tmp

dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)
	$(MAKE) doxy ; git add docs

shadow:
	git push -v
	git checkout $@
	git pull -v

release:
	git tag $(NOW)-$(REL)
	git push -v --tags
	$(MAKE) shadow

ZIP = tmp/$(MODULE)_$(NOW)_$(REL)_$(BRANCH).zip
zip:
	git archive --format zip --output $(ZIP) HEAD
