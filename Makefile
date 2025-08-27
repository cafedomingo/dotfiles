# all symlinks to create (source:target or source for ~/.<source>)
LINKS := \
	curlrc \
	gitconfig \
	gitignore \
	hushlogin \
	nanorc \
	vimrc \
	zprofile \
	zshrc \
	bin \
	sh \
	sh/config/starship.toml:.config/starship.toml \
	sh/config/ssh.config:.ssh/config

# directories to manage
DIRECTORIES := \
	bin \
	.config \
	.ssh

SHELL := /bin/bash
DOTFILES_DIR := $(shell pwd)/dotfiles

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
		$(if $(findstring :,$(link)), \
			$(eval source := $(word 1,$(subst :, ,$(link)))) \
			$(eval target := $(word 2,$(subst :, ,$(link)))) \
			$(RUN) ln -sfhv $(DOTFILES_DIR)/$(source) $(HOME)/$(target), \
			$(RUN) ln -sfhv $(DOTFILES_DIR)/$(link) $(HOME)/.$(link) \
		);)

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
		$(if $(findstring :,$(link)), \
			$(eval target := $(word 2,$(subst :, ,$(link)))) \
			$(RUN) rm -fv $(HOME)/$(target), \
			$(RUN) rm -fv $(HOME)/.$(link) \
		);)

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
