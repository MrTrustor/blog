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
	echo "User-agent: *" > $(shell pwd)/blog/public/robots.txt
	echo "Disallow: /" >> $(shell pwd)/blog/public/robots.txt

upload:
	s3deploy -bucket blog.mrtrustor.net -region eu-west-1 -source blog/public/

upload-drafts:
	s3deploy -bucket blog-drafts.mrtrustor.net -region eu-west-1 -source blog/public/

upload-gcs:
	gsutil -m rsync -d -r -a public-read -x ".DS_Store" -x "robots.txt" blog/public/ gs://blog.mrtrustor.net/

upload-drafts-gcs:
	gsutil -m rsync -d -r -a public-read -x ".DS_Store" blog/public/ gs://blog-drafts.mrtrustor.net/

clean:
	@rm -r blog/public

clean-drafts:
	aws s3 rm --region eu-west-1 s3://blog-drafts.mrtrustor.net/ --recursive

clean-drafts-gcs:
	gsutil -m rm -r gs://blog-drafts.mrtrustor.net/*

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
