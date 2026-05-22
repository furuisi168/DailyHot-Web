# 第一阶段：构建阶段
FROM node:20-alpine AS builder
WORKDIR /app

# 复制依赖描述文件
COPY package*.json ./

# 安装依赖（使用 npm，避免 pnpm 的 esbuild 权限问题）
RUN npm install

# ====== 关键：设置 API 地址 ======
# 如果你的前后端用 docker-compose 部署，推荐用服务名 api
ENV VITE_GLOBAL_API=http://ssh.mengdi520.site:6688

# 复制所有源代码
COPY . .

# 构建前端项目（此时 VITE_GLOBAL_API 会注入到代码中）
RUN npm run build

# 第二阶段：运行阶段
FROM nginx:stable-alpine
COPY --from=builder /app/dist /usr/share/nginx/html

# 自定义 nginx 配置（确保项目根目录下有 nginx.conf）
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
