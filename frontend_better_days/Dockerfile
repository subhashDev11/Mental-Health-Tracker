# # Stage 1: Build the Flutter web app
# FROM cirrusci/flutter:stable AS builder

# WORKDIR /app

# # Copy Flutter project files
# COPY . .

# # Get dependencies
# RUN flutter pub get

# # Build web release version
# RUN flutter build web

# # Stage 2: Serve using nginx
# FROM nginx:alpine

# # Remove default nginx static files
# RUN rm -rf /usr/share/nginx/html/*

# # Copy Flutter web build from builder
# COPY --from=builder /app/build/web /usr/share/nginx/html

# # Copy custom nginx config if needed (optional)
# # COPY nginx.conf /etc/nginx/nginx.conf

# # Expose port 80 inside the container
# EXPOSE 80

# # Start nginx
# CMD ["nginx", "-g", "daemon off;"]