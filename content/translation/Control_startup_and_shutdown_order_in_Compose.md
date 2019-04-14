---
title: "Control_startup_and_shutdown_order_in_Compose"
date: 2019-04-07T23:54:05+08:00
draft: false
---

原文链接：https://docs.docker.com/compose/startup-order/，翻译如下：



您可以使用“depends_on”选项控制服务启动和关闭的顺序。compose总是按依赖顺序启动和停止容器，依赖性由depends_on、links、volumes_form和网络模式“service:…”确定。


但是，对于启动，compose不会等到容器“就绪”（对于特定的应用程序来说，这意味着什么）之后才运行。这是有充分理由的。


等待数据库（例如）准备就绪的问题实际上只是分布式系统中一个更大问题的子集。在生产环境中，数据库可能随时不可用或移动主机。您的应用程序需要能够适应这些类型的故障。


要处理此问题，请设计应用程序以尝试在失败后重新建立与数据库的连接。如果应用程序重试连接，它最终可以连接到数据库。

最好的解决方案是在应用程序代码中执行这种签入，无论是在启动时还是在任何时候由于任何原因而丢失连接。但是，如果您不需要这种级别的恢复能力，您可以使用包装脚本来解决这个问题：

* 使用诸如wait for it、dockerize或sh-compatible wait for等工具。这些是小包装脚本，您可以将其包含在应用程序的映像中，以轮询给定的主机和端口，直到它接受TCP连接。

例如，要使用wait-for-it.sh或wait-for-wrap服务的命令：

```
version: "2"
services:
  web:
    build: .
    ports:
      - "80:8000"
    depends_on:
      - "db"
    command: ["./wait-for-it.sh", "db:5432", "--", "python", "app.py"]
  db:
    image: postgres
```
> 提示：第一个解决方案有局限性。例如，它不验证特定服务何时真正准备好。如果向命令添加更多参数，请使用带有循环的bash shift命令，如下一个示例所示。



* 或者，编写自己的包装器脚本来执行更特定于应用程序的健康检查。例如，您可能希望等待Postgres完全准备好接受命令： 

```
#!/bin/sh
# wait-for-postgres.sh

set -e

host="$1"
shift
cmd="$@"

until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$host" -U "postgres" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - executing command"
exec $cmd
```

您可以将其用作包装脚本，如前一个示例中所示，方法是设置：

> command: ["./wait-for-postgres.sh", "db", "python", "app.py"]