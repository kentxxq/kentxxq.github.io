---
title: jenkins教程
tags:
  - blog
date: 2024-01-29
lastmod: 2024-02-02
categories:
  - blog
description: 
---

## 简介

本来以为不会再使用 jenkins 了。但是遇到了这样的情况：

- 公司现在使用火山云 cicd，很烂，bug 多，很不好用
- 多种仓库结构
    - 前后端在同一个仓库
    - 后端多个微服务都在同一个仓库
    - 小程序独立项目结构。多种构建命令，产出不同端，不同目录
    - 前端独立仓库
- [[笔记/gitlab-cicd教程|gitlab-cicd]] 需要迁移代码到 gitlab。发版相关需要结合仓库的权限，分支的命名等。除非自己做二次开发

而 jenkins 这种久经沙场的万金油就不存在这些问题。

## 安装

### 安装 jenkins

```shell
# 安装jdk
apt install openjdk-21-jdk -y
```

[官网下载](https://www.jenkins.io/download/) war 包，配置守护进程

`/etc/systemd/system/jenkins.service`

```ini
[Unit]
Description=jenkins
# 启动区间30s内,尝试启动3次
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
# 环境变量 $MY_ENV1
# Environment=MY_ENV1=value1
# Environment="MY_ENV2=value2"
# 环境变量文件,文件内容"MY_ENV3=value3" $MY_ENV3
# EnvironmentFile=/path/to/environment/file1
WorkingDirectory=/root
ExecStart=/usr/bin/java -jar /root/jenkins.war
# 总是间隔30s重启,配合StartLimitIntervalSec实现无限重启
RestartSec=30s 
Restart=always
# 相关资源都发送term后,后发送kill
KillMode=mixed
# 最大文件打开数不限制
LimitNOFILE=infinity
# 子线程数量不限制
TasksMax=infinity

[Install]
WantedBy=multi-user.target
# Alias=testserver.service
```

启动

```shell
systemctl enable jenkins --now
```

因为国内的网络问题，启动大概率会有问题。

此时找到 `/root/.jenkins/hudson.model.UpdateCenter.xml` 文件，修改 url 为国内源

```xml
<?xml version='1.1' encoding='UTF-8'?>
<sites>
  <site>
    <id>default</id>
    <url>https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json</url>
  </site>
</sites>
```

重启

```shell
systemctl restart jenkins
```

### 配置 nginx

配置一个 [[笔记/point/nginx|nginx]] 反向代理

```nginx
server {
    listen 80;
    server_name jenkins.kentxxq.com;
    return 301 https://$server_name$request_uri;
    access_log /usr/local/nginx/conf/hosts/logs/jenkins.kentxxq.com.log k-json;
}

server {
    listen 443 ssl http2;
    server_name jenkins.kentxxq.com;
    access_log /usr/local/nginx/conf/hosts/logs/jenkins.kentxxq.com.log k-json;

    # 普通header头,ip之类的
    include /usr/local/nginx/conf/options/normal.conf;
    # 证书相关
    include /usr/local/nginx/conf/options/ssl_kentxxq.conf;

    location / {
        proxy_pass http://172.16.0.58:8080;
    }
}
```

### 配置 jenkins

1. 查看 `/root/.jenkins/secrets/initialAdminPassword` 拿到密码
2. 安装插件，可能会有一些插件报错。这是因为我们的 jenkins 不是最新版本，而我们的插件源是最新的版本，我们晚点处理。继续做下面的步骤
3. 在 `admin管理界面` 通常会有 `升级jenkins的选项`，升级然后重启 jenkins
4. 再次检查插件是否有问题，有问题的话就更新或重装插件。

## 使用

### 流水线示例

1. 参数化构建过程, 字符参数 `branch`, 默认值 `prod`
2. 配置流水线

```groovy
pipeline{
    agent any
    environment{
        PRO_GROUP = 'prod'
        PROJECT = 'ooo'
        GIT_URL = "https://git.kentxxq.com/xxx/ooo.git"
        GIT_DIR = "/opt/git/$PRO_GROUP/$PROJECT"
        HOST='目标IP地址'
        
        JAVA_DIR="/app/$PROJECT"
        JAVA_NAME = 'ooo.jar'
        PROT=9077
        PKG_DIR = "$GIT_DIR/ooo/target"
        // SCRIPTS_FILE = "$JAVA_DIR/app.sh restart  $JAVA_NAME"
        SCRIPTS_FILE = "supervisorctl stop ooo ; supervisorctl start ooo"
    }
    stages{    
        stage(' git pull'){
         steps{
                // "*/${branch}" 无法使用sha256发版
                checkout([$class: 'GitSCM', branches: [[name: "${env.branch}"]],
                doGenerateSubmoduleConfigurations: false, 
                extensions: [[$class: 'RelativeTargetDirectory', 
                relativeTargetDir: "$GIT_DIR"]],
                submoduleCfg: [], 
                userRemoteConfigs: [[credentialsId: 'gitlab_xiangqiang',
                url: "$GIT_URL"]]])
              }
          }
        stage('mvn package'){
            steps{
                sh "cd $GIT_DIR/  && mvn clean package -Pprod"        
                // sh "cd $GIT_DIR/  && mvn clean install -U -Dmaven.test.skip=true -Ptest"
            }
        }
         stage('scp java'){
              steps{
                  sh "ansible $HOST -m synchronize -a 'src=$PKG_DIR/$JAVA_NAME dest=$JAVA_DIR' "
                //   sh "ansible $HOST2 -m synchronize -a 'src=$PKG_DIR/$JAVA_NAME dest=$JAVA_DIR' "
              }
          }
          stage('restart java'){
              steps{
                  sh  "ansible $HOST -m shell -a '$SCRIPTS_FILE'"
              }
          }
}

}
```

## 参考资料

- 所有的内置变量 [jenkins.chinnshi.com/env-vars.html/](https://jenkins.chinnshi.com/env-vars.html/)
- [Jenkins常用插件汇总以及简单介绍 | 二丫讲梵](https://wiki.eryajf.net/pages/2280.html#_18-hidden-parameter-plugin)
- [mafeifan 的编程技术分享 | mafeifan 的编程技术分享](https://mafeifan.com/DevOps/Jenkins/Jenkins2-%E5%AD%A6%E4%B9%A0%E7%B3%BB%E5%88%973----Groovy%E8%AF%AD%E6%B3%95%E4%BB%8B%E7%BB%8D.html)
