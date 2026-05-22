# 第一阶段：构建阶段
FROM node:20-alpine AS builder
WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm

# 复制依赖文件
COPY package*.json ./

# 安装依赖
RUN pnpm install

# 复制所有源代码并构建
COPY . .
RUN pnpm build

# 第二阶段：运行阶段
FROM nginx:stable-alpine

# 复制构建产物到 nginx 目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制自定义 nginx 配置（确保项目根目录下有 nginx.conf 文件）
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
