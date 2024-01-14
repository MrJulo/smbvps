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

# 显示文件列表和第二行内容
echo "Available files:"

for ((i=0; i<${#files[@]}; i++)); do
    content=$(sed -n '2p' "${files[$i]}")  # 获取第二行内容
    echo "$((i+1)): ${files[$i]} \"$content\""
done

# 直接显示第一个文件内容
echo -e "\nContent of ${files[0]}:"
cat "${files[0]}"

# 循环提示用户输入
for ((i=1; i<${#files[@]}; i++)); do
    read -p $'\nPress Enter to display the next file, or enter "q" to quit: ' input

    # 检查用户是否输入退出字符
    if [ "$input" == "q" ]; then
        echo "Exiting the script."
        exit 0
    fi

    # 显示下一个文件内容
    echo -e "\nContent of ${files[$i]}:"
    cat "${files[$i]}"
done
