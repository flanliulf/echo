FROM node:20.19.0

WORKDIR /app

COPY package*.json ./
RUN npm install --production
RUN npm install -g pm2

COPY . .

EXPOSE 3000

CMD ["pm2-runtime", "ecosystem.config.js", "--env", "production"]
