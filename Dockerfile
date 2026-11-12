# Stage 1: Build the Angular application
FROM node:20-alpine AS build

WORKDIR /usr/src/app

# Copy package files and install exact dependencies
COPY package*.json ./
RUN npm ci

# Copy project source and build for production
COPY . .
RUN npm run build

# Stage 2: Serve the built application with Nginx
FROM nginx:1.27-alpine

# Copy custom Nginx configuration provided in the repository
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy compiled Angular static assets to /app (configured as root in nginx.conf)
COPY --from=build /usr/src/app/dist/olympic-games-starter/browser /app

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
