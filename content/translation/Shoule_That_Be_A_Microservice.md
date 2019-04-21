---
title: "Shoule_That_Be_A_Microservice"
date: 2019-04-21T22:51:16+08:00
draft: false
---

# 这应该是微服务吗？记住这六个因素

> 原文链接：https://content.pivotal.io/blog/should-that-be-a-microservice-keep-these-six-factors-in-mind

2018年1月19日
> NATHANIEL SCHUTTA

你写的代码比以往任何时候都多。关键是知道什么应该是微服务，什么不应该是。

这些天里，你一直在听到所有人都在谈论微服务。开发者们正在学习 Eric Evan 有先见之明的书《[Domain Driven Design](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)》。团队正在重构单个的应用，寻找上下文界限并定义一个普及的语言。然而虽然已经有了无数的文章，视频和会谈来帮助你把现有服务转换成微服务，但很少有人会花费哪怕一点时间去问一句，这个应用真的应该是微服务吗？

使用微服务架构有很多好的理由，但世界上没有免费的午餐，微服务的积极因素也增加了复杂性。团队应该乐于接受这个复杂性...只要有问题的应用能够从微服务中收益。

## 请微服务负起责任

[Matt Stine](https://twitter.com/mstine) 和我最近花了几天时间与客户一起浏览他们的一些应用。就像最近这些天一样，讨论开始于一个观点“一切都应该是微服务”。然后谈话就停滞不前，因为人们都在争论各种实现细节。

这促使 Matt 在白班上写了一套原则。这些简单的陈述在剩下的日子里一直指导着我们。这些陈述让我们质疑应用架构的每个部分，寻找微服务可以产生价值的地方。这个清单根本性地改变了对话的基调，并且帮助团队设计出了不错的架构决策。

为了让这个时间摆脱多余的微服务，我们提供了这个清单，来帮助你集中精力。阅读以下原则并且回答你们的应用是否受益于给定的原则。如果在一个或多个原则中你的回答都是“是”，那么微服务会是个不错的选择。如果所有的原则你的回答都是“否”，那么就有可能会在你的系统中引入[意外的复杂性](https://www.amazon.com/Mythical-Man-Month-Software-Engineering-Anniversary/dp/0201835959)

## 1. 多种变化率

你的系统中不同的部分是否需要以不同的速度往不同的方向发展？那么把他们分成微服务吧。这将允许每个组件拥有独立的生命周期。

在任何系统中，都会有一些模块很少被触及，而其他模块似乎每次都会被改动。提了说明，我们举个例子，比如一个用于在线销售的单体电子商务应用。

![img](https://content.cdntwrk.com/files/aHViPTYzOTc1JmNtZD1pdGVtZWRpdG9yaW1hZ2UmZmlsZW5hbWU9aXRlbWVkaXRvcmltYWdlXzVhNjEzZDRiOGU1ZGMucG5nJnZlcnNpb249MDAwMCZzaWc9MWY0NTVkZmIzOWY3N2E3YTQ5MzhiN2YwYWQxNmI2YzQ%253D)

我们的**购物车**和**库存**函数在日常的开发工作中可能很少会被触及。但是我们可能会不断尝试我们的**推荐引擎**。我们还希望努力改善我们的**搜索**功能。将这两个模块拆分成微服务将允许各自的团队以更快的速度进行迭代，以允许我们快速交付业务价值。

![img2](https://content.cdntwrk.com/files/aHViPTYzOTc1JmNtZD1pdGVtZWRpdG9yaW1hZ2UmZmlsZW5hbWU9aXRlbWVkaXRvcmltYWdlXzVhNjEzZDcxMTcxMWQucG5nJnZlcnNpb249MDAwMCZzaWc9MDA0NGNjYWFhMTU1Yzc4NDBhMGY3YzNjNzI5NDM1YmE%253D)

## 2. 独立的声明周期

如果一个模块需要一个完全独立的生命周期（意味着代码提交多给生产环境的流程），那么它应该是微服务。他应该拥有自己的代码仓库和 CI/CD 管道等。

叫嚣的范围是的微服务的测试变得更加容易。我记得有一个项目拥有80个小时的回归测试套件！无需多言，我们并不会经常执行完整的回归测试（虽然我们真的很想。）微服务支持细粒度的回归测试。这颗牙节省我们无数个小时。并且我们也可能会更快发现问题。

测试并不是我们拆分微服务的唯一原因。在某些情况下，一个业务需求也可能会将我们推向微服务架构。让我们看一下 Widget.io Monolith 示例。

我们的业务领导者可能已经发现了一个新的机会 - 而且推向市场的速度至关重要。如果我们决定将所需的新功能添加到整体中，那会需要太长时间。我们无法按照业务需要的步伐前进。

但作为独立的微服务，**Project X**（如下所示）可以拥有自己的部署管道。这种方法使我们能够快速迭代，并利用新的商机。

![img3](https://content.cdntwrk.com/files/aHViPTYzOTc1JmNtZD1pdGVtZWRpdG9yaW1hZ2UmZmlsZW5hbWU9aXRlbWVkaXRvcmltYWdlXzVhNjEzZDhjOGMwMDkucG5nJnZlcnNpb249MDAwMCZzaWc9MjMzNzk3ZDQ0ZWMxMDAzMmZlMDgwZGY3YjZlM2E1OTI%253D)

## 3. 独立的可扩展性

如果系统各部分的负载或吞吐量特性不同，则它们可能具有不同的扩展要求。解决方案：将这些组件分离成独立的微服务！这样，服务可以以不同的速率扩展。

即使粗略地回顾一下典型的架构，也会发现不同模块的不同扩展要求。让我们通过这个镜头回顾我们的Widget.io Monolith。

大概率来说，我们的**帐户管理**功能并没有像**订单处理**系统那么重要。在过去，为了支持我们最易变的组件，我们却必须扩展完整的系统。这种方法导致了更高的基础设施成本，因为我们被迫为我们应用程序的一部分最糟糕的情况来“过度配置”。

如果我们将**订单处理**功能重构为微服务，我们可以根据需要进行扩展和缩减。结果如下图所示：

![img4](https://content.cdntwrk.com/files/aHViPTYzOTc1JmNtZD1pdGVtZWRpdG9yaW1hZ2UmZmlsZW5hbWU9aXRlbWVkaXRvcmltYWdlXzVhNjEzZGEwYTg1MjcucG5nJnZlcnNpb249MDAwMCZzaWc9MzkyOWE1ZGM2OWZlMjA3MWE5NmQ4YTJjOWE3ZTdiZjM%253D)

## 4. 隔离故障

有时我们希望将应用程序与特定类型的故障隔离开来。例如，当我们依赖于不符合我们的可用性目标的外部服务时会发生什么？我们可能会创建一个微服务来将该依赖关系与系统的其他部分隔离开来。从那里，我们可以在该服务中构建适当的故障转移机制。

再次转向我们的示例 Widget.io Monolith，**Inventory**功能恰好与传统仓库系统进行交互，而后者的运行时间并不太好。我们可以通过将 Inventory 模块重构为微服务来保护我们的服务级别可用性目标。我们可能需要添加一些冗余来解决仓库系统的瑕疵问题。我们还可能会引入一些最终的一致性机制，例如 Redis 中的缓存库存。但就目前而言，向微服务的转变可以缓解不可靠的第三方依赖性导致的糟糕表现。

![img5](https://content.cdntwrk.com/files/aHViPTYzOTc1JmNtZD1pdGVtZWRpdG9yaW1hZ2UmZmlsZW5hbWU9aXRlbWVkaXRvcmltYWdlXzVhNjEzZGIyMGZhN2YucG5nJnZlcnNpb249MDAwMCZzaWc9NGNiNmVkZjc1MmZmY2FmMmJiYWMwODc2YzM2N2Q3MGI%253D)

## 5. 简化与外部依赖的交互（又名 Façade Pattern）

这个原则类似于“隔离失败”。扭曲：我们更注重于保护我们的系统免受经常变化的外部依赖。（这也可能是供应商依赖，其中一个服务提供商被换成另一个服务提供商，例如支付处理方的更换）。

微服务可以充当[间接层](https://www2.dmst.aueb.gr/dds/pubs/inbook/beautiful_code/html/Spi07g.html)，使你免受第三方依赖。我们可以在核心应用程序和依赖项之间放置一个抽象层（我们可以控制的），而不是直接调用依赖项。此外，我们可以构建此层，以便我们的应用程序可以轻松使用，隐藏依赖项的复杂性。如果将来事情发生变化 - 而且你必须迁移 - 你的更改仅限于外观，而不是更大的重构。

## 6. 为工作选择正确技术的自由

借助微服务，团队可以自由使用他们喜欢的技术栈。在某些情况下，业务需求应该适合特定的技术选择。其他时候，它受开发者偏好和熟悉程度的驱动。

注意：这个原则不是光明正大下使用每种技术的许可！为你的团队提供有关技术选择的指导。太多不同的技术栈会增加认知开销，并且可能比标准化的“一刀切”模型更糟糕。在一个技术栈中为第三方库保持更新已经足够有挑战性了。将这个辛苦乘以四或五，你将会承担相当大的组织负担。做有用的，并且专注于为你懂得维护的技术栈“铺路”。

在我们的Widget.io示例中，**搜索**功能可能会受益于与其他模块不同的语言或数据库选择。如果需要，可以直接执行此操作。当然，我们已经因为其他原因重构过它了！

## 文化检查

刚才是技术讨论，那么现在，文化呢？

真空中没有技术决定。因此，在你深入了解微服务的精彩世界之前，请先了解你的组织。你的组织结构是否轻松支持微服务架构？[Conway' Law](http://www.melconway.com/Home/Conways_Law.html) 觉得你可能会成功吗？

五十年前 Mel Conway 认为，任何组织设计的系统都会创建一个反映其组织结构图的系统。换句话说，如果你的团队没有组织成小型的自治团队，那么你的工程师就不可能创建由小型自治服务组成的软件。这种认识促使了 [Inverse Conway Maneuver](https://www.thoughtworks.com/radar/techniques/inverse-conway-maneuver)。这鼓励团队更改其组织结构图以反映他们希望在其应用程序中看到的体系结构。

你还应该考虑你的文化准备。微服务鼓励小的，频繁的变化 - 经常与传统的季度发布周期冲突的节奏。使用微服务，你将不会代码冻结或“大爆炸”代码集成。虽然基于微服务的体系结构肯定可以在传统的瀑布流环境中运行，但你不会看到完全的好处。

考虑如何配置基础架构。专注于自助服务和优化价值流的团队通常采用微服务范式。像 Pivotal Cloud Foundry 这样的平台可以帮助您的团队快速地部署服务，测试和改进，这只需要几分钟，而不是几周（或几个月）。开发人员只需按一下按钮即可启动实例 - 这种做法可以促进实验和学习。构建自动化依赖关系管理，这意味着开发商和运营商可以专注于提供业务价值。

最后，让我们问一下应用程序的两个具体问题：

* 此应用程序是否有多个业务所有者？如果一个系统有多个独立的自治企业主，那么它有两个不同的变化来源。这种情况可能会引发冲突。通过微服务，您可以实现“独立生命周期”并取悦这些不同的客户。
* 该应用程序是否由多个团队拥有？在单个系统上工作的多个团队的“协调成本”可能很高。相反，为它们定义API。从那里开始，每个团队都可以使用 [Spring Cloud Contract](https://cloud.spring.io/spring-cloud-contract) 或 [Pact](https://docs.pact.io/) 构建一个独立的微服务，用于[consumer driven contracts](https://martinfowler.com/articles/consumerDrivenContracts.html)测试。

对两个问题中任意一个的肯定回答，都将会将你引入微服务解决方案。

## 总结

美好的微服务之路已经铺好。但是不止一些团队在没有首先分析他们的需求的情况下加入了这个行列。微服务很强大。它们绝对应该在您的工具箱中！只要确保你考虑权衡。理解您的应用程序的业务驱动因素是无可替代的，这对于确定适当的架构方法至关重要。


