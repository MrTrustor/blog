HUGO_VER = 0.46

all: build upload-gcs

all-drafts: build-drafts upload-drafts-gcs

build:
	@cd blog && \
         docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
                    mrtrustor/hugo:$(HUGO_VER) --baseURL="https://blog-nl3g4apd7q-uc.a.run.app/"

build-drafts:
	@cd blog && \
         docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
		    mrtrustor/hugo:$(HUGO_VER) --buildDrafts --baseURL="https://blog-drafts.mrtrustor.net/"
	echo "User-agent: *" > $(shell pwd)/blog/public/robots.txt
	echo "Disallow: /" >> $(shell pwd)/blog/public/robots.txt

upload-gcs:
	gsutil -m rsync -d -r -a public-read -x ".DS_Store" -x "robots.txt" blog/public/ gs://blog.mrtrustor.net/

upload-drafts-gcs:
	gsutil -m rsync -d -r -a public-read -x ".DS_Store" blog/public/ gs://blog-drafts.mrtrustor.net/

clean:
	@rm -r blog/public

clean-drafts-gcs:
	gsutil -m rm -r gs://blog-drafts.mrtrustor.net/*

server:
	@cd blog && \
	docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
										-e LOCAL=true \
		    mrtrustor/hugo:$(HUGO_VER) --buildDrafts --baseURL="http://127.0.0.1:1313/" --bind 0.0.0.0 server
