FROM alpine:3.4

ENV HUGO_VERSION 0.16

RUN apk add --update curl \
    python \
    py-pip \
    && pip install Pygments

RUN curl -L https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-64bit.tgz | tar xvz -C /tmp && \
    mv /tmp/hugo /usr/local/bin/hugo && \
    rm -rf /tmp/* && \
    chmod 777 /tmp

WORKDIR /var/tmp/site

ENTRYPOINT ["hugo"]
