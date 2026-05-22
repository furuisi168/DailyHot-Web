# 第一阶段：构建阶段
FROM node:20-alpine AS builder
WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm

# 复制依赖描述文件
COPY package*.json ./

# 安装依赖，强制允许 esbuild 执行构建脚本（修复 Host/Binary 版本冲突）
RUN pnpm install --allow-build=esbuild

# 复制所有源代码
COPY . .

# 构建前端项目
RUN pnpm build

# 第二阶段：运行阶段
FROM nginx:stable-alpine

# 将构建产物复制到 nginx 默认目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 自定义 nginx 配置（如果项目根目录无此文件，请删除下面这行，否则构建会报错）
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
