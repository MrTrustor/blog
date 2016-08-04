HUGO_VER = 0.15

all: build upload

all-drafts: build-drafts upload-drafts

build:
	@cd blog && \
         docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
                    mrtrustor/hugo:$(HUGO_VER)

build-drafts:
	@cd blog && \
         docker run --name hugo --rm --user $(shell id -u) \
                    -v $(shell pwd)/blog:/var/tmp/site -p 1313:1313 \
                    mrtrustor/hugo:$(HUGO_VER) --buildDrafts --baseURL="http://blog-drafts.mrtrustor.net"

upload:
	s3deploy -bucket blog.mrtrustor.net -region eu-west-1 -source blog/public/
	$(MAKE) clean

upload-drafts:
	s3deploy -bucket blog-drafts.mrtrustor.net -region eu-west-1 -source blog/public/
	$(MAKE) clean

clean:
	@rm -r blog/public

clean-drafts:
	aws s3 rm --region eu-west-1 s3://blog-drafts.mrtrustor.net/ --recursive 
