HUGO_VER = 0.26

all: build upload

all-drafts: build-drafts upload-drafts

all-gcs: build upload-gcs

all-drafts-gcs: build-drafts upload-drafts-gcs

build:
	@cd blog && \
         docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
                    mrtrustor/hugo:$(HUGO_VER)

build-drafts:
	@cd blog && \
         docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
		    mrtrustor/hugo:$(HUGO_VER) --buildDrafts --baseURL="https://blog-drafts.mrtrustor.net/"

upload:
	s3deploy -bucket blog.mrtrustor.net -region eu-west-1 -source blog/public/
	$(MAKE) clean

upload-drafts:
	s3deploy -bucket blog-drafts.mrtrustor.net -region eu-west-1 -source blog/public/
	$(MAKE) clean

upload-gcs:
	gsutil -m rsync -d -r -a public-read -x ".DS_Store" blog/public/ gs://blog.mrtrustor.net/
	$(MAKE) clean

upload-drafts-gcs:
	gsutil -m rsync -d -r -a public-read -x ".DS_Store" blog/public/ gs://blog-drafts.mrtrustor.net/
	$(MAKE) clean

clean:
	@rm -r blog/public

clean-drafts:
	aws s3 rm --region eu-west-1 s3://blog-drafts.mrtrustor.net/ --recursive

post:
	@cd blog && \
	docker run --name hugo --rm --user $(shell id -u) \
		-v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
		mrtrustor/hugo:$(HUGO_VER) \
		new post/$(POST_NAME).md

server:
	@cd blog && \
	docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
		    mrtrustor/hugo:$(HUGO_VER) --buildDrafts --baseURL="http://127.0.0.1:1313" --bind 0.0.0.0 server
