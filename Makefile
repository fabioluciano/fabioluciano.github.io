OUTPUTDIR = ./output/

PDFOPTIONS = -a allow-uri-read -a pdf-theme=src/resources/themes/default-theme.yml -a pdf-fontsdir=src/resources/fonts
OUTPUTFILE_HTML = index.html
OUTPUTFILE_PDF = resume.pdf

CONTAINER_NAME = fabioluciano/fabioluciano.github.io
TAG_NAME = $(shell cat ./VERSION)

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
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor \
		-o $(OUTPUTDIR)ptbr/$(OUTPUTFILE_HTML) \
		src/resume-ptbr.adoc
	cp $(OUTPUTDIR)/ptbr/$(OUTPUTFILE_HTML) $(OUTPUTDIR)$(OUTPUTFILE_HTML)
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor \
		-o $(OUTPUTDIR)en/$(OUTPUTFILE_HTML) \
		src/resume-en.adoc

build_pdf: execute_python
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
		$(PDFOPTIONS) \
		-o $(OUTPUTDIR)ptbr/$(OUTPUTFILE_PDF) \
		src/resume-ptbr.adoc
	docker run --rm -v $(CURDIR):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf \
		$(PDFOPTIONS) \
		-o $(OUTPUTDIR)en/$(OUTPUTFILE_PDF) \
		src/resume-en.adoc

build_docker_image:
	tar -czvf output.tar.gz -C output .
	docker build -t ${CONTAINER_NAME}:$(TAG_NAME) --build-arg DEPLOYMENT=output.tar.gz .
	rm output.tar.gz

push_docker_image:
	echo "$DOCKER_HUB_TOKEN" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin
	docker push ${CONTAINER_NAME}:$(TAG_NAME)