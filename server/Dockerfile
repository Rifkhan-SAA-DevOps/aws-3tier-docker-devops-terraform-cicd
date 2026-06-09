FROM node:20-alpine

WORKDIR /app

# Alpine image may not include wget or curl
# We need it because Docker Compose healthcheck will use wget.
RUN apk add --no-cache wget  

COPY package*.json ./

RUN npm ci --omit=dev 
# RUN npm ci --only=production
# RUN npm ci --omit=dev #Because npm ci installs exactly from package-lock.json, so builds are more predictable
# Installs only production dependencies
# RUN npm install

COPY . .

# RUN addgroup -S appgroup && adduser -S appuser -G appgroup
# Creates a non-root user.

# USER appuser
# Runs your backend as non-root.
# This is better for security.

EXPOSE 5000

CMD ["npm", "start"]