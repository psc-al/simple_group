FROM hernanat/simple-group-app-prod:latest AS Builder

FROM nginx:1.18.0-alpine

COPY --from=Builder /opt/rails/public /var/www/public

ADD ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
