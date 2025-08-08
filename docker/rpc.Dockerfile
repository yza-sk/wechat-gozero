FROM golang:1.24-alpine AS builder
# 安装依赖工具
RUN apk update --no-cache && \
    apk add --no-cache tzdata git
# 接收模块路径参数（如app/user/rpc）
ARG FULL_MODULE_PATH
# 接收配置文件名
ARG YAML_NAME
# 国内代理配置
ENV GOPROXY=https://goproxy.cn,https://mirrors.aliyun.com/goproxy/,direct
ENV GOSUMDB=sum.golang.google.cn
# 设置容器内代码根目录
WORKDIR /app
# 复制项目所有代码到容器内
COPY . .
# 下载依赖
RUN go mod download
# 进入具体模块目录构建
WORKDIR /app/app/${FULL_MODULE_PATH}
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/rpc .

# 运行阶段
FROM alpine:latest
# 新增非root用户（安全性优化）
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# 接收模块路径参数（如app/user/api）
ARG FULL_MODULE_PATH
# 接收配置文件名
ARG YAML_NAME

# 配置时区
COPY --from=builder /usr/share/zoneinfo/Asia/Shanghai /usr/share/zoneinfo/Asia/Shanghai
ENV TZ=Asia/Shanghai
WORKDIR /app
# 复制配置文件和可执行文件
COPY --from=builder /app/app/${FULL_MODULE_PATH}/etc /app/etc
COPY --from=builder /app/rpc .
# 暴露服务端口（RPC服务通用端口）
EXPOSE 8080
# 启动命令（指定对应配置文件）
CMD ["./rpc", "-f", "etc/${YAML_NAME}"]