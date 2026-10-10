FROM nginx:alpine
RUN apk update && \
    apk add --no-cache libexpat>=2.8.5-r0 pcre2>=10.49-r0 tiff>=4.7.2-r0
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
