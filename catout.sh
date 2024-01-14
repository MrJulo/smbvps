#!/bin/bash

# 设置目录为当前脚本的目录
directory="$(dirname "$0")"

# 获取目录下所有以 "out" 开头的文件
files=("$directory"/out*)

# 如果没有文件，给出提示并退出
if [ ${#files[@]} -eq 0 ]; then
    echo "在目录中找不到 'out' 文件。退出。"
    exit 1
fi

# 直接显示第一个文件内容
echo -e "Content of ${files[0]}:"
cat "${files[0]}"

# 显示文件列表和第二行内容
echo -e "\nAvailable files:"

for ((i=0; i<${#files[@]}; i++)); do
    content=$(sed -n '2p' "${files[$i]}")  # 获取第二行内容
    echo "$((i+1)): ${files[$i]} \"$content\""
done

# 循环提示用户输入
for ((i=0; i<${#files[@]}; i++)); do
    read -p $'\n输入文件编号以显示对应内容，按回车退出: ' input

    # 检查用户是否输入回车
    if [ -z "$input" ]; then
        echo "退出脚本。"
        exit 0
    fi

    # 检查输入是否是数字
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        index=$((input-1))
        if [ "$index" -ge 0 ] && [ "$index" -lt ${#files[@]} ]; then
            # 显示选择文件的内容
            echo -e "\n${files[$index]} 的内容:"
            cat "${files[$index]}"
        else
            echo "无效的文件编号，请重新输入。"
        fi
    else
        echo "无效的输入，请输入有效的文件编号。"
    fi
done
