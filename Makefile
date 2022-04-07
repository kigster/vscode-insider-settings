# vim: ts=8 ft=make
.PHONY: help backup-all-extensions binary-vscode binary-vscode-insiders binary-vscode-insiders import-extensions dump-extensions dump-extensions-vscode dump-extensions-vscode-insiders import-extensions-vscode import-extensions-vscode-insiders install-fonts install-launchers install-vscode install-vscode-insiders verify-binary vscode vscode-insiderVSCODE_PATH="/Applications/Visual Studio Code.app"

white           := \033[0;30m
red             := \033[0;31m
yellow          := \033[0;33m
purple          := \033[0;35m
blue            := \033[0;32m
clear           := \033[0m
bg_red          := \033[7;31m
bg_blue         := \033[7;32m
bg_purple       := \033[7;35m

args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a="$($a)"))

VSCODE_STANDARD_PATH="/Applications/Visual Studio Code.app"
VSCODE_INSIDERS_PATH="/Applications/Visual Studio Code - Insiders.app"

VSCODE_STANDARD_LAUNCHER_PATH="$(shell echo $(VSCODE_PATH)/Contents/Resources/app/bin/code)"
VSCODE_INSIDERS_LAUNCHER_PATH="$(shell echo $(VSCODE_INSIDERS_PATH)/Contents/Resources/app/bin/code)"

VSCODE_STANDARD_SETTINGS_PATH="$(HOME)/Library/Application Support/Code/User"
VSCODE_INSIDERS_SETTINGS_PATH="$(HOME)/Library/Application Support/Code - Insiders/User"

NOW=$(shell $(shell command -v gdate>/dev/null && echo 'gdate' || echo 'date') "+%Y%m%d.%T.%N" | tr -d '/:')

CURRENT:=$(NOW)
EXTENSIONS_FILE=settings/extensions.txt
STANDARD_SETTINGS=settings/standard
INSIDERS_SETTINGS=settings/insiders

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'

verify-binary:
	@printf "\n$(bg_blue)  👉  $(blue)$(clear) Verifying vscode binary... \n\n"
	@test -z ${VSCODE_BINARY} && echo 'BINARY is not set, abort.' && exit 1
	@command -v ${VSCODE_BINARY}>/dev/null || {  \
		echo 'Can not find code-insiders executable. Did you create the command launcher from VSCode Insiders?'; \
		exit 1 ;\
	}

#---------------------------------------------------------------------------

backup-all-extensions:
	@bash -c "[[ -f $(EXTENSIONS_FILE) && ! -h $(EXTENSIONS_FILE) ]] && mv -v $(EXTENSIONS_FILE) $(EXTENSIONS_FILE).$(NOW) || true"

dump-extensions-vscode: VSCODE_BINARY = $(shell echo code)
dump-extensions-vscode: backup-all-extensions ## Exports list of extensions of VSCode to extensions.txt
	@printf "\n$(bg_blue)  👉  $(blue)$(clear) Exporting extensions and settings from regular VSCode... \n\n"
	@mkdir -vp $(STANDARD_SETTINGS)
	@${VSCODE_BINARY} --list-extensions | sort > $(STANDARD_SETTINGS)/extensions-standard.txt
	@ln -nfs standard/extensions-standard.txt $(EXTENSIONS_FILE)
	@cp -vf $(VSCODE_STANDARD_SETTINGS_PATH)/*.{json,dict} $(STANDARD_SETTINGS)/ || true

dump-extensions-vscode-insiders: VSCODE_BINARY = $(shell echo code-insiders)
dump-extensions-vscode-insiders: backup-all-extensions ## Exports list of extensions of VSCode Insiders to extensions.txt
	@printf "\n$(bg_blue)  👉  $(blue)$(clear) Exporting extensions and settings from VSCode Insiders... \n\n"
	@mkdir -vp $(INSIDERS_SETTINGS)
	@${VSCODE_BINARY} --list-extensions | sort > $(INSIDERS_SETTINGS)/extensions-insiders.txt
	@ln -nfs insiders/extensions-insiders.txt $(EXTENSIONS_FILE)
	@cp -vf $(VSCODE_INSIDERS_SETTINGS_PATH)/*.{json,dict} $(INSIDERS_SETTINGS)/ || true

dump: dump-extensions-vscode-insiders  dump-extensions-vscode	 ## Dumps both Insiders and Standard settings, if available

#---------------------------------------------------------------------------

backup-settings-vscode: ARCHIVE = $(shell echo $(STANDARD_SETTINGS)/vscode-standard-library-backup-$(CURRENT).tar.gz)
backup-settings-vscode:
	@printf "\n$(bg_green)  👉  $(blue)$(clear) Backing up previous settings for VSCode\n\n"
	@tar cvzf $(ARCHIVE) $(VSCODE_STANDARD_SETTINGS_PATH)/*.{json,dict} || true
	@[[ -f $(ARCHIVE) ]] && mv -v $(ARCHIVE) archive/

import-extensions-vscode: VSCODE_BINARY = $(shell echo code)
import-extensions-vscode: backup-settings-vscode ## Import extensions from extensions.txt into VSCode
	@printf "\n$(bg_blue)  👉  $(blue)$(clear) Importing extensions and settings for VSCode \n\n"
	@cat $(EXTENSIONS_FILE) | xargs -L 1 ${VSCODE_BINARY} --install-extension 2>/dev/null| egrep '^Extension ' || true
	@cp -vf $(STANDARD_SETTINGS)/*.{json,dict} $(VSCODE_STANDARD_SETTINGS_PATH) || true

backup-settings-vscode-insiders: ARCHIVE = $(shell echo $(INSIDERS_SETTINGS)/vscode-insiders-library-backup-$(CURRENT).tar.gz)
backup-settings-vscode-insiders: 
	@printf "\n$(bg_green)  👉  $(blue)$(clear) Backing up previous settings for VSCode Insiders \n\n"
	@tar cvzf "$(ARCHIVE)" $(VSCODE_INSIDERS_SETTINGS_PATH)/*.{json,dict} || true
	@mv -v "$(ARCHIVE)" archive/

import-extensions-vscode-insiders: VSCODE_BINARY = $(shell echo code-insiders)
import-extensions-vscode-insiders: backup-settings-vscode-insiders ## Import extensions from extensions.txt into VSCode Insiders
	@printf "\n$(bg_blue)  👉  $(blue)$(clear) Importing extensions and settings for VSCode Insiders \n\n"
	@cat $(EXTENSIONS_FILE) | xargs -L 1 ${VSCODE_BINARY} --install-extension 2>/dev/null| egrep '^Extension ' || true
	@cp -vf $(INSIDERS_SETTINGS)/*.{json,dict} $(VSCODE_INSIDERS_SETTINGS_PATH) || true

install-launchers: ## Install command launchers for VSCode and VSCode Insiders
	@printf "\n$(bg_blue)  👉  $(blue)$(clear) Installing command line launchers... \n\n"
	@if [[ -x $(VSCODE_STANDARD_LAUNCHER_PATH) ]]; then \
		cd /usr/local/bin || exit 1; \
		ln -nvfs $(VSCODE_STANDARD_LAUNCHER_PATH) code; \
		ln -nvfs $(VSCODE_STANDARD_LAUNCHER_PATH) co; \
		cd - > /dev/null || exit 1; \
		echo "IMPORTANT: installed CLI aliases 'code' and 'co' for VSCode"; \
	fi 
	@if [[ -x $(VSCODE_INSIDERS_LAUNCHER_PATH) ]]; then \
		cd /usr/local/bin ; \
		ln -nvfs $(VSCODE_INSIDERS_LAUNCHER_PATH) code-insiders; \
		ln -nvfs $(VSCODE_INSIDERS_LAUNCHER_PATH) ci; \
		echo "IMPORTANT: installed CLI aliases 'code-insiders' and 'ci' for VSCode Insiders"; \
	fi

install-vscode: ## Install VSCode using brew
	@if [[ ! -d $(VSCODE_STANDARD_PATH) ]] ; then brew install --cask visual-studio-code; else echo 'VSCode is already installed.'; fi

install-vscode-insiders: ## Install VSCode-Insiders using brew
	@if [[ ! -d $(VSCODE_INSIDERS_PATH) ]] ; then brew install --cask homebrew/cask-versions/visual-studio-code-insiders; else echo 'VSCode Insiders is already installed.'; fi

install-fonts: ## Install a slew of excellent open-source Mono-Spaced fonts for the IDE & Terminal
	@printf "\n$(bg_blue)  👉  $(blue)$(clear) Installing amazing mono-spaced fonts...\n\n"
	@./bin/mono-install

install: install-fonts vscode-insiders vscode-standard copy-standard-to-insiders ## Install fonts, VSCode, Insiders and copy standard settings into insiders

vscode-insiders: install-vscode-insiders install-launchers import-extensions-vscode-insiders  ## Installs VSCode Insiders Edition, mono-fonts, and the extensions

vscode-standard: install-vscode 	 install-launchers import-extensions-vscode  ## Installs VSCode Regular Edition, mono-fonts, and the extensions

copy-standard-to-insiders:  dump-extensions-vscode-insiders dump-extensions-vscode
	@cp -v $(VSCODE_STANDARD_SETTINGS_PATH)/*.{json,dict} $(INSIDERS_SETTINGS)/ || true

import-standard-to-insiders: install-fonts install-vscode-insiders copy-standard-to-insiders import-extensions-vscode-insiders ## Import standard settings from VSCode into Insiders Edition

