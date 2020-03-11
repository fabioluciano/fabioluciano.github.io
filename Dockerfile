FROM nginx:1-alpine
ARG DEPLOYMENT
ADD ${DEPLOYMENT} /usr/share/nginx/html