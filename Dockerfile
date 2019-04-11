FROM nginx:1.15

ENV PORT=8080
ADD site.template /etc/nginx/site.template
ADD blog/public /usr/share/nginx/html/

ENTRYPOINT [ "/bin/bash", "-c", "envsubst '$PORT' '$HOST' < /etc/nginx/site.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'" ]
