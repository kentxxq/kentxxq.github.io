---
title: mongodb
tags:
  - point
  - mongodb
date: 2023-07-06
lastmod: 2023-07-06
categories:
  - point
---

`mongodb` 是一个文本型数据库. 不同于 [[笔记/point/mysql|mysql]] 等关系型数据库.

要点:

- 免费
- 和 [[笔记/point/JavaScript|js]] 匹配度高

### 导入导出

```shell
# 导出库db_a
mongodump -d db_a

# 从db_a文件夹导入库
mongorestore -d db_a db_a/
```
