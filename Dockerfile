FROM nginx:1.15

ADD site.template /etc/nginx/site.template
ADD blog/public /usr/share/nginx/html/

ENTRYPOINT [ "/bin/bash", "-c", "envsubst < /etc/nginx/site.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'" ]
