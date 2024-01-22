#!/bin/bash

# 以下是运行该脚本的说明和注意事项：
# 1）首先备份生产服务器上的全部nginx & haproxy配置文件
# 2）该脚本一次只能处理一个目录下的配置文件，如果有多个目录，需要多次运行该脚本
# 3）该脚本只能处理扩展名为conf的文件，如果有其他扩展名的文件，需要先手动更改扩展名
# 4）运行该脚本时，会首先提示用户输入要更改的源IP和目标IP，然后会在当前目录下生成srcip.list文件，该文件记录了源IP在哪些文件中被找到了，以及找到了多少次
# 5）该脚本会将源IP更改为目标IP，并将更改后的文件复制到/home/目标IP目录下
# 6）该脚本会在当前目录下生成src_源IP文件和tgt_目标IP文件，分别记录了源IP和目标IP在哪些文件中被找到了，以及找到了多少次
# 7）该脚本会比对src_源IP文件和tgt_目标IP文件，如果找到的次数相同，则认为IP更改成功，否则认为IP更改失败
# 8）如果IP更改失败，则会输出未更改成功的文件名清单
# 9）如果IP更改失败，则需要手动检查未更改成功的文件，然后再次运行该脚本
# 10）如果IP更改成功，则可以将/home/目标IP目录下的文件复制到生产服务器上，覆盖原来的配置文件，然后重新加载配置文件
# 11）重复上述步骤，直到所有需要更改IP的配置文件都被更改为止



# 生成srcip.list文件
touch srcip.list

# 提示用户输入要更改的源IP和目标IP
read -p "请输入要更改的源IP：" source_ip
read -p "请输入要更改的目标IP：" target_ip

# 在/home目录下创建目录，目录名为目标IP
mkdir -p /home/$target_ip

# 初始化文件名数量为0
num_src=0
num_tgt=0

# 逐个读取当前目录下每个扩展名为conf文件的文件名
for filename in *.conf; do
    # 初始化找到的次数为0
    count=0
    while read -r line; do
        # 检查该行行内是否包含源IP
        if [[ "$line" == *"$source_ip"* ]]; then
            ((count++))
            echo "在文件 $filename 中找到了 $count 次 $source_ip"
            echo "$filename: $line" >> srcip.list
            # 替换源IP为目标IP，并将替换后的文件复制到/home/目标IP目录
            sed "s/$source_ip/$target_ip/g" "$filename" > "/home/$target_ip/$filename"
        fi
    done < "$filename"
    # 如果找到了源IP，则将文件名添加到src_源IP文件中，并记录文件名数量
    if [ $count -gt 0 ]; then
        echo "$filename" >> "src_$source_ip"
        ((num_src+=count))
    fi
    # 将替换好的文件名添加到tgt_目标IP文件中，并记录文件名数量
    if grep -q "$target_ip" "/home/$target_ip/$filename"; then
        ((num_tgt+=count))
    fi
done

# 比对num_src和num_tgt，输出结果
if [ $num_src -eq $num_tgt ]; then
    echo "$num_tgt IP更改成功!!!!!!!!!!!"
else
    echo "IP更改失败"
    echo "未更改成功的文件名清单："
    comm -23 <(sort "src_$source_ip") <(sort "tgt_$target_ip")
fi