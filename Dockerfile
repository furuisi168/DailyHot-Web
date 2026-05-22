# 第一阶段：构建阶段
FROM node:20-alpine AS builder
WORKDIR /app

# 复制依赖描述文件（package.json 和 package-lock.json 如存在）
COPY package*.json ./

# 使用 npm 安装依赖（默认执行 esbuild 构建脚本，不会出现版本冲突）
RUN npm install

# 复制所有源代码
COPY . .

# 构建前端项目
RUN npm run build

# 第二阶段：运行阶段
FROM nginx:stable-alpine

# 将构建产物复制到 nginx 默认目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 自定义 nginx 配置（确保项目根目录下有 nginx.conf 文件，否则删除下一行）
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
