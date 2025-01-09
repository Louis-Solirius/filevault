FROM node:20-alpine

RUN addgroup -S nonroot \
    && adduser -S nonroot -G nonroot

USER nonroot

RUN id

WORKDIR /src/azure-sa

COPY --chown=root:root --chmod=755 package*.json ./

RUN npm install --ignore-scripts

COPY ./src ./

EXPOSE 3000

CMD ["npm", "start"]