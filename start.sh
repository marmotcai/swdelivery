
#!/bin/bash

# 调试模式开关，默认关闭
DEBUG_MODE=true

if [ -z "${MAIN_DIR}" ]; then
  export MAIN_DIR=$( dirname `readlink -f  $0`)
fi

if [ -z "${PLAYBOOK_DIR}" ]; then
  export PLAYBOOK_DIR=${MAIN_DIR}/playbook
fi

if [ -z "${SCRIPTS_DIR}" ]; then
  export SCRIPTS_DIR=${MAIN_DIR}/scripts
fi

########################################################################
YELLOW='\033[0;33m'
NC='\033[0m'
echo -e "${YELLOW} ---------------------------------------------------------------------------------------------------${NC}"
echo -e "${YELLOW}  ____                              _   _         ____           _   _                               ${NC}"
echo -e "${YELLOW} / ___|   _   _  __      __   ___  | | | |       |  _ \    ___  | | (_) __   __   ___   _ __   _   _ ${NC}"
echo -e "${YELLOW} \___ \  | | | | \ \ /\ / /  / _ \ | | | |       | | | |  / _ \ | | | | \ \ / /  / _ \ | '__| | | | |${NC}"
echo -e "${YELLOW}  ___) | | |_| |  \ V  V /  |  __/ | | | |       | |_| | |  __/ | | | |  \ V /  |  __/ | |    | |_| |${NC}"
echo -e "${YELLOW} |____/   \__,_|   \_/\_/    \___| |_| |_|       |____/   \___| |_| |_|   \_/    \___| |_|     \__, |${NC}"
echo -e "${YELLOW}                                                                                               |___/  ${NC}"  
echo -e "${YELLOW} ---------------------------------------------------------------------------------------------------${NC}"

########################################################################

source ${SCRIPTS_DIR}/getos.sh
SCRIPTS_OS_DIR=${SCRIPTS_DIR}/${OS}

if [ "${DEBUG_MODE}" == "true" ]; then
  bash ${SCRIPTS_DIR}/color.sh blue "当前系统：${OS}"
  bash ${SCRIPTS_DIR}/color.sh blue "当前运行目录：${MAIN_DIR}"
  bash ${SCRIPTS_DIR}/color.sh blue "当前脚本路径：${SCRIPTS_DIR}"
  bash ${SCRIPTS_DIR}/color.sh blue "当前系统脚本路径：${SCRIPTS_OS_DIR}"
fi


########################################################################
# 定义帮助信息函数
print_help() {
  echo "使用方法: $0 [-1] [-s [check|docker]] [-u]"
  echo "选项："
  echo "  -m    菜单选择"
  echo "  -1    一键安装"
  echo "  -s    单步运行"
  echo "        - check: 系统检测"
  echo "        - docker: 部署docker"
  echo "  -u    卸载"
  exit 1
}
# 如果没有参数传入，则默认进入菜单模式
if [ $# -eq 0 ]; then
  set -- "-m"
fi

while getopts "mos:uh" opt; do
  case $opt in
  m)
    while : ;do
      source ${SCRIPTS_DIR}/color.sh green "请选择(1: 环境检查, 2: 推送镜像, 3: 运行实例, 任意键: 退出):"

      read WANT_TO_DO

      case $WANT_TO_DO in
          #########################################################################
          1) # 环境检查
            build_cmd="bash start.sh -s check"
            echo ${build_cmd}
            ( ${build_cmd} )
          ;;

          #########################################################################
          2) # 推送镜像
            tag_cmd="docker tag ${SLINES_IMAGE_NAME}:${TAGET} ${SLINES_IMAGE_REGISTRY_NAME}:${TAGET}"
            echo ${tag_cmd}
            push_cmd="docker push ${SLINES_IMAGE_REGISTRY_NAME}:${TAGET}"
            echo ${push_cmd}
            ( ${tag_cmd} && ${push_cmd} )
          ;;

          3) # 运行实例
            DOCKERCOMPOSE_PATH="${PROPATH}/docker-compose.yml"
            if [ -f ${DOCKERCOMPOSE_PATH} ]; then
              run_cmd="docker-compose -f  ${DOCKERCOMPOSE_PATH} --project-directory ${PROPATH} up -d ${TAGET}"
              bash ${SCRIPTS_DIR}/color.sh blue ${run_cmd}
              ${run_cmd}
            fi
          ;;

          *)
            exit 0
          ;;
          esac
    done
    ;;
  o)
    ;;
  s)
    action="$OPTARG"

    case "$action" in
      check)
        build_cmd="bash ${SCRIPTS_OS_DIR}/check_system.sh"
        echo ${build_cmd}
        ( ${build_cmd} )
        ;;
      *)
        echo "未知的操作: $action"
        print_help
        ;;
    esac
    ;;
  u)
    ;;
  h)
    print_help
    ;;

  \?)
    echo "错误: 无效的选项 -$OPTARG" >&2
    print_help
    ;;
  esac
done

exit 0

########################################################################

TAGET=${1}
PROPATH=${2}

if [ ${PROPATH}x == "x" ]; then
  PROPATH="."
fi

echo "exit"
exit 0; 