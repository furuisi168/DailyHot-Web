# 第一阶段：构建阶段
FROM node:20-alpine AS builder
WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm

# 复制依赖描述文件
COPY package*.json ./

# 安装依赖（pnpm 可能忽略 esbuild 构建脚本）
RUN pnpm install

# 🔧 手动执行 esbuild 的安装脚本，确保二进制文件匹配当前版本
RUN node node_modules/esbuild/install.js

# 复制所有源代码
COPY . .

# 构建前端项目（此时 esbuild 版本一致，可正常构建）
RUN pnpm build

# 第二阶段：运行阶段
FROM nginx:stable-alpine

# 将构建产物复制到 nginx 默认目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 自定义 nginx 配置（如果项目根目录下没有 nginx.conf，请注释掉或删除下一行）
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
