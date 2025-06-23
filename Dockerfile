# 使用官方 Go 轻量级镜像作为构建环境
FROM golang:1.23-alpine AS builder
# 设置工作目录
WORKDIR /app
# 复制 Go 模块文件并下载依赖
COPY go.mod go.sum ./
RUN go mod download
# 复制源代码到容器
COPY . .
# 定义构建参数（接收外部传入的 commit ID）
#ARG GIT_COMMIT

# 将 commit ID 设置为环境变量（构建阶段可用）
#ENV GIT_COMMIT=${GIT_COMMIT}

# 构建应用（在应用中可通过 os.Getenv("GIT_COMMIT") 获取）
#RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-X main.GitCommit=${GIT_COMMIT}" -o /go-app
RUN CGO_ENABLED=0 GOOS=linux go build -o /go-app
# 构建 Go 应用（禁用 CGO 以获得更兼容的二进制文件）
#RUN CGO_ENABLED=0 GOOS=linux go build -o /go-app

# 使用更小的运行时镜像
FROM alpine:latest
# 设置容器时区（可选）
RUN apk add --no-cache tzdata
ENV TZ=Asia/Shanghai
# 定义构建参数（再次声明以在运行时阶段使用）
ARG GIT_COMMIT
# 设置为运行时环境变量
ENV GIT_COMMIT=${GIT_COMMIT}
# 从构建阶段复制可执行文件
COPY --from=builder /go-app /app/go-app
# 暴露应用端口
EXPOSE 8000
# 设置容器启动命令
CMD ["/app/go-app"]
# 复制启动脚本
#COPY entrypoint.sh /app/
# 设置可执行权限
#RUN chmod +x /app/entrypoint.sh
# 设置入口点
#ENTRYPOINT ["/app/entrypoint.sh"]