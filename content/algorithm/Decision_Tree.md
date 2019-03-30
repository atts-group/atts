---
title: "DecisionTree"
date: 2019-03-30T10:39:56+08:00
draft: false
---

# 决策树

学习并构建决策树。<br>
决策树的一个重要任务是为了数据中心所蕴含的知识信息，因此决策树可以使用不熟悉的数据集合，并从中提取出一系列规则。在这些机器根据数据创建规则时，就是机器学习的过程。专家系统中经常使用决策树，而且决策树给出结果往往可以匹敌在当前领域具有几十年工作经验的人类专家。

决策树示例：

![决策树示例](https://raw.githubusercontent.com/CTubby/images/master/markdown/SparkMLlibDecisionTree/1.png)

## 决策树函数组成部分


|优缺点          |说明  |
| ------------ | :----------------------------------------------------------------------------- |
|优点           | 计算复杂度不高、输出结果易于理解，对中间值的缺失不敏感，可以处理不相关特征数据 |
| 缺点         | 可能会产生过度匹配问题                                                         |
| 适用数据类型 | 数值型和标称型                                                                 |

1. 寻找最佳划分特征值

    构造决策树时，需要考虑的第一个问题：当前数据集中哪个特征在划分数据分类时起到决定作用。<br>
    为了找到这个特征，需要评估每一个特征，完成评测后，原始数据就会被划分为几个数据子集。然后遍历每个数据子集，若是都为同类，则该数据集结束分类，否则在该数据集中重新执行评估，二次分类。依次执行，直到数据被划分完毕或特征使用完毕时停止。

    创建分支的伪代码函数createBranch如下图所示：
    ```
    检测数据集中的每个子项是否属于同一分类：
    if so return 类标签：
    else:
        寻找划分数据集的最好特征
        划分数据集
        创建分支节点
            for每个划分的子集
                调用函数createBranch并增加返回结果到分支节点中
        return 分支节点
    ```
2. 信息增益

    划分数据集最大的原则是：将无序的数据变得更加有序。本章选取信息论度量信息。<br>
    在划分数据集之前之后信息发生的变化称为信息增益，知道如何计算信息增益，我们就可以计算每个特征值划分数据集获得的信息增益，获得信息增益最好的特征就是最好的选择。

    1).计算给定数据集的香农熵
    计算熵的公式：
    $$
    H = -\sum_{i=1}^{n}P(x_{i})log_{2}^{P(x_{i})}
    $$  
      

    ```python
    from math import log

    def calcShannonEnt(dataSet):
        numEntries = len(dataSet)  # 获取数据集中实例总数
        labelCounts = {}  # 创建数据字典，键值为数据集最后一列的值，即标签 
        for featVec in dataSet:
            currentLabel = featVec[-1]  # 获取标签
            if currentLabel not in labelCounts.keys(): # 如果标签不在字典中，则将其添加进去
                labelCounts[currentLabel] =0
            labelCounts[currentLabel] += 1  # 如果标签存在，则对应的数值加1
        shannonEnt = 0.0
        for LabelKey in labelCounts:
            prob = float(labelCounts[LabelKey]) / numEntries  # 计算数值进入该分类的概率
            shannonEnt -= prob * log(prob, 2)  # 计算熵
        return shannonEnt
    ```
    示例数据：

    |      | 不浮出水面 | 是否有脚蹼 | 属于鱼类 |
    | :--- | :--------- | :--------- | :------- |
    | 1    | 是         | 是         | 是       |
    | 2    | 是         | 是         | 是       |
    | 3    | 是         | 否         | 否       |
    | 4    | 否         | 是         | 否       |
    | 5    | 否         | 是         | 否       |

    对应数据集：
    ```
    dataSet = [
        [1, 1, 'yes'],
        [1, 1, 'yes'],
        [1, 0, 'no'],
        [0, 1, 'no'],
        [0, 1, 'no']
    ]
    ```
3. 划分数据集
    划分数据集，度量划分数据集的熵，以便判断当前是否正确划分了数据集。
    通过对每个特征划分数据集的结果度量熵，判断哪个特征划分数据集是最好的划分方式。
    ```python
    def splitDateSet(dataSet, axis, value):  # dataSet：待划分的数据集；axis：划分数据的特征索引；value：对应划分的特征值
        retDateSet = []
        for featVec in dataSet:
            if featVec[axis] == value:
                reduceFeatVec = featVec[:axis]
                reduceFeatVec.extend(featVec[axis+1:])
                retDataSet.append(reduceFeatVec)
        return retDateSet
    ```
    
4. 选择最好的数据集划分方式
   通过该函数选取特征，划分数据集，计算出最好的划分数据集的特征。
   ```python
    def chooseBestFeatureToSplit(dataSet):
        numFeatures = len(dataSet[0]) -1
        bestEntropy = calcShannonEnt(dataSet)  # 计算原始香农熵
        bestInfoGain = 0.0  # 信息增益
        bestFeature = -1  # 原始特征值索引
        for i in range(numFeatures):
            featList = [example[i] for example in dataSet]  #创建第i个特征值组成的列表
            uniqueVals = set(featList ) #创建特征值集合，去除重复元素
            newEntropy = 0.0
            for value in uniqueVals:  # 依次读取特征值，计算香农熵
                subDataSet = splitDataSet(dataSet, i, value)
                prob = len(subDataSet)/float(len(dataSet))
                newEntropy += prob * calcShannonEnt(subDataSet)
            infoGain = baseEntropy - newEntropy  #计算信息增益
            if infoGain > bestInfoGain:  # 如果信息增益变大，则代表该特征值更好
                bestInfoGain = infoGain
                bestFeature = i
        return bestFeature  # 返回最佳特征值的索引
   ```
## 递归构造决策树
    递归构造决策树原理：根据数据集选择最好的特征划分数据集，由于特征可能多于两个，故分支节点可能有多个。第一次划分后，子数据集中，可能还需要进行划分，故需要在子数据集中，递归调用决策树进行分类。

1. 构建叶子节点分类函数
   在本章构建决策树时，选择最佳特征值后，会删除特征。假设所有的特征使用完毕后，在某些叶子结点中，并不是都是一类，此时需要使用多数表决来分类。
   下述函数将对叶子结点中所有的数据进行分类统计，最后选出数量最多的类别并返回其标签作为叶子结点分类标签。
    ```python
    def majorituCnt(classList):
        classCount = {}
        for vote in classList:
            if vote not in classCount.keys():
                classCount[vote] = 0
            classCount[vote] += 1
        sortedClassCount = sorted(classCount.iteritems(), key=operator.itemgetter(1), reverse=True)
        return sortedClassCountp[0][0]
    ```
2. 构建决策树

    ```python
    def createTree(data, labels):
        classList = [example[i] for example in dataSet]
        if classList.count(classList[0]) == len(classList):  # 当类别完全相同时停止继续划分
            return classList[0]
        if len(dataSet[0]) == 1:  # 遍历完所有特征时返回出现次数最多
            return majorityCnt(classList)
        bestFeat = chooseBestFeatureToSplit(dataSet)  # 选取最佳划分特征
        bestFeatLabel = labels[bestFeat]
        myTree = {bestFeatLabel:{}}  # 构建节点
        del(labels[bestFeat])
        featValues = [example[bestFeat] for example in dataSet]
        uniqueVals = set(featValues)
        for value in uniqueVals:
            subLabels = labels[:]  # 将类标签复制，防止使用过程中类标签被改变。
            myTree[bestFFeatLabel][value] = createTree(splitDataSet(dataSet, bestFeat, value), subLabels)  # 递归调用函数
        return myTree
    ```

## 使用Matplotlib绘制决策树

```python
import matplotlib.pyplot as plt

from pylab import *
mpl.rcParams['font.sans-serif'] = ['SimHei']

decisionNode = dict(boxstyle='sawtooth', fc='0.8')
leafNode = dict(boxstyle='round4', fc='0.8')
arrow_args = dict(arrowstyle='<-')


def getNumLeafs(MyTree):  # 获取叶子节点数
    NumLeafs = 0
    firstStr = list(MyTree.keys())[0]
    secondDict = MyTree[firstStr]
    for TreeKey in secondDict.keys():
        if isinstance(secondDict[TreeKey], dict):
            NumLeafs += getNumLeafs(secondDict[TreeKey])
        else:
            NumLeafs += 1
    return NumLeafs


def getTreeDepth(MyTree):  # 获取树深度
    maxDepth = 0
    thisDepth = 0
    firstStr = list(MyTree.keys())[0]
    secondDict = MyTree[firstStr]
    for TreeKey in secondDict.keys():
        if isinstance(secondDict[TreeKey], dict):
            thisDepth = 1 + getTreeDepth(secondDict[TreeKey])
        else:
            thisDepth += 1
        if thisDepth > maxDepth:
            maxDepth = thisDepth
    return maxDepth


def plotMidText(cntrPt, parentPt, txtString):
    xMid = (parentPt[0]-cntrPt[0])/2.0 + cntrPt[0]
    yMid = (parentPt[1]-cntrPt[1])/2.0 + cntrPt[1]
    createPlot.axl.text(xMid, yMid, txtString)


def plotTree(MyTree, parentPt, nodeTxt):
    numLeafs = getNumLeafs(MyTree)
    depth = getTreeDepth(MyTree)
    firstStr = list(MyTree.keys())[0]
    cntrPt = (plotTree.x0ff + (1.0 + float(numLeafs))/2.0/plotTree.totalW, plotTree.y0ff)
    plotMidText(cntrPt, parentPt, nodeTxt)
    plotNode(firstStr, cntrPt, parentPt, decisionNode)
    secondDict = MyTree[firstStr]
    plotTree.y0ff = plotTree.y0ff - 1.0/plotTree.totalD
    for TreeKey in secondDict.keys():
        if isinstance(secondDict[TreeKey], dict):
            plotTree(secondDict[TreeKey], cntrPt, str(TreeKey))
        else:
            plotTree.x0ff = plotTree.x0ff + 1.0/plotTree.totalW
            plotNode(secondDict[TreeKey], (plotTree.x0ff, plotTree.y0ff), cntrPt, leafNode)
            plotMidText((plotTree.x0ff, plotTree.y0ff), cntrPt, str(TreeKey))
    plotTree.y0ff = plotTree.y0ff + 1.0/plotTree.totalD


def plotNode(nodeTxt, centerPt, parentPt, nodeType):
    createPlot.axl.annotate(nodeTxt, xy=parentPt, xycoords='axes fraction', xytext=centerPt, textcoords='axes fraction', va='center', ha='center', bbox=nodeType, arrowprops=arrow_args)


def createPlot(inTree):
    fig = plt.figure(1, facecolor='white')
    fig.clf()
    anprops = dict(xticks=[], yticks=[])
    createPlot.axl = plt.subplot(111, frameon=False, **anprops)
    plotTree.totalW = float(getNumLeafs(inTree))
    plotTree.totalD = float(getTreeDepth(inTree))
    plotTree.x0ff = -0.5/plotTree.totalW
    plotTree.y0ff = 1.0
    plotTree(inTree, (0.5, 1.0), '')
    plt.show()

```