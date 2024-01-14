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

# 指定要排除的文件夹名称
exclude_folders=("disk-m" "disk1" "disk2" "disk3" "disk4" "disk5" "上传文件" "uploads")

counter=1

while true; do
    # 显示源目录的文件和文件夹，并标上号，排除指定的文件夹
    echo "源目录中的文件和文件夹:"
    files=("$source_directory"/*)
    index=1
    index_array=()  # 用于存储列表出来的文件的索引
    for entry in "${files[@]}"; do
        # 获取文件或文件夹名称
        filename=$(basename "$entry")
        
        # 检查是否在排除列表中
        if [[ ! " ${exclude_folders[@]} " =~ " $filename " ]]; then
            echo "$index: $filename"
            index_array+=("$index")  # 将索引添加到数组中
            ((index++))
        fi
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
        if [ "$selection" -ge 1 ] && [ "$selection" -le ${#index_array[@]} ]; then
            # 获取用户选择对应的文件或文件夹
            selected_index=${index_array[$((selection-1))]}
            selected_item=$(basename "${files[$((selected_index-1))]}")
            echo "正在移动文件: $selected_item"

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
