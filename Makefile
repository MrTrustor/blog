HUGO_VER = 0.46

build:
	@cd blog && \
         docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
                    mrtrustor/hugo:$(HUGO_VER) --baseURL="https://blog.mrtrustor.net/"

build-drafts:
	@cd blog && \
         docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
		    mrtrustor/hugo:$(HUGO_VER) --buildDrafts --baseURL="https://blog-drafts.mrtrustor.net/"

server:
	@cd blog && \
	docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
										-e LOCAL=true \
		    mrtrustor/hugo:$(HUGO_VER) --buildDrafts --baseURL="http://127.0.0.1:1313/" --bind 0.0.0.0 server
