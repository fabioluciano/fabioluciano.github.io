all: clean prepare pdf html

clean:
	sudo rm -rf $(CURDIR)/output

execute_python:
	pip3 install --user -r python/requirements.txt
	GH_TOKEN=6e7888ccf6f691a30bea98eb01a11b813ac3187e python3 $(CURDIR)/python/main.py

prepare:
	docker pull integr8/alpine-asciidoctor-helper

pdf:
	docker run --rm -v $(CURDIR):/documents/ -e 'ASCIIDOCTOR_PLUGIN=tel-inline-macro,highlight-treeprocessor' -e 'ASCIIDOCTOR_PDF_THEMES_DIR=resources/themes' -e 'ASCIIDOCTOR_PDF_THEME=default' -e 'ASCIIDOCTOR_PDF_FONTS_DIR=resources/fonts' integr8/alpine-asciidoctor-helper pdf resume-en.adoc resume-ptbr.adoc

html:
	docker run --rm -v $(CURDIR):/documents/ -e 'ASCIIDOCTOR_PLUGIN=tel-inline-macro' integr8/alpine-asciidoctor-helper html resume-en.adoc resume-ptbr.adoc

