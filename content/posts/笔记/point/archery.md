---
title: archery
tags:
  - point
  - archery
date: 2023-08-14
lastmod: 2023-08-14
categories:
  - point
---

`archery` 是一个 `sql` 审计工具.

要点:

- 开源
- 免费

对接 LDAP:

```
AUTH_LDAP_SERVER_URI = "ldap://ldap.kentxxq.com"
AUTH_LDAP_BING_DN = "cn=ldap,CN=Users,ou=Ken,dc=kentxxq,dc=com"
AUTH_LDAP_BING_PASSWORD = '密码'
AUTH_LDAP_CONNECTION_OPTIONS = {
    ldap.OPT_DEBUG_LEVEL: 1,
    ldap.OPT_REFERRALS: 0,
}
AUTH_LDAP_USER_SEARCH = LDAPSearch(
    'ou=Ken,dc=kentxxq,dc=com',
     ldap.SCOPE_SUBTREE,
     '(cn=%(user)s)'
)
```
