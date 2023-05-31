FROM node:16.20.0-slim

WORKDIR /app
COPY . .

RUN yarn install

EXPOSE 5173

CMD ["yarn", "start"]
