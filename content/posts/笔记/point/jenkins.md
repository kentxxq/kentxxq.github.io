---
title: jenkins
tags:
  - point
  - jenkins
date: 2023-07-27
lastmod: 2023-07-27
categories:
  - point
---

`jenkins` 是一个非常流行的 [[笔记/point/CICD|CICD]] 工具

要点:

- 开源
- 免费
- 用户量大

### 流水线示例

1. 参数化构建过程, 字符参数 `branch`,默认值 `prod`
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
