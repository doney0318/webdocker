#!/bin/bash                                                                                               
#===================================================================#
#   System Required:  CentOS 7                                      #
#===================================================================#
#
#一键脚本
#
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

restart_qiaohu(){
    cd /opt/qiaohu
    docker-compose restart
}



# 输出结果
notice(){
    green "=================================================="
    green "主程序已搭建完毕，让我们来完成最后几步，之后就可以访问了"
    green "=================================================="
    white "以下内容必须一步步操作"
    greenbg "等待数据库完成初始化，等待约10s"
    sleep 12s
    docker exec -it qizhimysql mysql -uroot -p$rootpwd < /tmp/qiaohu.sql
    sleep 10s
    greenbg "正在重启qiaohu"
    restart_qiaohu
    sleep 10s
}

# 开始安装qiaohu
install_main(){
    blue "获取配置文件"
    mkdir -p /opt/qiaohu && cd /opt/
    white "请仔细填写参数，部署完毕会反馈已填写信息"
    green "访问端口：如果想通过域名访问，请设置80端口，其余端口可随意设置"
    read -e -p "请输入访问端口(默认端口80)：" port
    [[ -z "${port}" ]] && port="80"
    green "设置数据库ROOT密码"
    read -e -p "请输入ROOT密码(默认123456)：" rootpwd
    [[ -z "${rootpwd}" ]] && rootpwd="123456"  
    qiaohu_master
    notice  
   
}


# 初始化qiaohu程序
qiaohu_master(){
    rm -rf /opt/qiaohu && cd /opt
    git clone -b master https://git.china-qizhi.com/zhangjian/qiaohu.git
    cd /opt/qiaohu 
    sed -i "s/"8000:80/"$port:80/"  /opt/qiaohu/docker-compose.yml
    sed -i "s/数据库密码/$rootpwd/g"  /opt/qiaohu/docker-compose.yml
    sed -i "s/123456/$rootpwd/g"    /opt/qiaohu/protected/config/dbconfig.php
    greenbg "本地初始化完成"
    cd /opt/qiaohu
    redbg "开始启动服务，首次启动会拉取镜像，请耐心等待"
    docker-compose up -d    
}

# 停止服务
stop_qiaohu(){
    cd /opt/qiaohu
    docker-compose kill
}

# 重启服务
restart_qiaohu(){
    cd /opt/qiaohu
    docker-compose restart
}

# 卸载
remove_all(){
    cd /opt/qiaohu
    docker-compose down
	echo -e "\033[32m已完成卸载\033[0m"
}



#开始菜单
start_menu(){
    clear
	echo ""
    greenbg "==============================================================="
    greenbg "简介：网站一键安装脚本                                          "
    greenbg "系统：Centos7、Ubuntu等                                         "
    greenbg "==============================================================="
    echo
    yellow "使用前提：脚本会自动安装docker，国外服务器搭建只需1min~2min"
    yellow "国内服务器下载镜像稍慢，请耐心等待"
    blue "备注：非80端口可以用caddy反代，自动申请ssl证书，到期自动续期"
    echo
    white "—————————————程序安装——————————————"
    white "1.安装qiaohu"
    white "—————————————杂项管理——————————————"
    white "2.停止qiaohu"
    white "3.重启qiaohu"
    white "4.卸载qiaohu"
    white "5.清除本地缓存（仅限卸载后操作）"
    white "—————————————域名访问——————————————" 
    white "6.Caddy域名反代一键脚本(可以实现非80端口使用域名直接访问)"
    blue "0.退出脚本"
    echo
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
	check_docker
    check_docker_compose
    install_main
	;;
	2)
    stop_qiaohu
    green "qiaohu程序已停止运行"
	;;
	3)
    restart_qiaohu
    green "qiaohu程序已重启完毕"
	;;
	4)
    remove_all
	;;
	5)
    rm -fr /opt/qiaohu
    green "清除完毕"
	;;    
	6)
    bash <(curl -L -s https://raw.githubusercontent.com/doney0318/webdocker/master/caddy.sh)
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
