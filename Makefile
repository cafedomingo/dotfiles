IS_MACOS := $(shell [ "$$(uname -s)" = "Darwin" ] && echo 1)
SHELL := /bin/bash
REPO_DIR := $(shell pwd)

# root dotfiles: auto-discover non-hidden items without file extensions
# hidden items (.*) and items with extensions (README.md) are excluded by convention
EXCLUDE := Makefile LICENSE macos linux prefs claude config ssh private
LINKS := $(shell ls -1 | grep -v '^\.' | grep -v '\.' \
    | grep -v -E '^($(shell echo $(EXCLUDE) | sed "s/ /|/g"))$$')

# mirror directories: <dirname> → ~/.<dirname>/ (files symlinked, dirs created)
MIRROR_DIRS := claude config ssh

# directories to scan for broken symlinks during cleanup
CLEANUP_DIRS := $(HOME) $(HOME)/bin $(HOME)/.claude $(HOME)/.config $(HOME)/.config/ghostty $(HOME)/.ssh

# private repo
PRIVATE_REPO := cafedomingo/dotfiles-private
PRIVATE_DIR := $(REPO_DIR)/private

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
	@$(foreach dir,$(MIRROR_DIRS), \
		$(foreach file,$(shell find $(REPO_DIR)/$(dir) -type f 2>/dev/null | sed 's|^$(REPO_DIR)/$(dir)/||'), \
			$(RUN) mkdir -p "$(HOME)/.$(dir)/$(dir $(file))"; \
			$(RUN) ln -sfnv "$(REPO_DIR)/$(dir)/$(file)" "$(HOME)/.$(dir)/$(file)";))
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
	@$(foreach dir,$(MIRROR_DIRS), \
		$(foreach file,$(shell find $(REPO_DIR)/$(dir) -type f 2>/dev/null | sed 's|^$(REPO_DIR)/$(dir)/||'), \
			$(RUN) rm -fv "$(HOME)/.$(dir)/$(file)";))
ifdef IS_MACOS
	@$(RUN) rm -fv "$(HOME)/Library/Application Support/Sublime Text/Packages/User/Preferences.sublime-settings"
endif

update-submodules:
	@echo -e "$(INFO)📦 Updating submodules to latest tags$(RESET)"
	@git submodule foreach --quiet ' \
		git fetch --tags --quiet && \
		latest=$$(git tag --sort=-v:refname | grep -v -E "[-](alpha|beta|rc|pre|dev)" | head -1) && \
		[ -z "$$latest" ] && latest=$$(git tag --sort=-v:refname | head -1); \
		if [ -n "$$latest" ]; then \
			current=$$(git describe --tags --exact-match 2>/dev/null || echo "untagged"); \
			if [ "$$current" = "$$latest" ]; then \
				echo "  $$name: already at $$latest"; \
			else \
				git checkout --quiet "$$latest" && \
				echo "  $$name: $$current -> $$latest"; \
			fi; \
		else \
			echo "  $$name: no tags found, skipping"; \
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
