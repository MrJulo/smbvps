#!/bin/bash

# 显示可选目标目录
echo "可选目标目录:"
options=("disk1" "disk2" "disk3" "disk4" "disk5" "disk-m")
PS3="选择一个目标目录编号: "

select target_directory in "${options[@]}"; do
    if [[ -n "$target_directory" ]]; then
        break
    else
        echo "退出脚本。"
        exit 0
    fi
done

# 设置源目录和目标目录
source_directory="/var/lib/transmission-daemon/downloads"
destination_directory="$source_directory/$target_directory"

# 检查目标目录是否存在，不存在则创建
if [ ! -d "$destination_directory" ]; then
    mkdir -p "$destination_directory"
fi

echo "目标目录已设置为: $destination_directory"

# 指定要排除的文件夹名称
exclude_folders=("disk-m" "disk1" "disk2" "disk3" "disk4" "disk5" "上传文件" "uploads")

counter=1

while true; do
    # 显示源目录的文件和文件夹，并标上号，排除指定的文件夹
    echo "源目录中的文件和文件夹:"
    files=("$source_directory"/*)
    valid_folders=()  # 存储没有被排除的文件夹
    index=1
    for entry in "${files[@]}"; do
        # 获取文件或文件夹名称
        filename=$(basename "$entry")
        
        # 检查是否在排除列表中
        if [[ ! " ${exclude_folders[@]} " =~ " $filename " ]]; then
            echo "$index: $filename"
            valid_folders+=("$entry")  # 将没有被排除的文件夹添加到数组中
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
        if [ "$selection" -ge 1 ] && [ "$selection" -le ${#valid_folders[@]} ]; then
            # 获取用户选择对应的文件或文件夹
            selected_item=$(basename "${valid_folders[$((selection-1))]}")

            # 移动文件或文件夹到目标目录，显示进度条
            echo -e "\e[1;36m正在移动文件: $selected_item\e[0m"
            nohup bash -c "rsync -ah --progress --remove-source-files \"$source_directory/$selected_item\" \"$destination_directory\" && echo -e '\e[1;32m项目成功移动到 $destination_folder_name!\e[0m'" > "out$counter" 2>&1 &
            ((counter++))
        else
            echo "无效的选择，请输入有效的文件编号。"
        fi
    else
        echo "无效的输入，请输入有效的文件编号。"
    fi
done
