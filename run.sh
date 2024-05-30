#!/bin/sh

# Pasted from Tomcat bin/startup.sh 

# Better OS/400 detection: see Bugzilla 31132
os400=false
case "`uname`" in
OS400*) os400=true;;
esac

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

PRGDIR=`dirname "$PRG"`/bin
EXECUTABLE=catalina.sh

# Check that target executable exists
if $os400; then
  # -x will Only work on the os400 if the files are:
  # 1. owned by the user
  # 2. owned by the PRIMARY group of the user
  # this will not work if the user belongs in secondary groups
  eval
else
  if [ ! -x "$PRGDIR"/"$EXECUTABLE" ]; then
    echo "Cannot find $PRGDIR/$EXECUTABLE"
    echo "The file is absent or does not have execute permission"
    echo "This file is needed to run this program"
    exit 1
  fi
fi

# Helper current directory variable, should be ROOT of installer
_curr=`cd "$PRGDIR/.." >/dev/null; pwd`

# Parse Tomcat Ports & Application Context
APP_PORT=`sed '/^\#/d' $_curr/snowMirror.properties | grep 'snowMirror.port'  | tail -n 1 | cut -d "=" -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`
CONTROL_PORT=`sed '/^\#/d' $_curr/snowMirror.properties | grep 'snowMirror.controlport'  | tail -n 1 | cut -d "=" -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`
APP_CONTEXT=`sed '/^\#/d' $_curr/snowMirror.properties | grep 'snowMirror.context'  | tail -n 1 | cut -d "=" -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`
APP_XMS=`sed '/^\#/d' $_curr/snowMirror.properties | grep 'snowMirror.memory.Xms'  | tail -n 1 | cut -d "=" -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`
APP_XMX=`sed '/^\#/d' $_curr/snowMirror.properties | grep 'snowMirror.memory.Xmx'  | tail -n 1 | cut -d "=" -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`
APP_JAVA_OPTS=`sed '/^\#/d' $_curr/snowMirror.properties | grep 'snowMirror.startup.java_opts'  | tail -n 1 | cut -d "=" -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`
APP_CATALINA_OPTS=`sed '/^\#/d' $_curr/snowMirror.properties | grep 'snowMirror.startup.catalina_opts'  | tail -n 1 | cut -d "=" -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`
export ADDITIONAL_CLASSPATH=`sed '/^\#/d' $_curr/snowMirror.properties | grep 'snowMirror.startup.classpath'  | tail -n 1 | cut -d "=" -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'`

echo "Memory settings in $_curr/snowMirror.properties: Xms=$APP_XMS, Xmx=$APP_XMX"
echo "JAVA_OPTS in $_curr/snowMirror.properties:       $APP_JAVA_OPTS"
echo "CATALINA_OPTS in $_curr/snowMirror.properties:   $APP_CATALINA_OPTS"
echo "ADDITIONAL_CLASSPATH in $_curr/snowMirror.properties: $ADDITIONAL_CLASSPATH"

if [ -z "$APP_XMS" ]; then
	APP_XMS="700m"
fi
if [ -z "$APP_XMX" ]; then
	APP_XMX="2G"
fi

# Create "logs" directory if it does not exist.
if [ ! -d "$_curr/logs" ]; then
  echo "Creating logs directory: '$_curr/logs'"
  mkdir "$_curr/logs"
else
  echo "Logs directory exists: '$_curr/logs'"
fi

# Export java properties
echo "Memory settings: Xms=$APP_XMS, Xmx=$APP_XMX"

# OpenTelemetry related env vars
export JAVA_TOOL_OPTIONS="-javaagent:$_curr/lib/opentelemetry-javaagent.jar"
export OTEL_SERVICE_NAME="snowmirror"

export JAVA_OPTS="-Duser.timezone=UTC -Duser.country=en -Duser.language=en -DsnowMirror.logDir=$_curr/logs -DsnowMirror.dataDir=file://$_curr/snow-mirror/data -DsnowMirror.properties.location=file://$_curr/snow-mirror/conf/ -DsnowMirror.config.db.location=file://$_curr/snowMirror.properties -DsnowMirror.config.location=file://$_curr/snow-mirror/conf/ -DsnowMirror.themesDir="file:///$_curr/snow-mirror-themes/" -Dspring.profiles.active=live -Dtomcat.http.port=$APP_PORT -Dtomcat.http.controlport=$CONTROL_PORT -Dtomcat.snowMirror.context=$APP_CONTEXT $APP_JAVA_OPTS"
export CATALINA_OPTS="-Xms$APP_XMS -Xmx$APP_XMX $APP_CATALINA_OPTS"

echo "### Starting server on http://localhost:${APP_PORT}${APP_CONTEXT} ###"
exec "$PRGDIR"/"$EXECUTABLE" "$@"
