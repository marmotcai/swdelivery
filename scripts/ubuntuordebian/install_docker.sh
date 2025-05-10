#!/bin/bash
# 检查是否传入了参数
if [ -z "$1" ]; then
    echo "错误：请提供安装目录作为参数。"
    echo "使用方法：$0 <安装目录>"
    exit 1
fi
# 获取传入的安装目录
INSTALL_DIR=$1
# 切换到指定目录
cd "$INSTALL_DIR" || {
    echo "错误：无法切换到目录 $INSTALL_DIR"
    exit 1
}
# 安装所有 .rpm 包，忽略依赖关系并强制安装
rpm -ivh *.rpm --force --nodeps
# 检查安装是否成功
if [ $? -eq 0 ]; then
    echo "Docker 安装成功！"
else
    echo "Docker 安装失败，请检查错误信息。"
fi

# 安装docker-compose
cp docker-compose /usr/bin/

# 设置docker-compose的权限
chmod +x /usr/bin/docker-compose

# 检查docker和docker-compose是否安装成功
if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    echo "Docker 和 Docker Compose 安装成功！"
else
    echo "Docker 或 Docker Compose 安装失败，请检查错误信息。"
fi