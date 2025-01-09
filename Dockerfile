FROM alpine

RUN addgroup -S nonroot \
    && adduser -S nonroot -G nonroot

USER nonroot

ENTRYPOINT ["id"]

WORKDIR /src/azure-sa

COPY package*.json ./

RUN npm install --ignore-scripts

COPY ./src ./

EXPOSE 3000

CMD ["npm", "start"]