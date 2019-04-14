---
title: "工作中用到的python写log方式"
date: 2019-04-07T22:17:39+08:00
draft: false
---

## 1.  使用logger
``` python
root@ubuntu:/home/hank# cat test_logger.py
#! /usr/bin/python
import logging
import os


class TestLogger:
    def __init__(self, log_name, log_dir=None, default_level=logging.DEBUG):
        self.logger = logging.getLogger(log_name)
        if not self.logger.handlers:
            log_dir = "/var/log/" if not log_dir else log_dir
            os.mkdir(log_dir) if not os.path.exists(log_dir) else None
            absolute_log = os.path.join(log_dir, log_name + '.log')

            handler = logging.FileHandler(absolute_log)
            formatter = logging.Formatter('%(asctime)-25s %(levelname)-8s %(message)s')
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)
            self.logger.setLevel(default_level)
    
    def debug(self, msg):
        self.logger.debug(msg)
    
    def info(self, msg):
        self.logger.info(msg)
    
    def error(self, msg):
        self.logger.error(msg)
    
    def critical(self, msg):
        self.logger.critical(msg)


if __name__ == '__main__':
    log_file, __ = os.path.splitext(os.path.basename(os.path.realpath(__file__)))
    logger = TestLogger(log_file)
    logger.info('information test')
    logger.error('error test')
```
``` python
root@ubuntu:/home/hank# cat test.py
#!/usr/bin/python
from test_logger import TestLogger

logger = TestLogger("test")
logger.info("information test")
logger.error('error test')
```

formatter = logging.Formatter('%(asctime)-25s %(levelname)-8s %(message)s')
这里定义-25s的原因是asctime为22。所以25正好够和后面的levelname相隔3

``` python
root@ubuntu:/home/hank# cat  /var/log/test.log
2019-04-04 19:18:53,432   INFO     information test
2019-04-04 19:18:53,432   ERROR    error test        

```
## 2.  简单的自定义log模块
``` python
#! /usr/bin/python


class SimpleLogger:
    def __init__(self, file_name):
        self.file_name = file_name

    def _write_log(self, level, msg):
        with open(self.file_name, "a") as log_file:
            log_file.write("[{0}] {1}\n".format(level, msg))
    
    def debug(self, msg):
        self._write_log("DEBUG", msg)
    
    def info(self, msg):
        self._write_log("INFO", msg)
    
    def warn(self, msg):
        self._write_log("WARN", msg)
    
    def error(self, msg):
        self._write_log("ERROR", msg)
    
    def critical(self, msg):
        self._write_log("CRITICAL", msg)


root@ubuntu:/home/hank# cat test3.py 
#! /usr/bin/python

from simple_logger import SimpleLogger

logger = SimpleLogger("simple_logger.log")
logger.warn("this is a warm")
logger.info("this is a info")


root@ubuntu:/home/hank# cat simple_logger.log 
[WARN] this is a warm
[INFO] this is a info
```


## 3. log中关于读写的问题
   写日志时，如是日志文件不存在，则创建；且可以写日志，且方式是追加，所以用a
