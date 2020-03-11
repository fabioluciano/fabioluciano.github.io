OUTPUTDIR = ./output/

OUTPUTSTRING = -D $(OUTPUTDIR) -a outdir=$(OUTPUTDIR)
PDFOPTIONS = -a allow-uri-read -a pdf-theme=src/resources/themes/default-theme.yml -a pdf-fontsdir=src/resources/fonts

OUTPUTFILE_HTML = index.html
OUTPUTFILE_PDF = resume.pdf

TAG = $(shell cat ./VERSION)

all: clean prepare execute_python build_html build_pdf build_docker_image

clean:
	sudo rm -rf $(CURDIR)/output

prepare:
	docker pull integr8/alpine-asciidoctor-helper
	mkdir -p -m 0777 $(CURDIR)/output/{en,ptbr}

execute_python: prepare
	pip3 install -r $(CURDIR)/src/python/requirements.txt
	python3 $(CURDIR)/src/python/main.py

build_html: execute_python
	docker run --rm --user 1000:1000 -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor \
		-o ./ptbr/$(OUTPUTFILE_HTML) \
		$(OUTPUTSTRING) src/resume-ptbr.adoc
	cp $(OUTPUTDIR)/ptbr/$(OUTPUTFILE_HTML) $(OUTPUTDIR)$(OUTPUTFILE_HTML)
	docker run --rm --user 1000:1000 -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor \
		-o ./en/$(OUTPUTFILE_HTML) \
		$(OUTPUTSTRING) src/resume-en.adoc

build_pdf: execute_python
	docker run --rm --user 1000:1000 -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
		$(PDFOPTIONS) \
		-o ./ptbr/$(OUTPUTFILE_PDF) \
		$(OUTPUTSTRING) src/resume-ptbr.adoc
	docker run --rm --user 1000:1000 -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
		$(PDFOPTIONS) \
		-o ./en/$(OUTPUTFILE_PDF) \
		$(OUTPUTSTRING) src/resume-en.adoc

build_docker_image:
	tar -czvf output.tar.gz -C output .
	docker build -t fabioluciano.dev:$(TAG) --build-arg DEPLOYMENT=output.tar.gz .
	rm output.tar.gz
