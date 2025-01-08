FROM node:20-alpine

WORKDIR /src/azure-sa

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]