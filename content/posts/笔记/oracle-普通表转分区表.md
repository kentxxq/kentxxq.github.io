---
title: oracle-普通表转分区表
tags:
  - blog
  - oracle
date: 2018-12-20
lastmod: 2023-08-16
categories:
  - blog
keywords:
  - "oracle"
  - "普通表"
  - "分区表"
description: "oracle普通表转分区表"
---

## 简介

[[笔记/point/oracle|oracle]] 有很多的版本，现在的话，常用的有 11g，12cR1/R2。都有不同的方法  
对于数据库，我是不推荐使用外键，存储过程，或者触发器的。除非对数据需要超高度的一致性要求，同时不规范的数据，是属于不允许的  

1. 数据库的拓展需要添加 `新的集群存储`，`新的机器部署oracle服务`，`很难像应用服务器一样动态部署`，相反拓展服务器更加简单。承担了这一部分的数据库压力  
2. 外键是也是有 `性能消耗` 的，同时内部加锁，更容易出现 `死锁` 问题
3. 尽量少的数据库约束，越方便数据之间的 `解耦合`。否则你会发现所有的表都互相依赖。牵一发而动全身
4. 应用应该知道自己的操作是在干嘛，而不是考虑不周，让写在数据库里的 `潜规则` 告诉你必须如何
5. 方便 `读写分离`，更好的解决了数据库写方面的压力，而读数据的锁几乎没有压力

## 转换

### 操作前提

1. 主键
2. 拥有自己的逻辑 id，而不是业务 id 主键。否则不方便以后的水平拓展
3. 使用 oracle 提供的包来检测是否可行

### 12cR1 和 11g

```sql
--检查可用性
EXEC DBMS_REDEFINITION.can_redef_table(UNAME => 'QX_HENGSHAN',TNAME => 'A20181220_2');
 
--开始重定义
DBMS_REDEFINITION.START_REDEF_TABLE(
   uname                 => 'STEVE',
   orig_table            => 'salestable',
   int_table             => 'int_salestable1, int_salestable2, int_salestable3',
   col_mapping           => NULL,
   options_flag          => DBMS_REDEFINITION.CONS_USE_ROWID,
   part_name             => 'sal03q1,sal03q2,sal03q3',
   continue_after_errors => TRUE);

--开始拷贝数据
DBMS_REDEFINITION.COPY_TABLE_DEPENDENTS(
  uname => 'AKAHALI',
  orig_table => 'ST1',
  int_table => 'T1',
  num_errors => lvn_errs
  );

--完成重定义
dbms_redefinition.finish_redef_table(
  uname => 'AKAHALI',
  orig_table => 'ST1',
  int_table => 'T1'
  );
```

### 12cR2

```sql
ALTER TABLE table_name MODIFY table_partitioning_clauses
  [ filter_condition ]
  [ ONLINE ]
  [ UPDATE INDEXES [ ( index { local_partitioned_index | global_partitioned_index | GLOBAL }
                     [, index { local_partitioned_index | global_partitioned_index | GLOBAL } ]... )
                   ]
  ]

--实例
alter table emp modify
    partition by range (deptno) interval (10)
      ( partition p1 values less than (10),
        partition p2 values less than (20)
      ) online
    update indexes
      (idx_emp_no local);
```

## 导入

### 创建分区表

> 中小型的系统或者 olap 类型适合分区表，后期超大存储，建议用分布式

```sql
--一般分区表推荐这样建立两层，了解业务，自己来进行分层
   partition by list(center_no)
 subpartition by list(join_year)
        subpartition template (
           subpartition SP_2014
           VALUES  ('2014'),
           subpartition SP_2015
           values ('2015'),
           subpartition SP_2016
           values ('2016')
       )
   (
       partition
            p_433127
           values ('433127'),
       partition
            P_433122
           values ('433122'),
       partition
            P_433101
           values ('433101')
    );

```

### 减少 log 并插入数据

```shell
# 关闭log
alter table xxx NOLOGGING;
# 加速插入数据
INSERT /*+append*/ into 用户.表名(字段,字段)
select ... from xxx
# 恢复log
ALTER TABLE tt_nh_canhe_members LOGGING;
```
