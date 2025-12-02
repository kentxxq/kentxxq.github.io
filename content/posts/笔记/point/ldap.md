---
title: ldap
aliases:
  - LDAP
tags:
  - point
  - LDAP
date: 2023-08-30
lastmod: 2023-08-30
categories:
  - point
---

`ldap` 是一个目录访问协议. 通过树状目录结构, 对人员/资源进行分类, 权限管理.

要点:

- 很多工具都对接了. 例如 [[笔记/point/gitlab|gitlab]], [[笔记/point/jenkins|jenkins]]

## 相关资源

- [phpLDAPadmin](https://github.com/leenooks/phpLDAPadmin) 是一个 web-ui 工具:  `docker run --rm -p 6443:443 --env PHPLDAPADMIN_LDAP_HOSTS=localhost -d osixia/phpldapadmin:latest`
- `osixia/openldap` 可以用于快速搭建一个 ldap 服务.

    ```shell
    docker run --rm --hostname ldap.kentxxq.com -p 389:389 -p 636:636 --name myopenldap --env LDAP_DOMAIN="ldap.kentxxq.com" --env LDAP_ADMIN_PASSWORD="密码" --env LDAP_TLS_VERIFY_CLIENT=try osixia/openldap:latest
    ```

- `ldapsearch` 可以用来 debug. `ldapsearch -x -H ldaps://ldap.kentxxq.com -b dc=ldap,dc=kentxxq,dc=com -D "cn=admin,dc=ldap,dc=kentxxq,dc=com" -w "密码"`
