#----------stage: INIT----------
#Tạo môi trường build, install dependencies và buil ứng dụng
FROM node:18-alpine AS build
# Thiết lập thư mục làm việc trong container
WORKDIR /app
# Sao chép package.json và package-lock.json (hoặc yarn.lock) vào thư mục làm việc
COPY package*.json ./
# Cài đặt các dependencies
RUN npm install
# Sao chép tất cả các file trong dự án của bạn vào thư mục làm việc
COPY . .
# Build ứng dụng
RUN npm run build

#----------stage: PRODUCTION----------
# Stage này sẽ copy các file đã build sang một image mới
# với mục đích loại bỏ hết các build tool cho nhẹ
FROM node:18-alpine AS deploy-node
WORKDIR /app
COPY --from=build /app/public ./public
COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json .
ENV NODE_ENV=production
RUN npm install

# Chạy ứng dụng cổng 8081
EXPOSE 8081
CMD ["npm", "run", "serve"]