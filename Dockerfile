FROM node:16

WORKDIR src/azure-sa

COPY package*.json .

RUN npm install

COPY src/azure-sa .

EXPOSE 3000

CMD ["npm", "start"]