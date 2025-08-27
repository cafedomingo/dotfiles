# detect macOS
IS_MACOS := $(shell [ "$$(uname -s)" = "Darwin" ] && echo 1)

SHELL := /bin/bash
DOTFILES_DIR := $(shell pwd)/dotfiles

# auto-discover link targets
LINKS := $(shell find $(DOTFILES_DIR) -maxdepth 1 \( -type f -o -type d \) -not -path "$(DOTFILES_DIR)" | sed 's|^$(DOTFILES_DIR)/||' | sort)

# config files with explicit paths
CONFIG_FILES := \
	sh/_config/starship.toml:.config/starship.toml \
	sh/_config/ssh.config:.ssh/config \
	$(if $(IS_MACOS),sh/_config/hushlogin:.hushlogin)

# directories to manage
DIRECTORIES := \
	bin \
	.config \
	.ssh

# enable dry-run mode with DRY_RUN=1
RUN := $(if $(DRY_RUN),echo "[DRY-RUN]",)

# colors for output
SUCCESS := \033[1;92m
INFO := \033[1;94m
RESET := \033[0m

# default target
.PHONY: all
all: install

# full installation
.PHONY: install
install: cleanup link starship
	@echo -e "$(SUCCESS)⚡️ Installation complete$(RESET)"

# clean broken symlinks
.PHONY: cleanup
cleanup:
	@echo -e "$(INFO)🧹 Cleaning broken symbolic links$(RESET)"
	@$(RUN) find $(HOME) -maxdepth 1 -type l ! -exec test -e {} \; -exec rm -v {} \; 2>/dev/null || true
	@$(foreach dir,$(DIRECTORIES), \
		$(RUN) find $(HOME)/$(dir) -maxdepth 1 -type l ! -exec test -e {} \; -exec rm -v {} \; 2>/dev/null || true;)

# create directories and symbolic links
.PHONY: link
link:
	@echo -e "$(INFO)📂 Creating directories$(RESET)"
	@$(foreach dir,$(DIRECTORIES), \
		$(RUN) mkdir -pv $(HOME)/$(dir);)
	@echo -e "$(INFO)🔗 Creating symbolic links$(RESET)"
	@$(foreach link,$(LINKS), \
		$(RUN) ln -sfhv $(DOTFILES_DIR)/$(link) $(HOME)/.$(link);)
	@$(foreach link,$(CONFIG_FILES), \
		$(eval source := $(word 1,$(subst :, ,$(link)))) \
		$(eval target := $(word 2,$(subst :, ,$(link)))) \
		$(RUN) ln -sfhv $(DOTFILES_DIR)/$(source) $(HOME)/$(target);)

# install starship prompt
.PHONY: starship
starship:
	@echo -e "$(INFO)🚀 Installing starship prompt$(RESET)"
	@cmd="curl -fsSL https://starship.rs/install.sh | sh -s -- --bin-dir=\"$(HOME)/bin\" --yes 2>&1 | sed '/Please follow the steps/,\$$d'"; \
	$(if $(DRY_RUN),echo "[DRY-RUN] $$cmd",sh -c "$$cmd")

# remove all symlinks (follows make convention)
.PHONY: clean
clean:
	@echo -e "$(INFO)🗑️ Removing dotfiles symlinks$(RESET)"
	@$(foreach link,$(LINKS), \
		$(RUN) rm -fv $(HOME)/.$(link);)
	@$(foreach link,$(CONFIG_FILES), \
		$(eval target := $(word 2,$(subst :, ,$(link)))) \
		$(RUN) rm -fv $(HOME)/$(target);)

.PHONY: help
help:
	@echo "Usage:"
	@echo "  make [target] [DRY_RUN=1]"
	@echo ""
	@echo "Targets:"
	@echo "  install    Full installation (default)"
	@echo "  cleanup    Clean broken symlinks"
	@echo "  link       Create directories and symbolic links"
	@echo "  starship   Install starship prompt"
	@echo "  clean      Remove all symlinks"
	@echo "  help       Show this help"
	@echo ""
	@echo "Options:"
	@echo "  DRY_RUN=1  Show what would be done without making changes"
	@echo ""
	@echo "Examples:"
	@echo "  make                 # Full installation"
	@echo "  make DRY_RUN=1       # Dry run of full installation"
