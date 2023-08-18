---
title: oracle-使用技巧
tags:
  - blog
  - oracle
date: 2023-07-06
lastmod: 2023-08-16
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

### 收集统计信息

```sql
execute dbms_stats.gather_table_stats(ownname => 'owner',tabname => 'table_name' ,estimate_percent => null ,method_opt => 'for all indexed columns' ,cascade => true)
```

### 触发器

```sql
alter trigger xx_trigger disable;
alter trigger xx_trigger enable;
```

### 索引

```sql
# 快速创建索引
create index idx_table_a on table_a(字段a,字段b) nologging parallel  4;
```

### 重建所有索引

```sql
declare
  STR VARCHAR2(400);
begin
  -- 重建Oracle索引
  FOR TMP_IDX IN (SELECT TABLESPACE_NAME, OWNER, TABLE_NAME, INDEX_NAME
                    FROM ALL_INDEXES
                   WHERE OWNER = 'HNACMS'
                     AND temporary = 'N'     
                     --AND TABLE_NAME = 'K_TASK'              
                     --AND TABLESPACE_NAME <> 'HNACMS_INDX'
                   ORDER BY TABLESPACE_NAME, TABLE_NAME) LOOP
    STR := 'ALTER INDEX ' || TMP_IDX.OWNER || '.' || TMP_IDX.INDEX_NAME ||
           ' Rebuild Tablespace HNACMS_INDX';
    EXECUTE IMMEDIATE STR;
  END LOOP;
end;

```

### 日志切换时间

```sql
select  b.SEQUENCE#, 
    b.FIRST_TIME,a.SEQUENCE#,
    a.FIRST_TIME,round(((a.FIRST_TIME-b.FIRST_TIME)*24)*60,2) 
from v$log_history a, 
     v$log_history b 
where a.SEQUENCE#=b.SEQUENCE#+1 
    and b.THREAD#=1 
order by a.SEQUENCE# desc;
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

#### sql-tuning

创建并执行 `tuning` 任务

```sql
DECLARE
       my_task_name VARCHAR2(300);
       my_sqltext   CLOB;
     BEGIN
       my_sqltext := 'select
a.join_year,a."FAMILY_INFO_ID",a."FAMILY_NO",a."CARD_NO",a."FAMILY_NO" as BOOK_NO ,a."CENTER_NO",a."AREA_NO",a."COUNTRY_NO",
substr(a."FAMILY_NO",-4,4) as DOOR_NO,a."MASTER_NO",a."ADDRESS",a."POSTALCODE",a."PHONECODE",a."LINKMAN",a."EMAIL",a."POPULATION",
a."FARMER",a."FARMER_STAY",a."JOIN_PROP",a."DOOR_PROP",a."RPR_TYPE",a."INOUT_FLAG",a."INOUT_DATE",a."INOUT_REASON",a."SALVATION",
a."REGISTER",a."REGISTER_DATE",a."BOOK_STATE",a."CARD_STATE",a."FAMILY_STATE",a."AUDI_MAN",a."AUDI_STATE",a."AUDI_TIME",a."UPDATE_TIME",
a."UPDATE_MAN",a."CREATE_TIME",a."CREATE_MAN",a."COMMENTS",a."IS_DEL",a."FRONT_STATE_D301",a."STR1",a."STR2",a."STR3",a."STR4",a."STR5",
a."ZHEN_NO",a."CUN_NO",a."MASTER_NAME"

from T_NH_CANHE_FAMILYS a
where  a.is_del=1
and exists (select 1 from t_nh_dict_area x where a.country_no=x.countrycode and x.state=1)';
       my_task_name := DBMS_SQLTUNE.CREATE_TUNING_TASK(
               sql_text    => my_sqltext,
               user_name   => 'XIANGXI',   -- 必须大写
               scope       => 'COMPREHENSIVE',
               time_limit  => 20,
               task_name   => 'tuning_sql_test',
               description => 'Task to tune a query on a specified table');
       DBMS_SQLTUNE.EXECUTE_TUNING_TASK( task_name => 'tuning_sql_test');
     END;
```

查看具体内容:

```sql
select dbms_sqltune.report_tuning_task('tuning_sql_test') from dual;
```

使用完毕后删除:

```sql
//sys用户删除
delete from dba_advisor_tasks where task_name ='tuning_sql_test'
```

## 生成 AWR

SQL 路径在 `oracle_home/rdbms/admin/awrrpt.sql`,可以参考 [手工生成AWR报告方法记录\_ITPUB博客](http://blog.itpub.net/17203031/viewspace-700471/)

```powershell
sqlplus sys/oracle as sysdba /nolog
@oracle_home/rdbms/admin/awrrpt.sql
# 按照提示输入即可
# 其中文件名，可以填好路径。方便后面使用
```

## 常用图表

- 数据文件: `dba_data_file`
- 临时表空间: `dba_temp_file`
- 数据库使用的 directory 路径: `dba_directories`
- 会话: `v$ssesion`. 其中 `sid,serial#` 用于杀死会话. `paddr` 用于关联 `v$proccess的addr`,关闭系统进程.
- 进程: `v$proccess`. 其中 `spid` 用 `kill -9` 杀死进程. `addr` 管理 `v$ssesion`
- SQL 文本: `v$sqlarea`. `sql_id,hash_value` 用于锁定 sql. `sql_fulltext` 全部 sql 语句，不会因为太长而截断
- 查看所有的 dblink: `dba_db_links`
- 空闲表空间: `dba_free_space`
- 分区表视图:
    `ALL_PART_TABLES` 通过 table_name，找到分区表的概况信息.
    `dba_tab_subpartitions` 分区表的详细信息 其中有分区名、子分区名
- 分区表查询
    select * from table partition (分区名)
    Select * from table subpartition (子分区名)
- 约束视图: `dba_constraints`
