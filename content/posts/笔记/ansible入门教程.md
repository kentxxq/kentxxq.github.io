---
title: ansible入门教程
tags:
  - blog
  - ansible
date: 2023-07-01
lastmod: 2024-05-06
categories:
  - blog
description: "[[笔记/point/ansible|ansible]] 的使用记录, 用到的时候能快速重新捡起来.."
---

## 简介

[[笔记/point/ansible|ansible]] 的使用记录, 用到的时候能快速重新捡起来..

## 安装配置

1. 安装 `apt install ansible sshpass -y`
2. 配置主机

   ```shell
   vim /etc/ansible/hosts
   # test组有一台机器,并配置了ssh连接信息
   [test]
   sh-ecs01 ansible_ssh_host=test.kentxxq.com ansible_ssh_user="root" ansible_ssh_pass="123456" ansible_ssh_port=22

   vim /etc/ansible/ansible.cfg
   [defaults]
   host_key_checking = False    #不检测host key.我们采用的是密码访问,所以这么做可以加快速度
   ```

## 日常操作

简单执行命令

```shell
ansible test -m shell -a "ls"
```

使用 `ansible-playbook playbook.yml` 执行脚本, 下面是脚本文件

```yml
---
- name: Install remote facts
  hosts: test
  vars:
    test_dir: /tmp/test_dir
    test_file: /tmp/test.txt
  # 禁用收集信息，可以加快脚本执行
  # gather_facts: false
  tasks:
    - name: 先ping一下
      ping:
    - name: echo输出
      command: echo 1
    - name: 准备工作-创建测试目录 "{{ test_dir }}"
      file:
        path: "{{ test_dir }}"
        state: directory
        owner: "root"
        group: "root"
        mode: 0755

    # 输出ansible默认采集到的信息
    #- name: debug输出ansible默认收集的变量
    #  debug:
    #    var: ansible_facts

    - name: 计算剩余内存百分比
      debug:
        msg: "{{ ansible_facts.memory_mb.nocache.free / ansible_facts.memtotal_mb * 100 }}"
      register: memory_usage_percent
    - name: 拿到register变量
      debug:
        msg: "{{ memory_usage_percent.msg }}"

    - name: 再register一个远程输出
      shell: hostname
      register: hostname_info
    - name: 拿到hostname_info变量
      debug:
        msg: "{{ hostname_info.stdout }}"

    - name: 创建本地文件
      copy:
        content: "123"
        dest: "{{ test_file }}"
      delegate_to: localhost

    - name: 传送文件
      copy:
        src: "{{ test_file }}"
        dest: "{{ test_file }}"

    - name: 本地执行命令
      local_action: command tar -zcvf /tmp/tmp.tgz /tmp/test.txt

    # 压缩和解压
    - name: "拷贝代码去到对应目录"
      unarchive:
        src: "/tmp/tmp.tgz"
        dest: "{{ test_dir }}"
        owner: "root"
        group: "root"
        extra_opts:
          - --strip-components= 1
```

## Role 方案

### 目录结构

```shell
root@poc:~/ansible-role# tree
.
├── \
├── deploy_java_role.yml # 入口文件
├── inventory
│   └── test-hosts # 主机文件
└── roles
    └── deploy_java_role
        ├── tasks
        │   ├── depoly-task.yml # 部署任务
        │   ├── init-app-task.yml # 初始化app环境
        │   ├── init-system-task.yml # 初始化系统环境
        │   ├── main.yml # 主入口
        │   └── vars-task.yml # 获取环境变量
        ├── templates
        │   └── supervisor_conf_template.j2 # 模板文件
        └── vars
            └── main.yml # 静态环境变量
```

### 调用方法

```shell
# 部署到了 deploy-task 阶段会报错,因为并没有 java 包,也没有 jenkins. 但是思路是一致的. 从本地 copy 构建物到目标机器.

# 指定role文件,-i指定hosts文件,然后外部传入参数
ansible-playbook deploy_java_role.yml \
-i inventory/test-hosts \
--extra-vars "ip_list=demo_test1" \
--extra-vars "java_params='-Xms256m -Xmx256m'" \
--extra-vars "module_name=name" \
--extra-vars "init=1"
```

### 文件内容

```yml
# role入口文件
# deploy_java_role.yml
---
- hosts: "{{ ip_list }}"
  remote_user: root
  roles:
    - role: deploy_java_role
  serial: 1
  max_fail_percentage: 0



# 主机文件
# inventory/test-hosts
[demo_test1]
sh-ecs01 ansible_ssh_host=1.1.1.1 ansible_ssh_user="root" ansible_ssh_pass="123456" ansible_ssh_port=22



# 主入口
# roles/deploy_java_role/tasks/main.yml
---
- name: 构建环境变量
  import_tasks: vars-task.yml
- name: 初始化环境
  import_tasks: init-system-task.yml
  when: init == "1"
- name: 应用所需环境
  import_tasks: init-app-task.yml
  when: init == "1"
- name: 部署脚本
  import_tasks: depoly-task.yml


# 获取环境变量
# roles/deploy_java_role/tasks/vars-task.yml
- name: 获取workspace变量
  debug:
    msg: "{{ lookup('env', 'WORKSPACE')}}"
  register: JenkinsWorkspace
  #failed_when: JenkinsWorkspace.msg == ''

# 初始化系统环境
# roles/deploy_java_role/tasks/init-system-task.yml
- name: 安装Supervisor启动管理程序
  package:
    name: supervisor
    state: present
- name: 开机自启supervisor
  service:
    name: supervisor
    enabled: yes
- name: 创建程序运行目录 "{{ program_dir }}"
  file:
    path: "{{ program_dir }}"
    state: directory
    owner: "{{ appuser }}"
    group: "{{ appuser }}"
    mode: 0755
- name: 创建程序备份目录 "{{ program_dir_backup }}"
  file:
    path: "{{ program_dir_backup }}"
    state: directory
    owner: "{{ appuser }}"
    group: "{{ appuser }}"
    mode: 0755
- name: 创建程序运行日志目录 "{{ program_dir_logs }}"
  file:
    path: "{{ program_dir_logs }}"
    state: directory
    owner: "{{ appuser }}"
    group: "{{ appuser }}"
    mode: 0755
- name: 创建程序运行临时目录 "{{ program_dir_tmp }}"
  file:
    path: "{{ program_dir_tmp }}"
    state: directory
    owner: "{{ appuser }}"
    group: "{{ appuser }}"
    mode: 0755
- name: 启动supervisor
  service:
    name: supervisor
    state: started



# 初始化app环境
# roles/deploy_java_role/tasks/init-app-task.yml
- name: 判断启动文件 "{{ module_name }}".ini是否存在
  stat:
    path: /etc/supervisor/conf.d/{{ module_name }}.conf
  register: init_file
  
- name: 如果启动文件不存在就拷贝一份启动模板文件 "{{ module_name }}".ini 到目标主机
  template:
    src: supervisor_conf_template.j2
    dest: /etc/supervisor/conf.d/{{ module_name }}.conf
  when: init_file.stat.exists == false
  
- name: 更新supervisor
  shell: supervisorctl update
  when: init_file.stat.exists == false


# 部署任务
# roles/deploy_java_role/tasks/depoly-task.yml
- name: "获取当前时间"
  shell: date +%F_%H%M%S
  register: date_result

- name: "获取{{ module_name }}构建物的名称"
  find:
    paths:
      - "{{ JenkinsWorkspace.msg }}/deploy/target"
    file_type: file
    use_regex: yes
    patterns: ".*{{ module_name }}((?!sources).)*.jar$"
    recurse: no
  register: artcraft
  delegate_to: localhost

- name: "判断构建物是否存在，不存在则退出"
  fail:
    msg: "{{ module_name }}.jar is not find"
  when: artcraft.matched == 0

- name: "复制Jenkins构建物{{ module_name }}到对应服务器的指定目录"
  copy:
    src: "{{ item.path }}"
    dest: "{{ program_dir_tmp }}/{{ module_name }}.jar"
    owner: "{{ appuser }}"
    group: "{{ appuser }}"
    mode: "0644"
    force: yes
    #backup: yes
  with_items: "{{ artcraft.files }}"

- name: 注册.部署前.程序运行状况并注册状态
  shell: ps -ef | grep {{ module_name }} | grep {{ appuser }} | awk '{print $2}'
  ignore_errors: True
  register: artcraft_status

- name: 回显并注册当前进程PID信息
  debug:
    var: artcraft_status.stdout_lines[0]
    verbosity: 0
  when: artcraft_status.stdout_lines[1]  is defined

- name: 提示当前进程没有运行
  debug:
    msg: "当前用户服务进程没有运行...部署继续..."
  when: artcraft_status.stdout_lines[1] is undefined

- name: 停止{{ module_name }}对应的服务
  command: supervisorctl stop {{ module_name }}
  when: artcraft_status.stdout_lines[1]  is defined
  register: artcraft_stop_status

- name: 回显当前程序状态是否停止成功
  debug:
    var: artcraft_stop_status
    verbosity: 0
  when: artcraft_status.stdout_lines[1]  is defined

- name: 注册.部署前.最新软件包的地址
  shell: ls -lt {{ program_dir_tmp }} | grep {{ module_name }} | head -n 1 |awk '{print $9}'
  ignore_errors: True
  register: artcraft_file

- name: 回显当前程序artcraft_file信息
  debug:
    var: artcraft_file
    verbosity: 0

- name: 备份并复制{{ module_name }}的构建物到指定目录
  copy:
    src: "{{ program_dir_tmp }}/{{ artcraft_file.stdout }}"
    dest: "{{ program_dir }}/{{ appuser }}/{{ module_name }}.jar"
    owner: "{{ appuser }}"
    group: "{{ appuser }}"
    mode: "0644"
    backup: yes
    remote_src: yes

- name: 启动{{ module_name }}服务
  command: supervisorctl start {{ module_name }}
  register: artcraft_start_status

- name: 等待{{ module_name }}服务正常收敛...
  wait_for:
    port: "{{ port }}"
    delay: 10
    timeout: 60
  when: port != "0"

- name: 回显当前服务{{ module_name }}状态信息
  debug:
    var: artcraft_start_status
    verbosity: 0

#- name: 更新服务的IP信息
#  uri:
#    url: "{{ register_url }}/appinfo/v2/add"
#    method: POST
#    body_format: json
#    body: { "name":"{{ module_name }}","updatetime":"{{ date_result.stdout_lines[0] }}","ip":"{{  play_hosts | join(',') }}","env":"{{ deploy_env }}","project":"{{ module_name }}","note":"" }
#  register: _register_service

#- name: 返回结果成功
#  debug: "msg={{ _register_service }}"



# 静态环境变量
# roles/deploy_java_role/vars/main.yml
---
company: kentxxq
appuser: root
program_dir: /usr/local/program
program_dir_tmp: /usr/local/program/tmp
program_dir_backup: /usr/local/program/backup
program_dir_logs: /usr/local/program/logs



# 模板文件
# roles/deploy_java_role/templates/supervisor_conf_template.j2
[program:{{ module_name }}]
# 运行程序 相对PATemplateTH 可以使用参数
command = java -Dfile.encoding=UTF-8 {{ java_params }} -jar {{ program_dir }}/{{ module_name }}.jar
# 启动进程数目默认为1
numprocs = 1
# 如果supervisord是root启动的 设置此用户可以管理该program
user = root
# 程序运行的优先级 默认999
priority = 997
# 随着supervisord 自启动
autostart = true
# 子进程挂掉后w无条件自动重启
autorestart = true
# 子进程启动多少秒之后 状态为running 表示运行成功
startsecs = 20
# 进程启动失败 最大尝试次数 超过将把状态置为FAIL
startretries = 3
# 标准输出的文件路径
stdout_logfile =  {{ program_dir_logs }}/{{ module_name }}-supervisor.log
# 日志文件最大大小
stdout_logfile_maxbytes=20MB
# 日志文件保持数量 默认为10 设置为0 表示不限制
stdout_logfile_backups = 30
```
