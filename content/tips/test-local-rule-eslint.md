---
title: "让 eslint 运行本地规则"
date: 2019-04-28T22:22:45+08:00
draft: false
---

运行本地规则，需要使用 `--rulesdir` 参数：

``` bash
 eslint --rulesdir rules/ test.js
```

通过上面这个命令，eslint 扫描 test.js 的时候，会加载 rules 文件夹下面的规则。

不过，还需要注意一点，需要在 eslint 配置文件中配置要使用的本地规则名称，本地规则才能工作：

```js
module.exports = {
    "env": {
        "browser": true,
        "commonjs": true,
        "es6": true
    },
    "extends": "eslint:recommended",
    "globals": {
        "Atomics": "readonly",
        "SharedArrayBuffer": "readonly"
    },
    "parserOptions": {
        "ecmaVersion": 2018
    },
    "rules": {
        "too_long_access_path": "error" // 需要在 rules 中配置要使用的本地规则
    }
};
```

