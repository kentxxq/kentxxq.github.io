---
title: oracle配置和命令
tags:
  - blog
  - oracle
date: 2023-07-06
lastmod: 2023-07-06
categories:
  - blog
description: "因为以前的公司是用 [[笔记/point/oracle|oracle]],所以也记录了不少的命令. 记录一下后续使用."
---

## 简介

因为以前的公司是用 [[笔记/point/oracle|oracle]],所以也记录了不少的命令. 记录一下后续使用.

## 命令

### 索引

```sql
# 快速创建索引
create index idx_table_a on table_a(字段a,字段b) nologging parallel  4;
```

### 删除操作

```sql
# 加速插入
alter table x nologging;
insert /*+append*/ into x (a,b,c) as select a,b,c from xxx;

# 批量删除.根据时间排序,1000条commmit一次
declare
     cursor [del_cursor] is select a.*, a.rowid row_id from [table_name] a order by a.rowid;
begin
     for v_cusor in [del_cursor] loop
          if v_cusor.[time_stamp] < to_date('2014-01-01','yyyy-mm-dd') then
               delete from [table_name] where rowid = v_cusor.row_id;
          end if;
          if mod([del_cursor]%rowcount,1000)=0 then
               commit;
          end if;
     end loop;
     commit;
end;

# 两表数据同步
MERGE INTO t_canhe_family t1 USING(select a1.family_id,a1.account_money,a1.balance,a1.remaining_money from t_canhe_family_bak20161121 a1) tt ON (tt.family_id=t1.family_id)
when matched then
update set t1.account_money=tt.account_money,
t1.balance=tt.balance,
t1.remaining_money=tt.remaining_money


```

### sql 优化

```sql
# 查看执行计划
select /*+ gather_plan_statistics */* 
       from 
table(dbms_xplan.display_cursor(NVL('ajkqn4733r2qx',NULL),NULL,'ALL ALLSTATS LAST PEEKED_BINDS cost partition -projection -outline'));
```
