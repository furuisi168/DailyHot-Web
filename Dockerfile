# 第一阶段：构建阶段
FROM node:20-alpine AS builder
WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm

# 允许 esbuild 执行安装后脚本（解决版本不匹配问题）
RUN pnpm config set allow-build esbuild

# 复制依赖描述文件
COPY package*.json ./

# 安装依赖
RUN pnpm install

# 复制所有源代码
COPY . .

# 构建前端项目
RUN pnpm build

# 第二阶段：运行阶段
FROM nginx:stable-alpine

# 将构建产物复制到 nginx 默认目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 如果项目根目录下没有 nginx.conf，请创建一个并放在 Dockerfile 同级目录，
# 否则可以将下面这行注释掉，使用 nginx 默认配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
