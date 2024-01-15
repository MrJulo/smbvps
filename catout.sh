#!/bin/bash

# 设置目录为当前脚本的目录
directory="$(dirname "$0")"

# 获取目录下所有以 "out" 开头的文件
files=("$directory"/out*)

# 如果没有找到文件，给出提示并退出
if [ ${#files[@]} -eq 0 ]; then
    echo "在目录中找不到 'out' 文件。退出。"
    exit 1
fi

# 直接显示第一个文件内容
#echo -e "第一个文件的内容："
#cat "${files[0]}"

# 循环提示用户输入
while true; do
    # 显示文件列表和它们的第二行内容
    echo -e "\n可用文件："
    for ((i=0; i<${#files[@]}; i++)); do
        # 获取第二行内容
        content=$(sed -n '1p' "${files[$i]}")
        echo "$((i+1)): ${files[$i]} \"$content\""
    done

    read -p $'输入文件编号以显示其内容，或按回车退出： ' input

    # 检查用户是否按回车
    if [ -z "$input" ]; then
        echo "退出脚本。"
        exit 0
    fi

    # 检查输入是否为数字
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        index=$((input-1))
        if [ "$index" -ge 0 ] && [ "$index" -lt ${#files[@]} ]; then
            # 显示所选文件的内容
            echo -e "\n${files[$index]} 的内容："
            cat "${files[$index]}"
            # 添加一个换行以提高可读性
            echo
        else
            echo "无效的文件编号。请输入有效的文件编号。"
        fi
    else
        echo "无效的输入。请输入有效的文件编号。"
    fi
done
