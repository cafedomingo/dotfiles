IS_MACOS := $(shell [ "$$(uname -s)" = "Darwin" ] && echo 1)
SHELL := /bin/bash
REPO_DIR := $(abspath .)

# root dotfiles: auto-discover non-hidden items without file extensions
# hidden items (.*) and items with extensions (README.md) are excluded by convention
EXCLUDE := Makefile LICENSE macos linux prefs claude config ssh private
LINKS := $(shell ls -1 | grep -v '^\.' | grep -v '\.' \
    | grep -v -E '^($(subst $() ,|,$(EXCLUDE)))$$')

# mirror directories: <dirname> → ~/.<dirname>/ (files symlinked, dirs created)
MIRROR_DIRS := claude config ssh

# directories to scan for broken symlinks during cleanup
CLEANUP_DIRS := $(HOME) $(HOME)/bin $(addprefix $(HOME)/.,$(MIRROR_DIRS))

# private repo
PRIVATE_REPO := cafedomingo/dotfiles-private
PRIVATE_DIR := $(REPO_DIR)/private

# list files in a mirror directory, relative to the directory root
MIRROR_FILES = $(shell find $(REPO_DIR)/$(1) -type f 2>/dev/null | sed 's|^$(REPO_DIR)/$(1)/||')

# dry-run support
RUN := $(if $(DRY_RUN),echo "[DRY-RUN]",)

SUCCESS := \033[1;92m
INFO := \033[1;94m
RESET := \033[0m

.PHONY: all install cleanup link starship private clean update-submodules help

all: install

install: cleanup link starship private
	@echo -e "$(SUCCESS)⚡️ Installation complete$(RESET)"

cleanup:
	@echo -e "$(INFO)🧹 Cleaning broken symbolic links$(RESET)"
	@$(foreach dir,$(CLEANUP_DIRS), \
		$(RUN) find $(dir) -maxdepth 1 -type l ! -exec test -e {} \; -exec rm -v {} \; 2>/dev/null || true;)

link:
	@echo -e "$(INFO)🔗 Linking dotfiles$(RESET)"
	@$(foreach link,$(LINKS), \
		$(RUN) ln -sfnv $(REPO_DIR)/$(link) $(HOME)/.$(link);)
	@echo -e "$(INFO)🔗 Linking config files$(RESET)"
	@$(foreach mdir,$(MIRROR_DIRS), \
		$(foreach file,$(call MIRROR_FILES,$(mdir)), \
			$(RUN) mkdir -p "$(HOME)/.$(mdir)/$(dir $(file))"; \
			$(RUN) ln -sfnv "$(REPO_DIR)/$(mdir)/$(file)" "$(HOME)/.$(mdir)/$(file)";))
ifdef IS_MACOS
	@echo -e "$(INFO)🔗 Linking macOS app preferences$(RESET)"
	@$(RUN) mkdir -p "$(HOME)/Library/Application Support/Sublime Text/Packages/User"
	@$(RUN) ln -sfnv "$(REPO_DIR)/macos/sublime-prefs.json" \
		"$(HOME)/Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings"
endif

starship:
	@echo -e "$(INFO)🚀 Installing starship prompt$(RESET)"
	@$(RUN) mkdir -p "$(HOME)/bin"
	@cmd="curl -fsSL https://starship.rs/install.sh | sh -s -- --bin-dir=\"$(HOME)/bin\" --yes 2>&1 | sed '/Please follow the steps/,\$$d'"; \
	$(if $(DRY_RUN),echo "[DRY-RUN] $$cmd",sh -c "$$cmd")

private:
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "Skipping private assets (gh not installed)"; \
	elif ! gh auth status >/dev/null 2>&1; then \
		echo "Skipping private assets (gh not authenticated)"; \
	else \
		latest=$$(gh release view --repo $(PRIVATE_REPO) --json tagName -q .tagName 2>/dev/null) || true; \
		if [ -z "$$latest" ]; then \
			echo "Skipping private assets (no releases found)"; \
		elif [ -f "$(PRIVATE_DIR)/.version" ] && [ "$$(cat $(PRIVATE_DIR)/.version)" = "$$latest" ]; then \
			echo "Private assets up to date ($$latest)"; \
		else \
			echo "Installing private assets $$latest..."; \
			mkdir -p $(PRIVATE_DIR); \
			gh release download "$$latest" --repo $(PRIVATE_REPO) \
				--pattern 'dotfiles-private-*.tar.gz' \
				--dir $(PRIVATE_DIR) --clobber; \
			tar xzf $(PRIVATE_DIR)/dotfiles-private-*.tar.gz \
				-C $(PRIVATE_DIR) --strip-components=1; \
			$(PRIVATE_DIR)/install.sh; \
			rm -f $(PRIVATE_DIR)/dotfiles-private-*.tar.gz; \
			echo "$$latest" > $(PRIVATE_DIR)/.version; \
		fi; \
	fi

clean:
	@echo -e "$(INFO)🗑️ Removing dotfiles symlinks$(RESET)"
	@$(foreach link,$(LINKS), \
		$(RUN) rm -fv $(HOME)/.$(link);)
	@$(foreach mdir,$(MIRROR_DIRS), \
		$(foreach file,$(call MIRROR_FILES,$(mdir)), \
			$(RUN) rm -fv "$(HOME)/.$(mdir)/$(file)";))
ifdef IS_MACOS
	@$(RUN) rm -fv "$(HOME)/Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings"
endif

update-submodules:
	@echo -e "$(INFO)📦 Updating submodules to HEAD$(RESET)"
	@git submodule foreach --quiet ' \
		git fetch --quiet && \
		default=$$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed "s|refs/remotes/||") && \
		[ -z "$$default" ] && default="origin/master"; \
		head=$$(git rev-parse $$default 2>/dev/null) && \
		current=$$(git rev-parse HEAD) && \
		if [ "$$current" = "$$head" ]; then \
			echo "  $$name: up to date"; \
		else \
			git checkout --quiet "$$head" && \
			echo "  $$name: $$(echo $$current | head -c 7) -> $$(echo $$head | head -c 7)"; \
		fi'

help:
	@echo "Usage:"
	@echo "  make [target] [DRY_RUN=1]"
	@echo ""
	@echo "Targets:"
	@echo "  install            Full installation (default)"
	@echo "  cleanup            Clean broken symlinks"
	@echo "  link               Create symbolic links"
	@echo "  starship           Install starship prompt"
	@echo "  private            Install private assets (themes, fonts)"
	@echo "  update-submodules  Update submodules to latest tags"
	@echo "  clean              Remove all symlinks"
	@echo "  help               Show this help"
	@echo ""
	@echo "Options:"
	@echo "  DRY_RUN=1  Show what would be done without making changes"
