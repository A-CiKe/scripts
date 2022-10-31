#!/bin/bash
#---------------------------------------------------------------
# 批量修改git的远程仓库地址
#---------------------------------------------------------------

# workBasePath 工作空间地址
# 示例如下：
# /home/admin/workspace
#             |-app1
#             |-app2
# 此时workBasePath如下：
# workBasePath=/

workBasePath=/home/admin/workspace
echo "只能修改 workBasePath 下一级目录的地址，多级目录无法修改"
sed -i ''  "s/http\:\/\/pub\.tingjiandan\.net\:8081/https\:\/\/codeup\.aliyun\.com\/tingjiandan/g" `grep -lr 'http://pub.tingjiandan.net:8081' ${workBasePath}/**/.git/config`

echo "请检查是否有未修改的地址:"
cat `grep -lr 'url' ${workBasePath}/**/.git/config` |grep 'url'
