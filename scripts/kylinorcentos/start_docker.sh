#!/bin/bash
# 检查是否传入了参数
if [ -z "$1" ]; then
    echo "错误：请提供安装目录作为参数。"
    echo "使用方法：$0 <安装目录>"
    exit 1
fi

# 获取传入的安装目录
docker_tar_dir=$1

docker_reload(){
json="{
   \"registry-mirrors\": [\"https://geuj9lut.mirror.aliyuncs.com\"],
    \"log-driver\": \"json-file\",
    \"log-opts\": {
       \"max-size\": \"100m\"
    },
    \"exec-opts\": [\"native.cgroupdriver=systemd\"],
    \"storage-driver\": \"overlay2\",
    \"insecure-registries\": [
        \"${domain}\",
	      \"ss.suwell.com\"
  ]
 }
"
echo "$json" > /etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker

}
docker_reload_set(){
  [ -f /etc/docker/daemon.json ] || touch /etc/docker/daemon.json
  local num=`grep ${domain} /etc/docker/daemon.json|wc -l`
  if [ $num -eq 0 ];then 
     docker_reload
  fi
}

off_line_install_docker(){
  if [ -d ${docker_tar_dir} ];then
    cd ${docker_tar_dir}
    info "start install docker"
    cp -ar docker/docker/* /usr/bin
    cp -ar containerd.service docker.service  docker.socket /usr/lib/systemd/system
    groupadd  docker
    systemctl daemon-reload
    systemctl enable containerd.service
    systemctl enable docker.socket
    systemctl enable docker.service
    systemctl start containerd.service
    systemctl start docker.socket
    systemctl start docker.service
       [ $? -eq 0 ] && info7 "docker安装成功"
  else
      info8 "${docker_tar_dir} 不存在,请检查后重试!!!"
      mkdir -p ${docker_tar_dir}
      exit 0
  fi
    #开启路由转发
 cat >>/etc/sysctl.conf<<EOF
 net.ipv4.ip_forward = 1
EOF
   sysctl -p  &>/dev/null

 #添加阿里云镜像加速器
 mkdir -p /etc/docker
 #tee /etc/docker/daemon.json <<-'EOF'
 #{
 #  "registry-mirrors": ["https://geuj9lut.mirror.aliyuncs.com"],
 #  "exec-opts": ["native.cgroupdriver=systemd"]
 #}
 #EOF
 docker_reload_set

}


#安装docker是的帮助信息
install_docker_help(){
   info8 "离线安装docker时,需要提前准备好对应的RPM的安装包,且需要存放在$docker_tar_dir"
   info8 "相应的配置可根据屏幕打印的提示继续即可"
}

#启动docker
start_docker(){
 if [ `ls /usr/bin|grep docker |wc -l` -eq 0 ];then
      off_line_install_docker
      systemctl restart docker
      systemctl enable docker >/dev/null
  else
     a=`rpm -qa|grep docker-ce|tail -1`
     info8 "\033[32m ${a}已安装，不需要重新部署\033[0m"
     local docker_status=`systemctl  status docker |grep Active|awk '{print $2}'`
       if [ ! ${docker_status} == "active" ];then
           systemctl start docker
           info8 "\033[32m docker服务已重新正常启动\033[0m"
       else
           info8 "\033[32m docker服务已正常启动!!!\033[0m"
      fi    
 fi
}