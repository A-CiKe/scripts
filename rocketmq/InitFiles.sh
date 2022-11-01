#!/bin/bash
#===========================================================================================
# 基本参数
#===========================================================================================
# RocketMQ在宿主机上的日志、数据、配置存储的基本目录
basePath=/tmp
# 宿主机IP地址
masterIP=192.168.1.234

error_exit ()
{
    echo "ERROR: $1 !!"
    exit 1
}
#===========================================================================================
# 创建rocketMQ需要的文件结构
#===========================================================================================
echo "开始创建文件目录"
mkdir -p ${basePath}/rocketmq/{conf,namesvr1-log,namesvr1-data,namesvr2-log,namesvr2-data,brokerM1-data,brokerM1-log,brokerM2-data,brokerM2-log,,brokerS1-data,brokerS1-log,,brokerS2-data,brokerS2-log}
cd ${basePath}/rocketmq/ || error_exit "进入rocket目录失败，请检查脚本执行情况"
echo "创建文件目录结束，目录详情："
ls ./
echo "开始创建rocketMQ配置文件,配置文件目录：${basePath}/rocketmq/conf"

cd ${basePath}/rocketmq/conf/ || error_exit "进入配置文件目录失败，请检查脚本执行情况"
echo "创建broker-m-1.conf"

cat > broker-m-1.conf <<EOF
#集群名称
brokerClusterName=ParkOrder
#broker名称
brokerName=broker1
#brokerId master用0 slave用其他
brokerId=0
#清理时机
deleteWhen=4
#文件保留时长 48小时
fileReservedTime=48
#broker角色 -ASYNC_MASTER异步复制 -SYNC_MASTER同步双写 -SLAVE
brokerRole=SYNC_MASTER
#刷盘策略 - ASYNC_FLUSH 异步刷盘 - SYNC_FLUSH 同步刷盘
flushDiskType=SYNC_FLUSH
#主机ip
brokerIP1=${masterIP}
#对外服务的监听接口，同一台机器上部署多个broker,端口号要不相同
listenPort=10911
#namesvr
# namesrvAddr=${masterIP}:9876;${masterIP}:9877
#是否能够自动创建topic
autoCreateTopicEnable=true
EOF
echo "创建broker-m-2.conf"

cat > broker-m-2.conf <<EOF
#集群名称
brokerClusterName=ParkOrder
#broker名称
brokerName=broker2
#brokerId master用0 slave用其他
brokerId=0
#清理时机
deleteWhen=4
#文件保留时长 48小时
fileReservedTime=48
#broker角色 -ASYNC_MASTER异步复制 -SYNC_MASTER同步双写 -SLAVE
brokerRole=SYNC_MASTER
#刷盘策略 - ASYNC_FLUSH 异步刷盘 - SYNC_FLUSH 同步刷盘
flushDiskType=SYNC_FLUSH
#主机ip
brokerIP1=${masterIP}
#对外服务的监听接口，同一台机器上部署多个broker,端口号要不相同
listenPort=12911
#namesrv
# namesrvAddr=${masterIP}:9876;${masterIP}:9877
#是否能够自动创建topic
autoCreateTopicEnable=true
EOF
echo "创建broker-s-1.conf"
cat > broker-s-1.conf <<EOF
#集群名称
brokerClusterName=ParkOrder
#broker名称
brokerName=broker1
#brokerId master用0 slave用其他
brokerId=1
#清理时机
deleteWhen=4
#文件保留时长 48小时
fileReservedTime=48
#broker角色 -ASYNC_MASTER异步复制 -SYNC_MASTER同步双写 -SLAVE
brokerRole=SLAVE
#刷盘策略 - ASYNC_FLUSH 异步刷盘 - SYNC_FLUSH 同步刷盘
flushDiskType=SYNC_FLUSH
#主机ip
brokerIP1=${masterIP}
#对外服务的监听接口，同一台机器上部署多个broker,端口号要不相同
listenPort=11911
#namesrv
# namesrvAddr=${masterIP}:9876;${masterIP}:9877
#是否能够自动创建topic
autoCreateTopicEnable=true
EOF
echo "创建broker-s-2.conf"
cat > broker-s-2.conf <<EOF
#集群名称
brokerClusterName=ParkOrder
#broker名称
brokerName=broker2
#brokerId master用0 slave用其他
brokerId=1
#清理时机
deleteWhen=4
#文件保留时长 48小时
fileReservedTime=48
#broker角色 -ASYNC_MASTER异步复制 -SYNC_MASTER同步双写 -SLAVE
brokerRole=SLAVE
#刷盘策略 - ASYNC_FLUSH 异步刷盘 - SYNC_FLUSH 同步刷盘
flushDiskType=SYNC_FLUSH
#主机ip
brokerIP1=${masterIP}
#对外服务的监听接口，同一台机器上部署多个broker,端口号要不相同
listenPort=13911
#namesrv
# namesrvAddr=${masterIP}:9876;${masterIP}:9877
#是否能够自动创建topic
autoCreateTopicEnable=true
EOF
cd ../
echo "创建docker-compose.yml"
cat > docker-compose.yml <<EOF
version: '3.5'
services:
  namesrv1:
    image: rocketmqinc/rocketmq:4.3.0
    container_name: namesrv1
    ports:
      - 9876:9876
    volumes:
      - ./namesvr1-log:/opt/logs
      - ./namesvr1-data:/opt/store
    command: sh mqnamesrv
    networks:
      rocketmq:
        aliases:
          - namesrv1
  namesrv2:
    image: rocketmqinc/rocketmq:4.3.0
    container_name: namesrv2
    ports:
      - 9877:9876
    volumes:
      - ./namesvr2-log:/opt/logs
      - ./namesvr2-data:/opt/store
    command: sh mqnamesrv
    networks:
      rocketmq:
        aliases:
          - namesrv2
  broker-m-1:
    image: rocketmqinc/rocketmq:4.3.0
    container_name: broker-m-1
    links:
      - namesrv1:namesrv1
      - namesrv2:namesrv2
    ports:
      - 10909:10909
      - 10911:10911
      - 10912:10912
    environment:
      TZ: Asia/Shanghai
      NAMESRV_ADDR: "namesrv1:9876;namesrv2:9876"
      JAVA_OPTS: "-Duser.home=/opt"
      JAVA_OPT_EXT: "-server -Xms256m -Xmx256m -Xmn256m"
    volumes:
      - ./brokerM1-log:/opt/logs
      - ./brokerM1-data:/opt/store
      - ./conf/broker-m-1.conf:/opt/rocketmq-4.3.0/conf/broker-m-1.conf
    command: sh mqbroker -c /opt/rocketmq-4.3.0/conf/broker-m-1.conf autoCreateTopicEnable=true &
    networks:
      rocketmq:
        aliases:
          - broker-m-1
  broker-s-1:
    image: rocketmqinc/rocketmq:4.3.0
    container_name: broker-s-1
    links:
      - namesrv1:namesrv1
      - namesrv2:namesrv2
    ports:
      - 11909:10909
      - 11911:11911
      - 11912:10912
    environment:
      TZ: Asia/Shanghai
      NAMESRV_ADDR: "namesrv1:9876;namesrv2:9876"
      JAVA_OPTS: "-Duser.home=/opt"
      JAVA_OPT_EXT: "-server -Xms256m -Xmx256m -Xmn256m"
    volumes:
      - ./brokerS1-log:/opt/logs
      - ./brokerS1-data:/opt/store
      - ./conf/broker-s-1.conf:/opt/rocketmq-4.3.0/conf/broker-s-1.conf
    command: sh mqbroker -c /opt/rocketmq-4.3.0/conf/broker-s-1.conf autoCreateTopicEnable=true &
    networks:
      rocketmq:
        aliases:
          - broker-s-1
  broker-m-2:
    image: rocketmqinc/rocketmq:4.3.0
    container_name: broker-m-2
    links:
      - namesrv1:namesrv1
      - namesrv2:namesrv2
    ports:
      - 12909:10909
      - 12911:12911
      - 12912:10912
    environment:
      TZ: Asia/Shanghai
      NAMESRV_ADDR: "namesrv1:9876;namesrv2:9876"
      JAVA_OPTS: "-Duser.home=/opt"
      JAVA_OPT_EXT: "-server -Xms256m -Xmx256m -Xmn256m"
    volumes:
      - ./brokerM2-log:/opt/logs
      - ./brokerM2-data:/opt/store
      - ./conf/broker-m-2.conf:/opt/rocketmq-4.3.0/conf/broker-m-2.conf
    command: sh mqbroker -c /opt/rocketmq-4.3.0/conf/broker-m-2.conf autoCreateTopicEnable=true &
    networks:
      rocketmq:
        aliases:
          - broker-m-2
  broker-s-2:
    image: rocketmqinc/rocketmq:4.3.0
    container_name: broker-s-2
    links:
      - namesrv1:namesrv1
      - namesrv2:namesrv2
    ports:
      - 13909:10909
      - 13911:13911
      - 13912:10912
    environment:
      TZ: Asia/Shanghai
      NAMESRV_ADDR: "namesrv1:9876;namesrv2:9876"
      JAVA_OPTS: "-Duser.home=/opt"
      JAVA_OPT_EXT: "-server -Xms256m -Xmx256m -Xmn256m"
    volumes:
      - ./brokerS2-log:/opt/logs
      - ./brokerS2-data:/opt/store
      - ./conf/broker-s-2.conf:/opt/rocketmq-4.3.0/conf/broker-s-2.conf
    command: sh mqbroker -c /opt/rocketmq-4.3.0/conf/broker-s-2.conf autoCreateTopicEnable=true &
    networks:
      rocketmq:
        aliases:
          - broker-s-2
  rocketmq-console:
    image: styletang/rocketmq-console-ng
    container_name: rocketmq-console
    links:
      - namesrv1:namesrv1
      - namesrv2:namesrv2
    ports:
      - 8090:8080
    environment:
      JAVA_OPTS: -Drocketmq.namesrv.addr=namesrv1:9876;namesrv2:9877 -Dcom.rocketmq.sendMessageWithVIPChannel=false
    networks:
      rocketmq:
        aliases:
          - rocketmq-console
networks:
  rocketmq:
    name: rocketmq
    driver: bridge
EOF

exit 0