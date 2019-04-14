---
title: "Five Simple Strategies for Securing APIs"
date: 2019-04-07T23:54:05+08:00
draft: false
---

# 保护API的五个简单策略

## 验证参数
任何弹性API实现的第一步是清理所有传入数据以进行确认它是有效的，不会造成伤害。对参数唯一最有效的防御操作和注入攻击时针对严格的模式验证所有传入的数据有效地描述了被认为是系统允许的输入。模式验证应尽可能具有限制性，尽可能使用输入、范围、集合甚至显性列表。还要考虑从许多开发工具生产的自动生成的模式通常会将所有参数减少到过于宽泛而无法有效识别潜在威胁的模型。手工构建的白名单时更优选的，因为开发人员可以根据他们对应用程序所期望的数据模型的理解来约束输入。基于XML的内容类型的一个选项是使用XML模式语言，该语言在创建受限制的内容模型和高度受约束的结构方面非常有效。对于日益普遍的JSON数据类型，有几种JSON模式描述语言。虽然没有XML那么丰富，但JSON的编写和理解要简单的多，提供透明度使其安全度提高。

## 应用显示威胁检测
良好的模式验证可以防止许多注入攻击，但也要考虑显示扫描常见的攻击签名。SQL注入或脚本注入攻击经常通过扫描原始输入容易发现的常见模式来进行攻击。
同时考虑可能采取其他形式，例如拒绝服务（DoS）。利用网咯基础设施俩发现和缓解网络级DoS攻击，还可以检查利用参数的DoS攻击。庞大的信息、严重嵌套的数据结构或过于复杂的数据结构都可能导致有效的拒绝服务攻击，从而不必要地消耗受影响的API服务器上的资源。将病毒检测应用于所有潜在风险的编码内容。文件传输中涉及的API硬解码base64附件并将其提交到服务器级病毒扫描，然后再保存到文件系统，在这些文件系统中可能会无意中激活它们。

## 始终开启SSL
使SSL / TLS成为所有API的规则。 在21世纪，SSL并不奢侈; 这是一个基本要求。 添加SSL / TLS并正确应用它可以有效抵御中间人攻击的风险。
SSL / TLS为客户端和服务器之间交换的所有数据提供完整性，包括重要的访问令牌，例如OAuth中使用的令牌。 它可选地使用证书提供客户端身份验证，这在许多环境中很重要。

## 应用严格的身份验证和授权
用户和应用程序标识是必须单独实现和管理的概念。 考虑基于广泛身份上下文的授权，包括实际因素，例如传入IP地址（如果已知是固定的或在特定范围内），访问时间窗口，设备标识（对移动应用程序有用），地理位置等。
OAuth正在迅速成为以用户为中心的API授权的首选资源，但它仍然是一个复杂，快速变化和困难的技术。 开发人员应该遵循基本的，易于理解的OAuth用例，并始终使用现有的库而不是尝试构建自己的库。

## 使用经过验证的Solutions
安全的第一条规则是：不要发明自己的。 没有理由创建自己的API安全框架，因为API已经存在优秀的安全解决方案。
挑战在于正确应用它们。