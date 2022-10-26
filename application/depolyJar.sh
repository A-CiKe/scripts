#!/bin/bash
#这里可替换为你自己的执行程序的文件名
FUN=$1
APP_NAME=$2
BASE_PATH=/server
APP_BASE_PATH=${BASE_PATH}/apps/${APP_NAME}
#启动项目的路径
APP_PATH=${APP_BASE_PATH}/${APP_NAME}.jar
#输出日志的路径
NOHUP_LOG_PATH=${APP_BASE_PATH}/nohup_${APP_NAME}.log

echo "应用名称：${APP_NAME},执行函数：${FUN}"
echo "JAR包路径：${APP_PATH}"
echo "启动日志路径：${NOHUP_LOG_PATH}"

#===========================================================================================
# Java Environment Setting
#===========================================================================================
error_exit ()
{
    echo "ERROR: $1 !!"
    exit 1
}

[ ! -e "$JAVA_HOME/bin/java" ] && JAVA_HOME=$HOME/jdk/java
[ ! -e "$JAVA_HOME/bin/java" ] && JAVA_HOME=/usr/java
# 如果没有特殊配置，使用该jdk8版本
[ ! -e "$JAVA_HOME/bin/java" ] && JAVA_HOME=/server/jdk8
[ ! -e "$JAVA_HOME/bin/java" ] && error_exit "Please set the JAVA_HOME variable in your environment, We need java(x64)!"

export JAVA_HOME
export JAVA="$JAVA_HOME/bin/java"

#===========================================================================================
# JVM Configuration
#===========================================================================================
JAVA_OPT="${JAVA_OPT} -Xms512m  -Xmx1G  -Xmn256m -Xss256k -XX:MetaspaceSize=256M -XX:MaxMetaspaceSize=512M "
JAVA_OPT="${JAVA_OPT} -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSClassUnloadingEnabled "
JAVA_OPT="${JAVA_OPT} -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${APP_BASE_PATH}/${APP_NAME}_heapdump.hprof"
JAVA_OPT="${JAVA_OPT} -jar -Dfile.encoding=utf-8"
JAVA_OPT="${JAVA_OPT} ${APP_PATH}"


#===========================================================================================
# fuction
#===========================================================================================

#使用说明，用来提示输入参数
usage(){
    echo -e "\033[0;31m 未输入操作名 \033[0m  \033[0;34m {start|stop|restart|status} \033[0m"
    echo "Usage: sh deployJar.sh [start|stop|restart|status] [AppName]  || ./deployJar.sh [start|stop|restart|status] [AppName]"
    exit 1
}

#检查程序是否在运行
is_exist(){
  pid=`ps -ef|grep $APP_NAME.jar|grep -v grep|grep -v tail|grep -v vim|grep -v /bin/sh|awk '{print $2}'`
  #如果不存在返回1，存在返回0
  if [ -z "${pid}" ]; then
    return 1
  else
    return 0
  fi
}

#启动方法
start(){
  is_exist
  if [ $? -eq 0 ]; then
    echo "==>>>${APP_NAME} is already running. pid=${pid}"
  else
    echo "java path:${JAVA}"
    echo "启动参数：${JAVA_OPT}"
    echo "准备启动..."
    # 执行jar的命令,nohup表示永久运行。&表示后台运行
    nohup ${JAVA} ${JAVA_OPT}  > ${NOHUP_LOG_PATH} 2>&1 &
    sleep 5
    is_exist
    if [ $? -eq 0 ]; then
      echo "程序已经正常启动,NOHUP输出日志："
      cat ${NOHUP_LOG_PATH}
      echo "${APP_NAME} start success"
    else
      echo "程序启动失败,NOHUP输出日志："
      cat ${NOHUP_LOG_PATH}
    fi

  fi
}

#停止方法
stop(){
  is_exist
  if [ $? -eq "0" ]; then
    kill -9 $pid
    echo "${APP_NAME} stop success"
    echo ">>>>>进程已经关闭！"
  else
    echo "程序未运行，请检查上次是否异常退出!"
    echo "${APP_NAME} is not running"
  fi
}

#输出运行状态
status(){
  is_exist
  if [ $? -eq "0" ]; then
    echo "${APP_NAME} is running. Pid is ${pid}"
  else
    echo "${APP_NAME} is not running."
  fi
}

#重启
restart(){
  stop
  sleep 5
  start
  echo "${APP_NAME} restart success"
}

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case ${FUN} in
  "start")
    start
    ;;
  "stop")
    stop
    ;;
  "status")
    status
    ;;
  "restart")
    restart
    ;;
  *)
    usage
    ;;
esac

exit 0