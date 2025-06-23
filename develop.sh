# 获取当前 commit ID
GIT_COMMIT=$(git rev-parse --short HEAD)
echo "Git Commit: $GIT_COMMIT"
# 构建镜像（传递 commit ID 作为构建参数）
docker build --build-arg GIT_COMMIT=${GIT_COMMIT} -t my-hello-world:latest .