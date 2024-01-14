#!/bin/bash

# 设置目录为当前脚本的目录
directory="$(dirname "$0")"

# 获取目录下所有以 "out" 开头的文件
files=("$directory"/out*)

# 如果没有文件，给出提示并退出
if [ ${#files[@]} -eq 0 ]; then
    echo "No 'out' files found in the directory. Exiting."
    exit 1
fi

# 显示第一个文件的内容
echo "Content of ${files[0]}:"
cat "${files[0]}"

# 显示文件列表和第二行内容
echo -e "\nAvailable files:"

for ((i=0; i<${#files[@]}; i++)); do
    content=$(sed -n '2p' "${files[$i]}")  # 获取第二行内容
    echo "$((i+1)): ${files[$i]} \"$content\""
done

# 循环提示用户输入
while true; do
    # 提示用户输入要查看的文件编号或回车退出
    read -p $'\nEnter the number of the file you want to view, or press Enter to quit: ' selection

    # 检查用户是否输入编号
    if [ -z "$selection" ]; then
        echo "Exiting the script."
        exit 0
    fi

    # 检查用户输入的编号是否有效
    if [ "$selection" -ge 1 ] && [ "$selection" -le ${#files[@]} ]; then
        selected_file="${files[$((selection-1))]}"
        echo "Content of ${selected_file}:"
        cat "$selected_file"
    else
        echo "Invalid selection. Please enter a valid file number or press Enter to quit."
    fi
done
