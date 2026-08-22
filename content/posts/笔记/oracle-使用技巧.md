---
title: oracle-使用技巧
tags:
  - blog
  - oracle
date: 2023-07-06
lastmod: 2023-08-30
categories:
  - blog
description: "因为以前的公司是用 [[笔记/point/oracle|oracle]],所以也记录了不少的命令. 记录一下后续使用."
---

## 简介

因为以前的公司是用 [[笔记/point/oracle|oracle]],所以也记录了不少的技巧. 记录一下后续使用.

## SQL 操作

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

### 加速插入

```sql
alter table x nologging;
insert /*+append*/ into x (a,b,c) as select a,b,c from xxx;
```

### 批量删除

```sql
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
```

### 两表数据同步

```sql
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

## 维护操作

### 新建表空间, 用户, 授权等

```sql
# 新建表空间
create tablespace xo datafile 'f:/xo.dbf' size 50m autoextend on;
# 新建临时表空间
create temporary tablespace tempfile 'f:/xo.dbf' size 50m autoextend on;
# 表空间添加文件
alter tablespace sales add datafile '/home/app/oracle/oradata/oracle8i/sales02.dbf' size 800M autoextend on next 50M maxsize 1000M; 
# 数据库文件大小重置
alter database datafile ‘dir’ resize 1000m;

# 新建用户
create user test identified by test default tablespace xo temporary tablespace test_temp;
# 修改用户密码
alter user test identified by 123456;
# 删除用户
drop user test cascade;

# 授权角色
grant dba,connect,resource to test;
# 授权表操作
grant select on v$session to test;
```

### 收集统计信息

```sql
execute dbms_stats.gather_table_stats(ownname => 'owner',tabname => 'table_name' ,estimate_percent => null ,method_opt => 'for all indexed columns' ,cascade => true)
```

### 客户端字符集

```sql
NLS_LANG="AMERICAN_AMERICA.ZHS16GBK"
```

### 用户表大小排名

```sql
select OWNER, 
t.segment_name, t.segment_type, sum(t.bytes / 1024 / 1024) mmm
from dba_segments t
where t.owner = 'XIANGXI' 
and t.segment_type='TABLE'
group by OWNER, t.segment_name, t.segment_type
order by mmm desc;
```

### 触发器 trigger

```sql
alter trigger xx_trigger disable;
alter trigger xx_trigger enable;
```

### 索引 index

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

### 闪回 flashback
```shell
# 启用闪回
startup mount;
alter database archivelog;
alter database flashback on;
alter database open;

# 开启行移动后,才能执行闪回
alter table xx enable movement;
# 闪回表到5分钟前
flashback table xx as of timestamp sysdate-5/1440;
flashback table t_canhe_family to timestamp (systimestamp-interval '5' minute);

# 查询5分钟前
select * from table as of timestamp sysdate-5/1440;

# 还原表
flashback table xx to before drop；
```

### 缩小表 shrink

```sql
alter table my_objects enable row movement;
alter table my_objects shrink space;
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

## 排错

### 活动的 session

```sql
select s.SID,  
       s.SERIAL#,  
       'kill -9 ' || p.SPID,  
       s.MACHINE,  
       s.OSUSER,  
       s.PROGRAM,  
       s.USERNAME,  
       s.last_call_et,  
       a.SQL_ID,  
       s.LOGON_TIME,  
       a.SQL_TEXT,  
       a.SQL_FULLTEXT,  
       w.EVENT,  
       a.DISK_READS,  
       a.BUFFER_GETS  
  from v$process p, v$session s, v$sqlarea a, v$session_wait w  
 where p.ADDR = s.PADDR  
   and s.SQL_ID = a.sql_id  
   and s.sid = w.SID  
   and s.STATUS = 'ACTIVE'  
 order by s.last_call_et desc;  
```

### 锁表查询

```sql
 SELECT l.session_id sid, s.serial#, l.locked_mode,l.oracle_username,

　　l.os_user_name,s.machine, s.terminal, o.object_name, s.logon_time

　　FROM v$locked_object l, all_objects o, v$session s

　　WHERE l.object_id = o.object_id

　　AND l.session_id = s.sid

　　ORDER BY sid, s.serial# ;
```

### 生成 AWR

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
