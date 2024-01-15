#!/bin/bash

# 提示用户选择源路径
echo "选择源路径:"
paths=("/var/lib/transmission-daemon/downloads/disk-m" "/var/lib/transmission-daemon/downloads/disk1" "/var/lib/transmission-daemon/downloads/disk2" "/var/lib/transmission-daemon/downloads/disk3" "/var/lib/transmission-daemon/downloads/disk4" "/var/lib/transmission-daemon/downloads/disk5")

for i in "${!paths[@]}"; do
    echo "$i: ${paths[$i]}"
done

while true; do
    read -p "输入源路径的编号: " source_index

    # 检查用户输入的编号是否有效
    if [[ "$source_index" =~ ^[0-9]+$ ]] && [ "$source_index" -ge 0 ] && [ "$source_index" -lt ${#paths[@]} ]; then
        source_path="${paths[$source_index]}"
        break
    elif [ -z "$source_index" ]; then
        echo "退出脚本。"
        exit 0
    else
        echo "无效的源路径编号，请重新输入。"
    fi
done

# 提示用户选择目标路径
echo "选择目标路径:"
for i in "${!paths[@]}"; do
    # 排除源路径，避免目标路径与源路径相同
    if [ "$i" -ne "$source_index" ]; then
        echo "$i: ${paths[$i]}"
    fi
done

while true; do
    read -p "输入目标路径的编号: " destination_index

    # 检查用户输入的编号是否有效
    if [[ "$destination_index" =~ ^[0-9]+$ ]] && [ "$destination_index" -ge 0 ] && [ "$destination_index" -lt ${#paths[@]} ] && [ "$destination_index" -ne "$source_index" ]; then
        destination_path="${paths[$destination_index]}"
        break
    elif [ -z "$destination_index" ]; then
        echo "退出脚本。"
        exit 0
    else
        echo "无效的目标路径编号，请重新输入。"
    fi
done

counter=1

while true; do
    # 列出源路径下的文件和文件夹，并标上序号
    echo "源路径中的文件和文件夹:"
    files=("$source_path"/*)
    index=1
    for entry in "${files[@]}"; do
        filename=$(basename "$entry")
        echo "$index: $filename"
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
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#files[@]} ]; then
        selected_index=$((selection - 1))
        selected_item=$(basename "${files[$selected_index]}")

        # 使用rclone move命令移动文件夹，保持文件夹结构
        nohup rclone move "$source_path/$selected_item" "$destination_path/$selected_item" --progress --quiet > "outp$counter" 2>&1 &
        echo "正在移动文件 $selected_item，请查看 outp$counter 文件以获取详细信息。"
        ((counter++))
    else
        echo "无效的选择，请输入有效的文件编号。"
    fi
done
