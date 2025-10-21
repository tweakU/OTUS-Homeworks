FROM alpine:latest

RUN apk update && \
    apk add --no-cache nginx

COPY ./default.conf /etc/nginx/http.d/
COPY ./index.html /var/www/default/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
