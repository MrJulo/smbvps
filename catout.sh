#!/bin/bash

# 将目录设置为当前脚本的目录
directory="$(dirname "$0")"

# 获取目录下所有以 "out" 开头的文件
files=("$directory"/out*)

# 如果没有找到文件，则提供提示并退出
if [ ${#files[@]} -eq 0 ]; then
    echo "No 'out' files found in the directory. Exiting."
    exit 1
fi

# 直接显示第一个文件的内容
echo -e "Content of ${files[0]}:"
cat "${files[0]}"

# 显示文件列表和它们的第二行内容
echo -e "\nAvailable files:"

for ((i=0; i<${#files[@]}; i++)); do
    # 获取第二行内容
    content=$(sed -n '2p' "${files[$i]}")
    echo "$((i+1)): ${files[$i]} \"$content\""
done

# 循环提示用户输入
while true; do
    read -p $'\nEnter a file number to display its content, or press Enter to exit: ' input

    # 检查用户是否按回车
    if [ -z "$input" ]; then
        echo "Exiting the script."
        exit 0
    fi

    # 检查输入是否为数字
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        index=$((input-1))
        if [ "$index" -ge 0 ] && [ "$index" -lt ${#files[@]} ]; then
            # 显示所选文件的内容
            echo -e "\nContent of ${files[$index]}:"
            cat "${files[$index]}"
        else
            echo "Invalid file number. Please enter a valid file number."
        fi
    else
        echo "Invalid input. Please enter a valid file number."
    fi
done
