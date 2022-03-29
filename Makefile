export SHELL:=/bin/bash
.ONESHELL:
UNAME:=$(shell uname)

export PATH:=$(CURDIR)/conda/bin:$(CURDIR)/bin:$(PATH)
unexport PYTHONPATH
unexport PYTHONHOME

ifeq ($(UNAME), Darwin)
CONDASH:=Miniconda3-4.7.12-MacOSX-x86_64.sh
endif

ifeq ($(UNAME), Linux)
CONDASH:=Miniconda3-4.7.12-Linux-x86_64.sh
endif

CONDAURL:=https://repo.anaconda.com/miniconda/$(CONDASH)

# might also need this one macOS:  brew install coreutils
conda:
	@set +e
	echo ">>> Setting up conda..."
	wget "$(CONDAURL)"
	bash "$(CONDASH)" -b -p conda
	rm -f "$(CONDASH)"

install: conda
	conda install -y conda-forge::nodejs
	pip install -r requirements.txt

bash:
	bash
