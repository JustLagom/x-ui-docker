# 使用轻量级 Alpine 基础镜像
FROM alpine:latest

# 定义目标架构参数，由 GitHub Actions 传入
ARG TARGETARCH

# 安装必要的工具，特别是 bash 和 curl，用于确保脚本兼容性
RUN apk update && apk add --no-cache net-tools curl bash

# 设定 X-UI 程序的安装路径
WORKDIR /usr/local/x-ui

# 1. 复制所有文件到工作目录
COPY . .

# 2. 核心修正：根据 TARGETARCH 变量，选择并重命名正确的二进制文件为 'x-ui'
#    如果缺少对应的文件，mv 命令将失败，导致构建退出并报错
RUN echo "Target Architecture is: $TARGETARCH" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        echo "Renaming xuiwpph_amd64 to x-ui..."; \
        mv xuiwpph_amd64 x-ui; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        echo "Renaming xuiwpph_arm64 to x-ui..."; \
        mv xuiwpph_arm64 x-ui; \
    else \
        # 如果架构不是 amd64 或 arm64，则失败
        echo "Error: Unsupported architecture or missing binary. TARGETARCH=$TARGETARCH"; exit 1; \
    fi

# 3. 赋予可执行权限 (针对统一命名后的 x-ui 文件)
RUN chmod +x x-ui

# 设置数据库文件路径，方便外部挂载实现数据持久化
ENV XUI_DB_FILE="/etc/x-ui/x-ui.db"
RUN mkdir -p /etc/x-ui

# X-UI 面板默认端口
EXPOSE 54321

# 容器启动时运行 X-UI
ENTRYPOINT ["/usr/local/x-ui/x-ui"]
CMD ["start"]
