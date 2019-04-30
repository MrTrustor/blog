FROM nginx:1.15

ENV PORT=8080 \
    ROBOTS_FILE=robots-prod.txt
ADD site.template /etc/nginx/site.template
ADD blog/public /usr/share/nginx/html/

ENTRYPOINT [ "/bin/bash", "-c", "envsubst '$PORT $HOST $ROBOTS_FILE' < /etc/nginx/site.template > /etc/nginx/conf.d/default.conf && mkdir -p /var/log/nginx && exec nginx -g 'daemon off;'" ]
