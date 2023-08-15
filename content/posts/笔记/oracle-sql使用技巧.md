---
title: oracle-sql使用技巧
tags:
  - blog
  - oracle
date: 2023-07-06
lastmod: 2023-08-15
categories:
  - blog
description: "因为以前的公司是用 [[笔记/point/oracle|oracle]],所以也记录了不少的命令. 记录一下后续使用."
---

## 简介

因为以前的公司是用 [[笔记/point/oracle|oracle]],所以也记录了不少的技巧. 记录一下后续使用.

## 使用技巧

### 字段操作

```sql
# 字符串截取
substr(t.family_no,0,6)='433127'
# 日期转换
systimestamp 时间戳
sysdate 日期
to_date('20170101','yyyymmdd')
to_char(sysdate,'YYYY-MM-DD HH24:MI:SS')
# 值判断
CASE WHEN A.STR7 IS NULL THEN '0' ELSE '0001' END  AS haha,
# 类似case when,v1就取r1,v2就取r2
DECODE(column_name, 'value1', 'result1', 'value2', 'result2', 'default_result')
# 长度判断
where length(a.id_card)>=14
# 在列表中
where D.IDENTITY IN('0001','17','20','19')
# 值为null就默认0
NVL(A.CIVIL_MONEY,0)
# 转数字
to_number(NVL(A.STR5,0)
```

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

#### 查看执行计划

```sql
select /*+ gather_plan_statistics */
        * 
        from 
table(dbms_xplan.display_cursor(NVL('ajkqn4733r2qx',NULL),NULL,'ALL ALLSTATS LAST PEEKED_BINDS cost partition -projection -outline'));
```

#### 查看 session 执行的 sql

```sql
SELECT 
    c.spid,
    b.sql_text, 
    a.sid, 
    a.serial#, 
    osuser, 
    machine  
FROM v$session a, v$sqlarea b ,v$process c
WHERE a.sql_address = b.address and a.paddr=c.addr and spid=&pid; 
```
