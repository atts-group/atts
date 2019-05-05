---
title: "如何用Python产生验证码"
date: 2019-05-06T00:18:55+08:00
draft: false
---

```python
#!/usr/bin/env python
# -*- coding:utf-8 -*-


import random
import string


def gen_random_string(length):
     num_of_numeric = random.randint(1,length-1)
     num_of_letter = length - num_of_numeric
     numerics = [random.choice(string.digits) for _ in range(num_of_numeric)]
     letters = [random.choice(string.ascii_letters) for _ in range(num_of_letter)]
     all_chars = numerics + letters
     random.shuffle(all_chars)
     result = ''.join(all_chars)
     return result


if __name__ == '__main__':
    print(gen_random_string(10))

C:\Python37\python.exe C:/python_workspace/test2.py
1863N575T5
```