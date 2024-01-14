#!/bin/bash

# 检查是否提供了目标文件夹名称参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <destination_folder_name>"
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

# 显示源目录的文件和文件夹，并标上号
echo "Files and folders in $source_directory:"
index=1
for entry in "$source_directory"/*; do
    echo "$index: $(basename "$entry")"
    ((index++))
done

# 提示用户输入要移动的项目的编号
read -p "Enter the number of the item you want to move: " selection

# 获取用户选择对应的文件或文件夹
selected_item=$(ls -A "$source_directory" | sed -n "${selection}p")

# 移动文件或文件夹到目标目录，显示进度条
#nohup rsync -ah --progress --remove-source-files "$source_directory/$selected_item" "$destination_directory" > out 2>&1 &
# --remove-source-files为复制文件到目标后删除源文件即移动文件
nohup bash -c "rsync -ah --progress --remove-source-files \"$source_directory/$selected_item\" \"$destination_directory\" && echo 'Item moved successfully to $destination_folder_name!'" > "$2" 2>&1 &
#echo "Item moved successfully to $destination_folder_name!"
