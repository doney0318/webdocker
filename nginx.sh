#!/bin/bash                                                                                               
#===================================================================#
#   System Required:  CentOS 7                                      #
#===================================================================#
#
#一键脚本
#
# 设置字体颜色函数
function blue(){
    echo -e "\033[34m\033[01m $1 \033[0m"
}
function green(){
    echo -e "\033[32m\033[01m $1 \033[0m"
}
function greenbg(){
    echo -e "\033[43;42m\033[01m $1 \033[0m"
}
function red(){
    echo -e "\033[31m\033[01m $1 \033[0m"
}
function redbg(){
    echo -e "\033[37;41m\033[01m $1 \033[0m"
}
function yellow(){
    echo -e "\033[33m\033[01m $1 \033[0m"
}
function white(){
    echo -e "\033[37m\033[01m $1 \033[0m"
}
#            
# @安装docker
install_docker() {
    docker version > /dev/null || curl -fsSL get.docker.com | bash 
    service docker restart 
    systemctl enable docker  
}
install_docker_compose() {
	curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
}


# 单独检测docker是否安装，否则执行安装docker。
check_docker() {
	if [ -x "$(command -v docker)" ]; then
		echo "docker is installed"
		# command
	else
		echo "Install docker"
		# command
		install_docker
	fi
}
check_docker_compose() {
	if [ -x "$(command -v docker-compose)" ]; then
		echo "docker-compose is installed"
		# command
	else
		echo "Install docker-compose"
		# command
		install_docker_compose
	fi
}
# check docker


# 以上步骤完成基础环境配置。
echo "恭喜，您已完成基础环境安装，可执行安装程序。"

restart_nginx(){
    cd /opt/nginx
    docker-compose restart
}



# 输出结果
notice2(){
    greenbg "初始化管理员"
    green "=================================================="
    green "搭建成功，现在您可以直接访问了"
    green "---------------------------"
    green " 首页地址： http://ip:$port"
    green " 后台地址：http://ip:$port/"
    green " 网页数据位置： /opt/nginx/www"
    green "---------------------------"
    white "其他信息"
    white "已配置的端口：$port  数据库root密码：$rootpwd "
    green "=================================================="
}

notice3(){
    green "=================================================="
    green "搭建成功，现在您可以直接访问了"
    green "---------------------------"
    green " 首页地址： http://ip:$port"
    green " 主机数据绝对路径： /opt/nginx"
    green "---------------------------"
    white "其他信息"
    white "已配置的端口：$port  数据库root密码：$rootpwd "
    white "phpMyAdmin: http://ip:8080"
    white "phpRedisAdmin: http://ip:8081"
    green "=================================================="
}
# 环境配置
config_nginx(){
    blue "获取配置文件"
    mkdir -p /opt/nginx && cd /opt/nginx
    yum install git -y
    git clone https://github.com/doney0318/dnmp.git
    mv dnmp/* .
    rm -rf dnmp
    blue "配置文件获取成功"
    sleep 2s
    white "请仔细填写参数，部署完毕会反馈已填写信息"
    green "访问端口：如果想通过域名访问，请设置80端口，其余端口可随意设置"
    read -e -p "请输入访问端口(默认端口80)：" port
    [[ -z "${port}" ]] && port="80"
    green "设置数据库ROOT密码"
    read -e -p "请输入ROOT密码(默认123456)：" rootpwd
    [[ -z "${rootpwd}" ]] && rootpwd="123456"
    green "环境配置中"
    cp env.sample .env
    cp docker-compose-sample.yml docker-compose.yml
    sed -i "s/NGINX_HTTP_HOST_PORT=80/NGINX_HTTP_HOST_PORT=$port/g" /opt/nginx/.env
    sed -i "s/MYSQL_ROOT_PASSWORD=123456/MYSQL_ROOT_PASSWORD=$rootpwd/g" /opt/nginx/.env
    green "已完成配置部署"
}

# 程序安装
install_main(){ 
   envpath = "/opt/nginx"
   if [[  -d "${envpath}" ]]; then
     white "配置文件已存在"
   else 
     white "配置文件不存在"
     blue "获取配置文件"
     mkdir -p /opt/nginx && cd /opt/nginx
     yum install git -y
     git clone https://github.com/doney0318/dnmp.git
     mv dnmp/* .
     rm -rf dnmp
     blue "配置文件获取成功"
     sleep 2s
     white "请仔细填写参数，部署完毕会反馈已填写信息"
     green "访问端口：如果想通过域名访问，请设置80端口，其余端口可随意设置"
     read -e -p "请输入访问端口(默认端口80)：" port
     [[ -z "${port}" ]] && port="80"
     green "设置数据库ROOT密码"
     read -e -p "请输入ROOT密码(默认123456)：" rootpwd
     [[ -z "${rootpwd}" ]] && rootpwd="123456"
     green "环境配置中"
     cp env.sample .env
     cp docker-compose-sample.yml docker-compose.yml
     sed -i "s/NGINX_HTTP_HOST_PORT=80/NGINX_HTTP_HOST_PORT=$port/g" /opt/nginx/.env
     sed -i "s/MYSQL_ROOT_PASSWORD=123456/MYSQL_ROOT_PASSWORD=$rootpwd/g" /opt/nginx/.env
     green "已完成配置部署"
   fi
   green "程序将下载镜像，请耐心等待下载完成"
   green "首次启动会拉取镜像，国内速度比较慢，请耐心等待完成"
   docker-compose up -d
   notice3
}

# 项目加载
nginx_master(){
    green "请选择需要安装的项目"
    yellow "1.[nginx1](项目一)"
    yellow "2.[nginx2](项目二)"
    read -e -p "请输入数字[1~2](默认1)：" vnum
    [[ -z "${vnum}" ]] && vnum="1" 
	if [[ "${vnum}" == "1" ]]; then
        white "开始加载项目一"
	white "施工中"
        elif [[ "${vnum}" == "2" ]]; then
        white "开始加载项目二"
	white "施工中"
	fi  
    redbg "拉取镜像中，请耐心等待"
}



# 停止服务
stop_nginx(){
    cd /opt/nginx
    docker-compose kill
}

# 重启服务
restart_nginx(){
    cd /opt/nginx
    docker-compose restart
}

# 卸载
remove_all(){
    cd /opt/nginx
    docker-compose down
    echo -e "\033[32m已完成卸载\033[0m"
}



#开始菜单
start_menu(){
    clear
    echo ""
    greenbg "==============================================================="
    greenbg "简介：网站一键安装脚本"
    greenbg "系统：Centos7"
    greenbg "==============================================================="
    echo
    white "—————————————环境设置——————————————"
    white "1.环境设置"
    white "—————————————程序安装——————————————"
    white "2.安装nginx"
    white "—————————————项目加载——————————————"
    white "3.项目加载"
    white "—————————————杂项管理——————————————"
    white "4.停止nginx"
    white "5.重启nginx"
    white "6.卸载nginx"
    white "7.清除本地缓存（仅限卸载后操作）"
    blue "0.退出脚本"
    echo
    read -p "请输入数字:" num
    case "$num" in
    	1)
    config_nginx
    green "环境参数设置完毕"
    	;;
        2)
    check_docker
    check_docker_compose
    install_main
	;;
        3)
    nginx_master
	;;
	4)
    stop_nginx
    green "程序已停止运行"
	;;
	5)
    restart_nginx
    green "程序已重启完毕"
	;;
	6)
    remove_all
	;;
	7)
    rm -fr /opt/nginx
    green "清除完毕"
	;;    
	0)
	exit 1
	;;
	*)
	clear
	echo "请输入正确数字"
	sleep 5s
	start_menu
	;;
    esac
}

start_menu
