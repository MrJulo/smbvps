#!/bin/bash

# 设置目录为当前脚本的目录
directory="$(dirname "$0")"

# 获取目录下所有以 "out" 开头的文件
files=("$directory"/out*)

# 如果只有一个文件，直接执行 cat
if [ ${#files[@]} -eq 1 ]; then
    echo "Only one file found. Displaying content of ${files[0]}:"
    cat "${files[0]}"
    exit 0
fi

# 显示文件列表和第二行内容
echo "Available files:"

for ((i=0; i<${#files[@]}; i++)); do
    content=$(sed -n '2p' "${files[$i]}")  # 获取第二行内容
    echo "$((i+1)): ${files[$i]} \"$content\""
done

while true; do
    # 提示用户输入要查看的文件编号或退出字符
    read -p "Enter the number of the file you want to view or 'q' to quit: " selection

    # 检查用户是否输入退出字符
    if [ "$selection" == "q" ]; then
        echo "Exiting the script."
        exit 0
    fi

    # 检查用户输入的编号是否有效
    if [ "$selection" -ge 1 ] && [ "$selection" -le "${#files[@]}" ]; then
        selected_file="${files[$((selection-1))]}"
        echo "Content of ${selected_file}:"
        cat "$selected_file"  # 直接使用 cat 命令显示文件内容
        exit 0
    else
        echo "Invalid selection. Please enter a valid file number or 'q' to quit."
    fi
done
