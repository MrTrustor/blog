HUGO_VER = 0.15

all: build upload

all-drafts: build-drafts upload

build:
	@cd blog && \
         docker run --name hugo --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
                    mrtrustor/hugo:$(HUGO_VER)

build-drafts:
	@cd blog && \
         docker run --name hugo --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
                    mrtrustor/hugo:$(HUGO_VER) --buildDrafts

upload:
	aws s3 sync --delete --region eu-west-1 blog/public/ s3://blog.mrtrustor.net/
	$(MAKE) clean

clean:
	@docker rm hugo >/dev/null
	@rm -r blog/public
