FROM node:18 AS build

RUN npm install node-gyp -g

WORKDIR /api
COPY ./packages/system-api/package.json /api/package.json
RUN npm i
# ---
WORKDIR /dashboard
COPY ./packages/dashboard/package.json /dashboard/package.json
RUN npm i

WORKDIR /api
COPY ./packages/system-api /api
RUN npm run build
# ---
WORKDIR /dashboard
COPY ./packages/dashboard /dashboard
RUN npm run build


FROM alpine:3.19.3 as app

WORKDIR /

# # Install dependencies
RUN apk --no-cache add nodejs npm
RUN apk --no-cache add g++
RUN apk --no-cache add make
RUN apk --no-cache add python3

RUN npm install node-gyp -g

WORKDIR /api
COPY ./packages/system-api/package*.json /api/
RUN npm install --omit=dev

WORKDIR /dashboard
COPY ./packages/dashboard/package*.json /dashboard/
RUN npm install --omit=dev

COPY --from=build /api/dist /api/dist

COPY --from=build /dashboard/.next /dashboard/.next
COPY ./packages/dashboard /dashboard

WORKDIR /