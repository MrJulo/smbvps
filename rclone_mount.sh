#!/bin/bash

fixed_path="/var/lib/transmission-daemon/downloads/"
fixed_options="--allow-other --vfs-cache-mode writes --vfs-cache-max-size 1G --buffer-size 32M --umask 000"
services=("disk-m" "disk1" "disk2" "disk3" "disk4" "disk5")
for service in "${services[@]}"; do
    if [ -d "$fixed_path$service" ]; then
       echo "$fixed_path$service已存在，无需创建"
    else
       echo "已创建$fixed_path$service文件夹"
       mkdir "$fixed_path$service"
    fi    
done
while true; do
    # 列出每个服务的状态
    echo "当前 rclone mount 服务状态:"
    for service in "${services[@]}"; do
        service_name="$service"
        status=$(sudo systemctl is-active "$service_name.service")
        if [[ $status = "active" ]]; then
            echo -e "\e[1m$service_name 服务状态: $status \e[0m"
        else
            echo -e "\e[1;31m$service_name \e[0m\e[1m服务状态: \e[0m\e[1;31m$status \e[0m"
        fi
    done
    # 我们加上字体颜色显示
    echo -e "\e[1;36m1. 安装 rclone mount 服务\e[0m"
    echo -e "\e[1;33m2. 删除 rclone mount 服务\e[0m"
    echo -e "\e[1m3. 启动 rclone mount 服务\e[0m"
    echo -e "\e[1;31m4. 停止 rclone mount 服务\e[0m"
    echo -e "\e[1m5. 退出脚本\e[0m"
    read -p "请选择操作 [1-5]: " choice

    case $choice in
        1)
             # 安装服务
            read -p $'请输入要安装的 rclone mount 服务 \n[disk-main=0,disk-1=1,disk-2=2,disk-3=3,disk-4=4,disk-5=5,]\n或输入 6 安装所有服务: ' install_choice

            if [ "$install_choice" -eq 6 ]; then
            echo "安装并启动所有 rclone mount 服务:"
            for service in "${services[@]}"; do
                service_file="/etc/systemd/system/$service.service"

                cat > "$service_file" <<EOF
[Unit]
Description=Rclone Mount for $service
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount $service:/ $fixed_path$service/ $fixed_options
ExecStop=fusermount -qzu /$service
[Install]
WantedBy=default.target
EOF

                sudo systemctl daemon-reload
                sudo systemctl enable "$service.service"
                sudo systemctl start "$service.service"
            done

            echo "所有 rclone mount 服务已安装并启动"
            elif [ "$install_choice" -ge 0 ] && [ "$install_choice" -le 5 ]; then
                service_name="${services[$install_choice]}"
                service_file="/etc/systemd/system/$service_name.service"

                cat > "$service_file" <<EOF
[Unit]
Description=Rclone Mount for $service_name
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount $service_name:/ $fixed_path$service_name/ $fixed_options
ExecStop=fusermount -qzu /$service_name
[Install]
WantedBy=default.target
EOF

                sudo systemctl daemon-reload
                sudo systemctl enable "$service_name.service"
                sudo systemctl start "$service_name.service"
                echo "$service_name已安装"
            else
                echo "无效的选择,请重新输入"
            fi
            ;;
        2)
            # 删除服务
            read -p $'请输入要删除的 rclone mount 服务 \n[disk-main=0,disk-1=1,disk-2=2,disk-3=3,disk-4=4,disk-5=5,]\n或输入 6 删除所有服务: ' del_choice

            if [ "$del_choice" -eq 6 ]; then
            # 停止并删除所有服务
            echo "停止并删除所有 rclone mount 服务:"
            for service in "${services[@]}"; do
                service_name="$service"
                sudo systemctl stop "$service_name.service"
                sudo rm "/etc/systemd/system/$service_name.service"
            done
            echo "所有 rclone mount 服务已停止并删除"
            elif [ "$del_choice" -ge 0 ] && [ "$del_choice" -le 5 ]; then
                service_name="${services[$del_choice]}"
                sudo systemctl stop "$service_name.service"
                sudo rm "/etc/systemd/system/$service_name.service"
                echo "$service_name已删除"
            else
                echo "无效的选择,请重新输入"
            fi
            ;;
        3)
            # 启动服务
            read -p $'请输入要启动的 rclone mount 服务 \n[disk-main=0,disk-1=1,disk-2=2,disk-3=3,disk-4=4,disk-5=5,]\n或输入 6 启动所有服务: ' start_choice

            if [ "$start_choice" -eq 6 ]; then
                for service in "${services[@]}"; do
                    service_name="$service"
                    sudo systemctl start "$service_name.service"
                done
            elif [ "$start_choice" -ge 0 ] && [ "$start_choice" -le 5 ]; then
                service_name="${services[$start_choice]}"
                sudo systemctl start "$service_name.service"
            else
                echo "无效的选择,请重新输入"
            fi
            ;;
        4)
            # 停止服务
            read -p $'请输入要停止的 rclone mount 服务 \n[disk-main=0,disk-1=1,disk-2=2,disk-3=3,disk-4=4,disk-5=5,]\n或输入 6 停止所有服务: ' stop_choice

            if [ "$stop_choice" -eq 6 ]; then
                for service in "${services[@]}"; do
                    service_name="$service"
                    sudo systemctl stop "$service_name.service"
                done
            elif [ "$stop_choice" -ge 0 ] && [ "$stop_choice" -le 5 ]; then
                service_name="${services[$stop_choice]}"
                sudo systemctl stop "$service_name.service"
            else
                echo "无效的选择,请重新输入"
            fi
            ;;
        5)
            # 退出脚本
            echo "退出脚本"
            exit 0
            ;;
        *)
            # 无效的选择
            echo "无效的选择,请重新输入"
            ;;
    esac
done
