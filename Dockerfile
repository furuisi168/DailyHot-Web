# 第一阶段：构建阶段
FROM node:18-alpine AS builder
WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm

# 先复制依赖文件，利用 Docker 缓存
COPY package*.json ./
RUN pnpm install

# 复制所有源代码并构建
COPY . .
RUN pnpm build

# 第二阶段：运行阶段
FROM nginx:stable-alpine

# 从构建阶段复制构建产物到 nginx 目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制自定义的 nginx 配置文件（下面会提供内容）
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
