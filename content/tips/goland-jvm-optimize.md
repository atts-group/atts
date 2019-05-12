---
title: "Goland Jvm Optimize"
date: 2019-05-12T21:44:40+08:00
draft: false
---

Help->Edit Custom VM Options

```
-Xms3g
-Xmx3g
-XX:ReservedCodeCacheSize=512m
-XX:+UseCompressedOops
-Dfile.encoding=UTF-8
-XX:SoftRefLRUPolicyMSPerMB=50
-ea
-Dsun.io.useCanonCaches=false
-Djava.net.preferIPv4Stack=true
-Djdk.http.auth.tunneling.disabledSchemes=""
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-Xverify:none
-server

-XX:+UseG1GC
-XX:MaxGCPauseMillis=20

-XX:ErrorFile=$USER_HOME/java_error_in_idea_%p.log
-XX:HeapDumpPath=$USER_HOME/java_error_in_idea.hprof
```