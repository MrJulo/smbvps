#!/bin/bash

# 设置源目录
source_directory="/var/lib/transmission-daemon/downloads"

# 提示用户输入退出字符
read -p "Enter the exit character (e.g., 'q' to quit): " exit_character

while true; do
    # 显示源目录的文件和文件夹，并标上号
    echo "Files and folders in $source_directory:"
    index=1
    for entry in "$source_directory"/*; do
        echo "$index: $(basename "$entry")"
        ((index++))
    done

    # 提示用户输入要移动的项目的编号或退出字符
    read -p "Enter the number of the item you want to move or '$exit_character' to quit: " selection

    # 检查用户是否输入退出字符
    if [ "$selection" == "$exit_character" ]; then
        echo "Exiting the script."
        exit 0
    fi

    # 获取用户选择对应的文件或文件夹
    selected_item=$(ls -A "$source_directory" | sed -n "${selection}p")

    # 提示用户输入目标文件夹名称
    read -p "Enter the name of destination folder: " destination_folder_name

    # 设置目标目录
    destination_directory="$source_directory/$destination_folder_name"

    # 检查目标目录是否存在，不存在则创建
    if [ ! -d "$destination_directory" ]; then
        mkdir -p "$destination_directory"
    fi

    # 移动文件或文件夹到目标目录，显示进度条
    nohup bash -c "rsync -ah --progress --remove-source-files \"$source_directory/$selected_item\" \"$destination_directory\" && echo 'Item moved successfully to $destination_folder_name!'" > "out_$destination_folder_name" 2>&1 &
done
