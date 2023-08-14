---
title: python-工具脚本
tags:
  - blog
  - python
date: 2023-08-14
lastmod: 2023-08-14
categories:
  - blog
description: 
---

## 简介

[[笔记/point/python|python]] 的小工具脚本和示例.

## 内容

### pywinrm

远程操作 [[笔记/point/windows|windows]] 机器

```python
host = winrm.Session(
    "10.0.216.207", ("主机\\用户名", "密码"), transport="ntlm"
)

result = host.run_cmd(cmd)

print(result.status_code)
print(result.std_out.decode("gbk"))
```

### selenium 示例

```python
# coding:utf-8

from selenium import webdriver

options = webdriver.ChromeOptions()
options.headless = True
options.add_argument('--ignore-certificate-errors-spki-list')
options.add_argument('--ignore-ssl-errors')
options.add_argument('--disable-gpu')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--no-sandbox')
driver = webdriver.Chrome(executable_path='/usr/local/bin/chromedriver', options=options)

driver.get('https://kentxxq.com')

print(driver.page_source)
```

### 拼音处理

```python
from pypinyin import pinyin, Style

name = "黄先桃"
py_name_list = pinyin(name, Style.NORMAL)

first_name = py_name_list[0:1][0][0]

second_name = ""
for word in py_name_list[1:]:
    second_name += word[0]
    
full_name = ""
for word in py_name_list:
    full_name += word[0]

print(py_name_list)
print(full_name)
print(first_name)
print(second_name)

cmd = f'dsadd user "cn={full_name},OU=TZEDU,dc=tzict,dc=cn" -pwd TZ#Eb2xpn -pwdneverexpires yes -fn  {second_name} -ln {first_name} -display {full_name} -desc {name} -email {full_name}@mail.tanzk.com -memberof "cn=wiki,OU=TZEDU,dc=tzict,dc=cn"'

print(cmd)
```

### sqlalchemy 生成 models

```shell
sqlacodegen postgresql:///some_local_db
sqlacodegen mysql+oursql://user:password@localhost/dbname
sqlacodegen sqlite:///database.db

# 指定输出文件
--outfile models.py
# 默认输出对象类
# 指定输出为table对象
--noclasses

sqlacodegen sqlite:///test.db --noclasses --outfile app/models.py

sqlacodegen mysql+pymysql://用户名:密码@地址.mysql.rds.aliyuncs.com/om_all --noclasses --outfile app/models.py


flask-sqlacodegen --flask mysql+pymysql://用户名:'密码'@IP地址/数据库名 --outfile model.py
```

### pyinstaller 打包

命令 | 解释
---|---
-F | 单个文件，通常单个文件这样
-D, –onedir | 打包成文件夹，适合框架类型
-c | 控制台应用
-w | 窗口应用
-p | 依赖包的路径
-d | debug 模式
–version-file | windows 版本信息
-m, --manifest | windows 的 manifest 文件
--distpath DIR | 程序输出路径
-y, --noconfirm | 修改输出路径而不用确认
--clean | 构建前清理缓存和临时文件
-i | 应用图标
--add-binary | 加二进制文件
--add-data | 加文件或文件夹

```powershell
# 打包成单个文件
# 如果没有资源文件，可以考虑使用这个
pyinstaller.exe -c -p E:\kentxxq_code\pytest\.venv\Lib\site-packages -F .\test.py

# 打包成目录形式
# 如果有资源文件之类的，推荐打包成文件夹
pyinstaller.exe -c -p E:\kentxxq_code\pytest\.venv\Lib\site-packages --add-data "E:/kentxxq_code/pytest/Pipfile;." --clean -D .\test.py
```
