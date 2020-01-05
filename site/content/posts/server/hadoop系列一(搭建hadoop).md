---
title:  hadoop系列一(搭建hadoop)
date:   2019-04-19 16:43:00 +0800
categories: ["笔记"]
tags: ["hadoop"]
keywords: ["hadoop","docker","centos7","安装","jdk8","MapReduce","HDFS"]
description: "大数据在我2015年回到长沙的时候就已经很火了。当时进了外包公司，在长沙银行做一个etl的中转层。把上有系统中的数据加载到hadoop，对下游的报表等等的系统提供处理后的数据。当时号称是长沙地区第一家采用hadoop大数据处理的银行。我只是做了一些皮毛工作。完全没有一个整体的概念。前两天觉得有点和外部的公司脱轨了。去面试了一家公司，来看看外面的情况怎么样。如果待遇不错的话，还真的就跳走了。发现是一个靠中国移动吃饭的上市公司。招聘大数据相关的职位，觉得大数据已经普及开来了，必须跟上才行。一直活在公司的java-web里，觉得大多数java程序员不就这么回事吗。现在看来，我是out拉！下面就来一系列的笔记和记录，帮助自己系统得学习hadoop"
draft: true
---

> 大数据在我2015年回到长沙的时候就已经很火了。当时进了外包公司，在长沙银行做一个etl的中转层。把上有系统中的数据加载到hadoop，对下游的报表等等的系统提供处理后的数据。当时号称是长沙地区第一家采用hadoop大数据处理的银行。我只是做了一些皮毛工作。完全没有一个整体的概念。
>
> 前两天觉得有点和外部的公司脱轨了。去面试了一家公司，来看看外面的情况怎么样。如果待遇不错的话，还真的就跳走了。发现是一个靠中国移动吃饭的上市公司。招聘大数据相关的职位，觉得大数据已经普及开来了，必须跟上才行。一直活在公司的java-web里，觉得大多数java程序员不就这么回事吗。现在看来，我是out拉！
>
> 下面就来一系列的笔记和记录，帮助自己系统得学习hadoop


## 概览hadoop

`hadoop`个人理解是一个框架。就像是web一样。属于不同的体系。

hadoop主要的思想是，把一个大问题，分解成很多的小问题。让每个集群节点进行处理。最后把汇总后的数据返回。

特点是**所有的设计理念，都是针对于大量数据(起码是TB级别)**。如果没有那么大的数据量，是没有必要的。

### MapReduce

**就是用来写处理逻辑的**。

`Map`用来表示如何把一个大问题，分割成小的问题。

`Reduce`用来写小问题应该要如何处理。

因为提供了streaming接口，所以可以使用任意语言来进行编写，例如python或者c++。

### HDFS

**一个分布式文件系统**。

把数据分割成一个一个的数据块。存储在不同的服务器上。

同时有冗余设置。一旦发现机器不可用，可以从正常的服务器上复制新的数据到其他节点，保证数据的安全。

### YARN

**一个任务调度服务**。

它监控这每一个MapReduce，负责查看那个节点现在空闲-处于等待接受任务的状态。然后把具体的任务分发给各个节点。

## 动手安装

### 安装前提

**想要安装成什么架构？**

一个namenode主节点，2个datanode做分布式计算。

```
namenode  172.17.0.100
datanode1 172.17.0.101
datanode2 172.17.0.102
```

**为什么使用centos7呢？**

因为我对这个比较熟。同时在大部分企业内，centos可以算是事实标准了。

**为什么使用docker呢？**

万一服务器不是centos呢？docker可以完美解决这个问题。

而且我没有那么多的学习机器，而用virtualBox之类的，启动太慢了。

还有并且！在大型的hadoop环境中，你要添加一台节点，你在新节点要配置很多东西，复用docker就显得尤为重要。

**在docker中为什么使用root用户？**

docker中的root权限和宿主机的root并不是同样的root权限。不会影响到宿主机。同时会解决非常多的权限问题！

[下载hadoop](https://hadoop.apache.org/releases.html)，最新的版本是3.2.0。但是最新的版本，有点怕不稳定。所以选中3.1.2版本，毕竟是第二个小版本了。而且在页面上的排序，也是第一位。说明是比较推荐的。

![hadoop下载图](/images/server/hadoop下载图.png)

[下载jdk](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)，选好了对应的hadoop，那么就要有对应的jdk版本。

其实我是推荐用openjdk的，但是openjdk的8貌似才刚刚移交给redhat来维护，而网站的链接直接指向了oracle的页面，那就用oracle的吧。如下图所示
[hadooop对应jdk版本](https://cwiki.apache.org/confluence/display/HADOOP/Hadoop+Java+Versions)
![hadoop对应jdk版本](/images/server/hadoop对应jdk版本.png)

### docker的安装

[按照官方文档来吧](https://docs.docker.com/install/linux/docker-ce/centos/)

### 制作docker容器

参数说明:

- `--name`:容器的名字
- `-v`:把本地的路径，映射到容器的对应路径下
- `-d`:当你用exit退出容器以后，不关闭容器的运行。
- `centos:latest`:选用最新的centos版本
- `-h`:设置主机名
- `/bin/bash`:进入容易以后，使用的shell命令行
- `-it`:进入容器

**运行centos7环境的容器**

`-v /data/hadoop/image_v:/volume`主要是为了把下载好的hadoop和jdk提供给容器使用。

`-v /tmp/hadoop_data:/data`主要是为了把数据放在这个位置。在实际情况中，添加新的节点，只需要安装docker，创建好相同的目录结构，就可以开始使用。

```bash

sudo docker network create hadoop

# 这里注意，你就算要改主机名，也不要加上下划线！！大坑！！
# 否则在后面的core-site.xml等等地方，不能使用主机名
# 
sudo docker run -it --name hadoopbase --net hadoop -h hadoopbase -v /data/hadoop/image_v:/volume -d -v /tmp/hadoop_data:/data centos:latest /bin/bash
```

**进入hadoop_base容器**

```bash
sudo docker exec -it hadoopbase /bin/bash
```

**安装必要的包**

```bash
yum -y install openssh-clients net-tools openssh-server
```

**生成密钥，才能手动启用sshd服务**

```bash
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key

ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key

ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

/usr/sbin/sshd

ssh-keygen -t rsa 
```

**把jdk和hahdoop的文件夹解压以后放到/soft文件夹下**

```bash
mkdir /soft && cp -R /volume/* /soft/
```

**设置系统变量**

```bash
# 下面两个都要加上！停止容器，然后重新进入！
vi /root/.bashrc
vi /etc/profile
# 在底部添加如下内容
export HADOOP_HOME=/soft/hadoop-3.1.2
export JAVA_HOME=/soft/jdk1.8.0_211
export PATH=$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
# 保存退出以后
source /root/.bashrc
# 验证jdk可以用     java -version
# 验证hadoop可以用  hadoop

# 给root设置一个密码，方便之后集群之间的互访
passwd 
123456
123456
# 验证ssh以及密码可以用 ssh localhost 
ssh-copy-id root@hadoopbase
```

hadoop-env.sh
```bash
export JAVA_HOME=/soft/jdk1.8.0_211
export HADOOP_HOME=/soft/hadoop-3.1.2

export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_SECURE_USER=root


```


core-site.xml
```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://hadoopbase:9000/</value>
    </property>

    <property>
        <name>hadoop.tmp.dir</name>
        <value>/data</value>
    </property>
</configuration>
```

hdfs
```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
</configuration>
```

mapred-site.xml 
```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```

yarn
```xml
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>hadoopbase</value>
    </property>

    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
```


hadoop namenode -format




yarn-env

export YARN_RESOURCEMANAGER_USER=root
export HADOOP_SECURE_DN_USER=root
export YARN_NODEMANAGER_USER=hroot


保存镜像
sudo docker commit hadoopbase


sudo docker run -it -p 9870 --name hadoopbase --net hadoop -h hadoopbase -v /data/hadoop/image_v:/volume -d -v /tmp/hadoop_data:/data hadoopbase:v1 /bin/bash

运行第二个




第二个
hadoop-daemon.sh start datanode

hdfs dfsadmin -refreshNodes
start-balancer.sh

#检查是否成功
hdfs dfsadmin -report