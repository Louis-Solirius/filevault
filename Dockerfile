FROM node:20-alpine

RUN addgroup -S nonroot \
    && adduser -S nonroot -G nonroot

USER nonroot

RUN id

WORKDIR /app

COPY --chown=nonroot:nonroot --chmod=755 package*.json ./

RUN npm install --ignore-scripts

COPY --chown=nonroot:nonroot ./ ./

EXPOSE 3000

CMD ["npm", "start"]