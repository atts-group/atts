---
title: "K近邻算法"
date: 2019-04-07T20:42:56+08:00
draft: false
---

## K-近邻算法（KNN）

 1. ### 算法思想：
存在一个训练样本集，并且样本数据集中每个数据都存在标签。将新数据的每个特征与样本数据集中数据对应的特征进行比较，然后算法提取前K个相似的数据。

 2. ### 优缺点及适用范围：
优点：精度高、对异常值不敏感、无数据输入假定；<br>
缺点：计算复杂度高、空间复杂度高；<br>
使用数据范围：数值型和标称型<br>

 3. ### 计算距离公式
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190303210938504.png)

 4. ### 示例分析：约会人员属性
- #### 使用的库
```
Numpy
operator
```
- #### 读取数据：将文本记录转化为Numpy矩阵
```
def file2matrix(filename):
    fr = open(filename)
    arrayOLines = fr.readlines()
    numberOfLines = len(arrayOLines)
    returnMat = zeros((numberOfLines, 3))  # 创建numpy矩阵 1000行,3列
    classLabelVector = []  # 类标签向量
    index = 0
    for line in arrayOLines:  # 逐行填充矩阵和标签向量
        line = line.strip()
        listFromLine = line.split('\t')
        returnMat[index, :] = listFromLine[0:3]
        classLabelVector.append(int(listFromLine[-1]))
        index += 1
    return returnMat, classLabelVector
```
- #### 处理数据：归一化数值(min-max标准化)
```
def autoNorm(dataSet):
    minValue = dataSet.min(0)
    maxValue = dataSet.max(0)
    ranges = maxValue - minValue
    normDataSet = zeros(shape(dataSet))
    m = dataSet.shape[0]
    normDataSet = dataSet - tile(minValue, (m, 1))  # titl函数将minValue复制成dataSet矩阵大小
    normDataSet = normDataSet/tile(ranges, (m, 1))
    return normDataSet, ranges, minValue
```
- #### K近邻算法代码
```
def classify0(inX, DataSet, labels, k: int):  # inX:用于分类的输入向量  DataSet:训练样本  labels：标签向量  k:用于选择的最近邻居的数目
    # 距离计算：向量之间的距离公式
    DataSetSize = DataSet.shape[0]
    DiffMat = tile(inX, (DataSetSize, 1)) - DataSet  # 将inX与DataSet做向量减法
    sqDiffMat = DiffMat ** 2  # 将相减后的结果进行平方
    sqDistances = sqDiffMat.sum(axis=1)  # 将矩阵进行行相加
    distances = sqDistances ** 0.5  # 将矩阵结果开平方
    # 选择距离最小的k个点
    sortedDistIndicies = distances.argsort()  # 得到distances矩阵从小到大排序后的对应index
    classCount = {}
    for i in range(k):  # 统计前k个距离中各个类别的个数
        voteIlabel = labels[sortedDistIndicies[i]]
        classCount[voteIlabel] = classCount.get(voteIlabel, 0) + 1
    # 排序
    sortedClassCount = sorted(classCount.items(), key=operator.itemgetter(1), reverse=True)  # 将字典按照value值排序
    return sortedClassCount[0][0]  # 将排序后的第一个key值
```
- #### 测试算法:测试算法正确率
```
def datingClassTest():
    hoRatio = 0.10
    datingDataMat, datingLabels = file2matrix("your dataset path")
    normat, ranges, minvalue = autoNorm(datingDataMat)
    m = normat.shape[0]
    numTestVecs = int(m*hoRatio)
    errorCount = 0.0
    for i in range(numTestVecs):
        classifierResult = classify0(normat[i, :], normat[numTestVecs:m, :], datingLabels[numTestVecs: m], 3)
        print("the classifier came back with %s, the real answer is: %s" % (classifierResult, datingLabels[i]))
        if classifierResult != datingLabels[i]:
            errorCount += 1.0
    print(errorCount, numTestVecs)
    print("the total error rate is %f" % (errorCount/float(numTestVecs)))
```

5. ### 测试结果
percentage of time spent playing video games?10<br>

frequent flier miles earned per year?10<br>

liters of ice cream consumed per year?20<br>

You will probably like this person: In small does