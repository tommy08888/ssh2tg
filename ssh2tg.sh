#!/bin/bash

# 登录计数文件路径
count_file="/var/log/ssh_login_count.log"

# 检查计数文件是否存在，如果不存在则创建
if [ ! -f $count_file ]; then
    touch $count_file
    count=0   # 设置默认初始值为0
else
    # 从计数文件中读取当前登录次数
    count=$(cat $count_file)
fi

# 将登录次数加一
count=$((count+1))

# 将新的登录次数写入计数文件
echo $count > $count_file

# Telegram Bot相关信息
TELEGRAM_BOT_TOKEN=replacetoken
CHAT_ID=replaceid

# 获取登录信息
IP=$(echo $SSH_CONNECTION | awk '{print $1}')
TIME=$(date +"%Y年%m月%d日 %H:%M:%S")
# 查询IP地址对应的地区信息
LOCATION=$(curl -s "http://opendata.baidu.com/api.php?query=$IP&co=&resource_id=6006&oe=utf8&format=json" | sed -n 's/.*"location":"\([^"]*\)".*/\1/p')
# 获取当前用户名
USERNAME=$(whoami)
HOSTNAME=$(hostname)
# 发送Telegram消息
MESSAGE="登录信息：
登录机器：$HOSTNAME
登录次数：$count
登录名：$USERNAME
登录IP：$IP
登录时间：$TIME
登录地区：$LOCATION"

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$CHAT_ID&text=$MESSAGE" >> /root/nohupssh2tg.out 2>&1 & disown

# 不显示登录次数
# echo "当前登录次数: $count"

# 移除读取最近5条记录的部分，确保脚本中没有任何 `jq` 的调用
# echo "您此台机器最后5次的登录记录如下！"
# cat nohupssh2tg.out | jq '.result.text' | tail -5 | sort -r | tr -d 'n''"' | sed 's/\\//g' | nl -w 2 -s '、'
