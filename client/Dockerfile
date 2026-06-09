# Stage 1: Build
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./

# RUN npm install
RUN npm ci

COPY . .

# Because GitHub Actions builds the frontend using
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]


# Why --host 0.0.0.0?
# Vite normally listens only inside the container.
# This makes Vite accessible from your browser through Docker port mapping.