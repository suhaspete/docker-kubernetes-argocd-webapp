#use nginx as base image
FROM nginx

# Copy frontend code into the container
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80

