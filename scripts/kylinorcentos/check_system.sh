#!/bin/bash

# 定义颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # 恢复默认颜色

# 打印分割线
print_divider() {
    echo "----------------------------------------"
}

# 检查系统内核版本
print_divider
echo -e "${YELLOW}系统内核版本：${NC}"
uname -r


# 检查 firewalld 是否关闭
print_divider
if systemctl is-active --quiet firewalld; then
    echo -e "${YELLOW}firewalld 正在运行，请关闭它，关闭方法：${NC}"
    echo "systemctl stop firewalld"
    echo "systemctl disable firewalld"
else
    echo -e "${GREEN}firewalld 已关闭。OK${NC}"
fi

# 检查 setenforce 是否关闭
print_divider
if getenforce | grep -q "Enforcing"; then
    echo -e "${YELLOW}SELinux 处于强制模式，请关闭它，关闭方法：${NC}"
    echo "setenforce 0"
    echo "要永久关闭 SELinux，请编辑 /etc/selinux/config 文件，将 SELINUX=enforcing 改为 SELINUX=permissive 或 SELINUX=disabled，然后重启系统。"
else
    echo -e "${GREEN}SELinux 已关闭。OK${NC}"
fi

# 检查 podman 是否卸载
print_divider
if rpm -q podman &> /dev/null; then
    echo -e "${YELLOW}系统自带的 podman 已安装，请卸载它，卸载方法：${NC}"
    echo "yum remove -y podman"
else
    echo -e "${GREEN}系统自带的 podman 已卸载。OK${NC}"
fi

# 检查 CPU 核数
print_divider
cpu_cores=$(nproc)
echo "CPU 核数: $cpu_cores"
if [ "$cpu_cores" -lt 8 ]; then
    echo -e "${RED}警告: CPU 核数低于 8 核，建议升级硬件！${NC}"
else
    echo -e "${GREEN}CPU 核数满足要求。OK${NC}"
fi

# 检查内存大小
print_divider
total_memory=$(free -g | awk '/^Mem:/{print $2}')
echo "系统内存大小: ${total_memory}GB"
if [ "$total_memory" -lt 16 ]; then
    echo -e "${RED}警告: 内存大小低于 16GB，建议升级硬件！${NC}"
else
    echo -e "${GREEN}内存大小满足要求。OK${NC}"
fi

# 检查磁盘容量
print_divider
disk_capacity=$(df -h --output=size / | tail -n 1 | tr -d ' ')
disk_capacity_gb=$(df -BG / | tail -n 1 | awk '{print $2}' | tr -d 'G')
echo "磁盘容量: $disk_capacity"
if [ "$disk_capacity_gb" -lt 500 ]; then
    echo -e "${RED}警告: 磁盘容量低于 500GB，建议升级硬件！${NC}"
else
    echo -e "${GREEN}磁盘容量满足要求。OK${NC}"
fi

# 结束分割线
print_divider
