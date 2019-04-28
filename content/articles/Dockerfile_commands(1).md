---
title: "Dockerfile常见命令(一)"
date: 2019-04-26T18:51:05+08:00
draft: false
---


1. FROM

**格式**：

FROM&lt;image&gt;&#91;AS &lt;name&gt;&#93;<br>
FROM&lt;image&gt;&#91;: &lt;tag&gt;&#93; &#91;AS &lt;name&gt;&#93;<br>
FROM&lt;image&gt;&#91;@ &lt;digest&gt;&#93; &#91;AS &lt;name&gt;&#93;<br>

**说明**：

FROM指令为后续指令创建一个基础镜像。所以所有的Dockerfile应该都是从FROM指令开始。初始化的镜像可以是任意合法的镜像。<br>
如果初始化的镜像在本地不存在，则会从公告仓库中获取镜像。

----
2. RUN

**格式**：

RUN &lt;command&gt; <br>
RUN &#91;"executable", "param1", "param2"&#93;

**说明**：

RUN指令会在当前镜像上生成新层，并在新层钟执行命令和提交结果。生成的新的镜像将用于下一步的Dockerfile。<br>
exec表单(第二种格式)被解析为JSON数组，这意味着必须使用双引号，不能使用单引号。<br>
"executable"中涉及到的路径必须转义反斜杠(\\)。

----
3. CMD

**格式**：

CMD &#91;"executable", "param1", "param2"&#93; (执行形式，这是首选形式)<br>
CMD &#91;"param1", "param2"&#93; (作为ENTRYPOINT的默认参数)<br>
CMD command param1 param2 (shell形式)

**说明**：

Dockerfile中只能有一个CMD指令，如果使用了多个，则只有在最后的CMD会生效。<br>
如果CMD用于为ENTRYPOINT指令提供默认参数，则应使用JSON数组格式指定CMD和ENTRYPOINT指令。

----
4. LABEL

**格式**：

LABEL &lt;key&gt;=&lt;value&gt; &lt;key&gt;=&lt;value&gt; &lt;key&gt;=&lt;value&gt; ...

**说明**：

LABEL指令将元数据添加到图像，LABEL使用键值对进行传值。<br>
镜像可以有多个标签，要指定多个标签，Docker建议LABEL尽可能将标签组合到单个指令中。如果使用多个LABEL，每条指令会生成一个新的图层，从而导致镜像效率低下。

---
5. EXPOSE

**格式**：

EXPOSE &lt;port&gt; &#91;&lt;port&gt; /&lt;protocol&gt;...&#93;

**说明**：

EXPOSE指令通知Docker容器在运行时侦听指定的网络端口。如果未指定，默认侦听TCP。

---
6. ENV

**格式**：

ENV &lt;key&gt; &lt;value&gt;<br>
ENV &lt;KEY&gt;=&lt;value&gt;

**说明**：

ENV指令将环境变量&lt;key&gt;设置为&lt;value&gt; 。<br>
尽量使用单一ENV作为环境变量指令。这样会产生单个缓存层。<br>
要为单个命令设置值，请使用RUN &lt;key&gt;=&lt;value&gt; &lt;command&gt; 。

---
7. ADD

**格式**：

ADD &lt;src&gt;.....&lt;dest&gt;<br>
ADD &#91;"&lt;src&gt;",.... "&lt;dest&gt;"&#93;  (包含空格的路径需要此表单)

**说明**：

ADD指令从中复制新文件，目录或远程文件URL， 并将它们添加到路径上镜像的文件系统中。<br>
&lt;src&gt;可以指定多个资源，但如果它们是文件或目录，则它们必须相对于正在构建的源目录(构建的上下文)。<br>
&lt;src&gt;中可以包含通配符进行匹配。通配符使用Go的[filepath.Match](http://golang.org/pkg/path/filepath#Match)规则完成。<br>
&lt;dest&gt;是容器中的一个绝对路径，或相对于一个路径WORKDIR，&lt;src&gt;内容将在&lt;dest&gt;目录下进行内容复制。<br>
当路径中存在特殊字符时，需要使用Golang规则进行转义，以防止被视为匹配模式。<br>
当复制文件为压缩格式时，ADD会将压缩内容在&lt;dest&gt;下解压缩为目录。

---
8. COPY

**格式**：

COPY &lt;src&gt;... &lt;dest&gt;<br>
COPY &#91;"&lt;src&gt;",.... "&lt;dest&gt;"&#93;  (包含空格的路径需要此表单)

**说明**：

COPY将&lt;src&gt;中的内容复制到容器的&lt;dest&gt;下。

---
COPY和ADD区别：
COPY只能从本机上复制内容，而ADD可以从URL地址处获取内容。
