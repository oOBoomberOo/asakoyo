FROM node:18

WORKDIR /app

COPY package.json .
COPY package-lock.json .
RUN npm install

COPY prisma/ prisma/
RUN npx prisma generate

COPY server/ server/
COPY app/ app/
COPY server.imba .

RUN npm run build

CMD [ "npm", "start" ]
