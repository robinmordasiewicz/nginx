FROM nginx:latest
COPY html /usr/share/nginx/html/
COPY VERSION /usr/share/nginx/html/version.html
