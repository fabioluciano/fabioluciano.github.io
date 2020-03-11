OUTPUTDIR = ./output/

PDFOPTIONS = -a allow-uri-read -a pdf-theme=src/resources/themes/default-theme.yml -a pdf-fontsdir=src/resources/fonts

OUTPUTFILE_HTML = index.html
OUTPUTFILE_PDF = resume.pdf

TAG = $(shell cat ./VERSION)

all: clean prepare build_html build_pdf build_docker_image

clean:
	sudo rm -rf $(CURDIR)/output

prepare:
	docker pull asciidoctor/docker-asciidoctor
	mkdir -p $(CURDIR)/output/en $(CURDIR)/output/ptbr

execute_python: prepare
	pip3 install -r $(CURDIR)/src/python/requirements.txt
	python3 $(CURDIR)/src/python/main.py

build_html: execute_python
	docker run --rm --user 1000:1000 -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor \
		-o $(OUTPUTDIR)ptbr/$(OUTPUTFILE_HTML) \
		src/resume-ptbr.adoc
	cp $(OUTPUTDIR)/ptbr/$(OUTPUTFILE_HTML) $(OUTPUTDIR)$(OUTPUTFILE_HTML)
	docker run --rm --user 1000:1000 -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor \
		-o $(OUTPUTDIR)en/$(OUTPUTFILE_HTML) \
		src/resume-en.adoc

build_pdf: execute_python
	docker run --rm --user 1000:1000 -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
		$(PDFOPTIONS) \
		-o $(OUTPUTDIR)ptbr/$(OUTPUTFILE_PDF) \
		src/resume-ptbr.adoc
	docker run --rm --user 1000:1000 -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
		$(PDFOPTIONS) \
		-o $(OUTPUTDIR)en/$(OUTPUTFILE_PDF) \
		src/resume-en.adoc

build_docker_image:
	tar -czvf output.tar.gz -C output .
	docker build -t fabioluciano.dev:$(TAG) --build-arg DEPLOYMENT=output.tar.gz .
	rm output.tar.gz
