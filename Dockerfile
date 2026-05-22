# 第一阶段：构建阶段
FROM node:20-alpine AS builder
WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm

# 复制依赖描述文件
COPY package*.json ./

# 创建 .npmrc 文件，允许 esbuild 执行构建脚本（解决 Host/Binary 版本冲突）
RUN echo "allow-build=esbuild" > .npmrc

# 安装依赖（此时 pnpm 会读取 .npmrc 并授权 esbuild）
RUN pnpm install

# 复制所有源代码
COPY . .

# 构建前端项目
RUN pnpm build

# 第二阶段：运行阶段
FROM nginx:stable-alpine

# 将构建产物复制到 nginx 默认目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 自定义 nginx 配置（如果项目根目录下没有 nginx.conf，请删除下一行）
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
