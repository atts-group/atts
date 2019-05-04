---
title: "自定义 eslint 规则"
date: 2019-04-28T22:10:12+08:00
draft: false
---

本文记录一下如何开发基于 estlint 的自定义检查规则。开发规则的官方文档：[文档链接](https://eslint.org/docs/developer-guide/working-with-rules)。如何在本地测试规则的方法，请参考 [这篇文章](/tips/test-local-rule-eslint)。

下面是一个实际的例子，用这个规则，可以检测下面这种代码：

```javascript
if (a.b && a.b.c && a.b.c.d && a.b.c.d) {
  // send some ajax request
}
```

自定义规则代码如下：

```javascript
// 逻辑表达式是一颗二叉树，对其进行 flatten 操作
// 比如 a && b && c && d ，flatten 的结果 [a, b, c, d]
function flattenLogicalExpression(node) {
    if (node.operator !== '&&') {
        return [node]
    }

    let ret = []
    if (node.left.type !== 'LogicalExpression') {
        ret.push(node.left)
    } else {
        ret = ret.concat(flattenLogicalExpression(node.left))
    }
    if (node.right.type !== 'LogicalExpression') {
        ret.push(node.right)
    } else {
        ret = ret.concat(flattenLogicalExpression(node.right))
    }
    return ret
}

// 对 MemberExpression 进行 flatten 处理
// 比如 a.b.c.d 表达式的 AST 树会被转换成 [a, b, c, d] 这样的节点数组
function flattenMemberExpression(node) {
    if (node.type === 'Identifier') {
        return [node.name]
    }
    if (node.type !== 'MemberExpression') {
        // impossible
        return []
    }
    let ret = []
    ret = ret.concat(flattenMemberExpression(node.object))
    ret = ret.concat(flattenMemberExpression(node.property))
    return ret
}

function longestPath(graph, start, memo) {
    if (memo[start] !== undefined) {
        return memo[start]
    }

    const nodes = graph[start]
    let count = 0
    nodes.forEach(n => {
        const c = longestPath(graph, n, memo) + 1
        if (c > count) {
            count = c
        }
    })
    memo[start] = count
    return count
}

function matchPattern(nodes) {
    // build graph
    const graph = []
    nodes.forEach(() => graph.push([]))
    nodes.forEach((n1, i1) => {
        nodes.forEach((n2, i2) => {
            if (i1 === i2) {
                return
            }

            if (n2.startsWith(n1)) {
                graph[i1].push(i2)
            }
        })
    })
    let count = 0
    const memo = {}
    graph.forEach((_, i) => {
        const c = longestPath(graph, i, memo) + 1
        if (c > count) {
            count = c
        }
    })
    return count >= 3
}

const RuleHandlers = {
    'LogicalExpression': function (node) {
        if (node.parent.type === 'LogicalExpression') {
            return
        }
        let nodes = flattenLogicalExpression(node)
        nodes = nodes.filter(n => n.type === "MemberExpression")
        nodes = nodes.map(n => flattenMemberExpression(n)).map(n => n.join('.'))
        if (matchPattern(nodes)) {
            this.context.report({
                node: node,
                message: "Too long access path"
            });
        }
    }
}

class Rule {
    constructor(context) {
        this.context = context
        for (let h in RuleHandlers) {
            this[h] = RuleHandlers[h].bind(this)
        }
    }
}

module.exports = {
    meta: {
        type: "suggestion"
    },
    create: function (context) {
        return new Rule(context)
    }
};
```

核心的代码是 `RuleHandlers` ，每次遇到 LogicalExpression 的时候它的回调函数都会被执行。代码执行逻辑：

1. 对 LogicalExpression 节点组成的树，做 flatten 处理，得到一组 MemberExpression 节点
2. 对 MemberExpression 节点组成的树，做 flatten 处理，得到属性访问路径，比如 'a.b.c.d'
3. 检测 MemberExpression 是否是嵌套访问了某个属性：
   1. 使用 MemberExpression 列表构造一颗有向无环图
   2. 求出从每个节点出发能够得到的最长路径，这里使用了回溯算法
   3. 判断最长路径是否超过 3 个节点，如果存在的话，那么说明代码存在问题



## 实际使用

对下面这段代码进行检查：

```javascript
const a = {}
if (a.b && a.b.c && a.b.c.d && a.b.c.d.e) {
    const flag = a.b && a.b.c && a.c && a.b.c.d
    if (flag) {
        a.b.c.d = 2
    }
}
```

运行结果：

```bash
/Users/yangchen/tmp/too_long_access_path_rule/test.js
  2:5   error  Too long access path  too_long_access_path
  3:18  error  Too long access path  too_long_access_path
```

