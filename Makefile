OUTPUTDIR = ./output/

PDFOPTIONS = -a allow-uri-read -a pdf-theme=src/resources/themes/default-theme.yml -a pdf-fontsdir=src/resources/fonts
HTMLOPTIONS = -a toc=left -a docinfo=shared
OUTPUTFILE_HTML = index.html
OUTPUTFILE_PDF = resume-raw.pdf

CONTAINER_NAME = fabioluciano/fabioluciano.github.io
TRAVIS_TAG ?= latest
TAG_NAME = ${TRAVIS_TAG}

all: clean prepare execute_python build_html build_pdf optimize_pdf build_docker_image

clean:
	sudo rm -rf $(CURDIR)/output

prepare:
	docker pull asciidoctor/docker-asciidoctor
	mkdir -p $(CURDIR)/output/en $(CURDIR)/output/ptbr

execute_python: prepare
	pip3 install -r $(CURDIR)/src/python/requirements.txt
	python3 $(CURDIR)/src/python/main.py

build_html:
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor \
		-o $(OUTPUTDIR)ptbr/$(OUTPUTFILE_HTML) \
		$(HTMLOPTIONS) \
		src/resume-ptbr.adoc
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor \
		-o $(OUTPUTDIR)en/$(OUTPUTFILE_HTML) \
		$(HTMLOPTIONS) \
		src/resume-en.adoc
	cp $(OUTPUTDIR)/ptbr/$(OUTPUTFILE_HTML) $(OUTPUTDIR)$(OUTPUTFILE_HTML)

build_pdf:
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
		$(PDFOPTIONS) -o $(OUTPUTDIR)ptbr/$(OUTPUTFILE_PDF) \
		src/resume-ptbr.adoc
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
		$(PDFOPTIONS) -o $(OUTPUTDIR)en/$(OUTPUTFILE_PDF) \
		src/resume-en.adoc

optimize_pdf:
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$(OUTPUTDIR)ptbr/resume.pdf $(OUTPUTDIR)ptbr/resume-raw.pdf
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$(OUTPUTDIR)en/resume.pdf $(OUTPUTDIR)en/resume-raw.pdf
	rm $(OUTPUTDIR)ptbr/resume-raw.pdf $(OUTPUTDIR)en/resume-raw.pdf -f

build_docker_image:
	tar -czvf output.tar.gz -C output .
	docker build -t ${CONTAINER_NAME}:$(TAG_NAME) --build-arg DEPLOYMENT=output.tar.gz .
	rm output.tar.gz

push_docker_image:
	echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USERNAME}" --password-stdin
	docker push ${CONTAINER_NAME}:$(TAG_NAME)