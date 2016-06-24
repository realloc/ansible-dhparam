#!/usr/bin/make -f

SHELL = bash
LOG_FILE = /dev/null

VENV_BIN = virtualenv
VENV_PATH	= ./.venv
VENV_NAME	= ansible-dhparam
PIP_BIN	= $(VENV_PATH)/bin/pip

ANSIBLE_BIN	= $(VENV_PATH)/bin/ansible
ANSIBLE_PLAYBOOK_BIN = $(VENV_PATH)/bin/ansible-playbook
ANSIBLE_GALAXY_BIN = $(VENV_PATH)/bin/ansible-galaxy
ANSIBLE_VAULT_BIN = $(VENV_PATH)/bin/ansible-vault

MOLECULE_BIN	= $(VENV_PATH)/bin/molecule

ifeq ($(shell command -v $(VENV_BIN) >/dev/null 2>&1; echo $$?), 1)
$(error The '$(VENV_BIN)' is not installed. Please install it first)
endif

.PHONY: setup
setup:
	@echo "**** Setting up an Ansible Environment ****"
	@echo -n "  - Cleaning virtual environment ..... "
	@rm -rf ${VENV_PATH} ||:
	@echo "[OK]"
	@echo -n "  - Creating virtual environment ..... "
	@$(NOW) >> $(LOG_FILE)
	@echo "+ $(VENV_BIN) --python=python2 --prompt=\"($(VENV_NAME)) \" --no-site-packages $(VENV_PATH)" >> $(LOG_FILE)
	@$(VENV_BIN) --python=python2 --prompt="($(VENV_NAME)) " --no-site-packages $(VENV_PATH) >> $(LOG_FILE) 2>&1 || (echo "[ERROR]"; exit 99)
	@echo "[OK]"
	@echo -n "  - Updating pip ..................... "
	@$(NOW) >> $(LOG_FILE)
	@echo "+ $(PIP_BIN) install --upgrade pip" >> $(LOG_FILE)
	@$(PIP_BIN) install --upgrade pip >> $(LOG_FILE) 2>&1|| (echo "[ERROR]"; exit 99)
	@echo "[OK]"
	@echo -n "  - Installing Ansible ............... "
	@echo "" >> $(LOG_FILE)
	@echo "+ $(PIP_BIN) install --upgrade --requirement requirements.txt" >> $(LOG_FILE)
	@$(PIP_BIN) install --upgrade --requirement requirements.txt >> $(LOG_FILE) 2>&1 || (echo "[ERROR]"; exit 99)
	@echo "[OK]"
	@echo ""

.PHONY: info
info: PYTHON_VERSION = $(shell $(VENV_PATH)/bin/python --version 2>&1 | head -n 1 | cut -d ' ' -f 2  )
info: ANSIBLE_VERSION = $(shell $(ANSIBLE_BIN) --version | head -n 1 | cut -d ' ' -f 2  )
info: MOLECULE_VERSION = $(shell $(MOLECULE_BIN) --version | head -n 1  )
info:
	@echo "*********** Ansible Environment ***********"
	@echo "      Python Version : $(PYTHON_VERSION)   "
	@echo "     Ansible Version : $(ANSIBLE_VERSION)  "
	@echo "    Molecule Version : $(MOLECULE_VERSION) "
	@echo ""

.PHONY: test
test: setup info
	source $(VENV_PATH)/bin/activate &&\
	$(MOLECULE_BIN) test

.PHONY: clean
clean:
	rm -rf .cache .molecule .venv .vagrant
