#!/bin/sh
#jdk所在目录
JAVA_HOME=/usr/local/src/jdk1.8.0_231
#jar包或者war包名
APP_MAINCLASS=jenkins.war
#项目所在目录
APP_HOME=/usr/local/src/jenkins
#log4j2有配置app.name和logpath
APP_NAME=jenkins
APP_LOG_HOME=/usr/local/src/jenkins/logs

psid=0

checkpid() {
   javaps=`ps -ef | grep $APP_MAINCLASS|grep -v grep`
   if [ -n "$javaps" ]; then
      psid=`echo $javaps | awk '{print $2}'`
   else
      psid=0
   fi
}


start() {
   checkpid
   echo "$psid"
   if [ $psid -ne 0 ]; then
      echo "================================"
      echo "warn: $APP_MAINCLASS already started! (pid=$psid)"
      echo "================================"
   else
      echo -n "Starting $APP_MAINCLASS ..."
      #有依赖外部包加上: -Dloader.path 有日志参数加上： -Dapp.name  -Dlog.root.path
      nohup $JAVA_HOME/bin/java -Xms256m -Xmx1024m -XX:MaxNewSize=256m -XX:MaxPermSize=256m -jar $APP_HOME/jenkins.war  --httpPort=8001 >/dev/null 2>&1 &
      checkpid
      if [ $psid -ne 0 ]; then
         echo "(pid=$psid) [OK]"
      else
         echo "[Failed]"
      fi
   fi
}

stop() {
   checkpid

   if [ $psid -ne 0 ]; then
      echo -n "Stopping $APP_MAINCLASS ...(pid=$psid) "
      kill -9 $psid
      if [ $? -eq 0 ]; then
         echo "[OK]"
      else
         echo "[Failed]"
      fi

      checkpid
      if [ $psid -ne 0 ]; then
         stop
      fi
   else
      echo "================================"
      echo "warn: $APP_MAINCLASS is not running"
      echo "================================"
   fi
}

status() {
   checkpid

   if [ $psid -ne 0 ];  then
      echo "$APP_MAINCLASS is running! (pid=$psid)"
   else
      echo "$APP_MAINCLASS is not running"
   fi
}


info() {
   echo "System Information:"
   echo "****************************"
   echo `head -n 1 /etc/issue`
   echo `uname -a`
   echo
   echo "JAVA_HOME=$JAVA_HOME"
   echo `$JAVA_HOME/bin/java -version`
   echo
   echo "APP_HOME=$APP_HOME"
   echo "APP_MAINCLASS=$APP_MAINCLASS"
   echo "****************************"
}

case "$1" in
   'start')
      start
      ;;
   'stop')
     stop
     ;;
   'restart')
     stop
         sleep 1
     start
     ;;
   'status')
     status
     ;;
   'info')
     info
     ;;
  *)
     echo "Usage: $0 {start|stop|restart|status|info}"
         ;;

esac
exit 1



