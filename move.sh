#!/bin/bash

# 检查是否提供了目标文件夹名称参数
if [ "$#" -ne 1 ]; then
    echo "用法: $0 <目标文件夹名称>"
    exit 1
fi

# 设置源目录和目标目录
source_directory="/var/lib/transmission-daemon/downloads"
destination_folder_name="$1"
destination_directory="$source_directory/$destination_folder_name"

# 检查目标目录是否存在，不存在则创建
if [ ! -d "$destination_directory" ]; then
    mkdir -p "$destination_directory"
fi

counter=1

while true; do
    # 显示源目录的文件和文件夹，并标上号
    echo "源目录中的文件和文件夹:"
    index=1
    for entry in "$source_directory"/*; do
        echo "$index: $(basename "$entry")"
        ((index++))
    done

    # 提示用户输入要移动的项目的编号
    read -p "输入要移动的项目的编号，或按回车退出: " selection

    # 检查用户是否按回车
    if [ -z "$selection" ]; then
        echo "退出脚本。"
        exit 0
    fi

    # 检查用户输入的编号是否为数字
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        # 检查用户输入的编号是否在文件夹数目的范围内
        if [ "$selection" -ge 1 ] && [ "$selection" -le ${#files[@]} ]; then
            # 获取用户选择对应的文件或文件夹
            selected_item=$(ls -A "$source_directory" | sed -n "${selection}p")

            # 移动文件或文件夹到目标目录，显示进度条
            nohup bash -c "rsync -ah --progress --remove-source-files \"$source_directory/$selected_item\" \"$destination_directory\" && echo '项目成功移动到 $destination_folder_name!'"> "out$counter" 2>&1 &
            ((counter++))
        else
            echo "无效的选择，请输入有效的文件编号。"
        fi
    else
        echo "无效的输入，请输入有效的文件编号。"
    fi
done
