---
title: alist
tags:
  - point
  - alist
date: 2023-08-31
lastmod: 2024-05-14
categories:
  - point
---

## 关于 alist

[alist](https://github.com/alist-org/alist) 是一个支持多存储的网盘/WebDAV 工具. 提供一个统一的 api/webdav/web 访问方式, 管理你的网盘, sftp, 对象存储.

## alist 搭建

### 服务启动

[[笔记/point/docker-compose|docker-compose]] 配置文件 `docker-compose.yml`

```yml
services:
  openlist:
    image: 'openlistteam/openlist:v4.1.2-aria2'
    container_name: openlist
    volumes:
      - '/etc/openlist:/opt/openlist/data'
    ports:
      - '5244:5244'
      - '5246:5246'
    environment:
      - UMASK=022
    restart: unless-stopped
```

### 反向代理

[[笔记/point/nginx|nginx]] 代理配置

```nginx
server {
    listen 80;
    server_name alist.kentxxq.com;
    return 301 https://$server_name$request_uri;

    include /usr/local/nginx/conf/options/normal.conf;
    access_log /usr/local/nginx/conf/hosts/logs/alist.kentxxq.com.log k-json;
}

server {
    listen 443 ssl;
    server_name alist.kentxxq.com;
    client_max_body_size 204800M;

    ssl_certificate /usr/local/nginx/conf/ssl/kentxxq.cer;
    ssl_certificate_key /usr/local/nginx/conf/ssl/kentxxq.key;

    access_log /usr/local/nginx/conf/hosts/logs/alist.kentxxq.com.log k-json;

    location / {
        proxy_pass http://10.0.1.157:5244;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Range $http_range;
	    proxy_set_header If-Range $http_if_range;
        proxy_redirect off;
    }
}
```

## 小雅

### 关于小雅

小雅通过 alist 挂载很多的云盘. 收集整理很多影视文件. 所以

- 站在巨人的肩膀上, 拥有了海量的资源
- 小雅改动了站内搜索, 可以快速搜索出来资源
- 可以挂载文件到自己的 alist

> 如果不自己搭建, 单个账号的请求数太多, 会被封. 同时小雅做了一些改造.
> 同时, 小雅每次在线观看, 会先把文件转存给自己. 然后再播放.

### 官方搭建

搭建小雅, 需要下面 3 个关键信息. 2 个 token 用于刷新 token 和存放文件, 一个 id 用于保存转存的文件.

下面是 [小雅文档](https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f#11fe173d670a4cf59142de0a83c8056f) 里写的配置内容

| 配置              | 对应文件                                | 获取方式                                                            |
| ----------------- | --------------------------------------- | ------------------------------------------------------------------- |
| token             | /etc/xiaoya/mytoken.txt                 | https://alist.nn.ci/zh/guide/drivers/aliyundrive.html               |
| open token        | /etc/xiaoya/myopentoken.txt             | https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html          |
| 临时保存文件的 id | /etc/xiaoya/temp_transfer_folder_id.txt | 在资源库创建一个文件夹.打开这个文件夹的网页版.复制 url 最后的最后一串 |

官网文档的部署操作如下

```shell
bash -c "$(curl http://docker.xiaoya.pro/update_new.sh)"

# 默认用户名密码
用户: guest 密码: guest_Api789
# 禁用guest用户,保证安全
touch /etc/xiaoya/guestlogin.txt

# 配置dav用户,后面都用这个用户
touch /etc/xiaoya/guestpass.txt
# 把dav用户的密码写进去
vim /etc/xiaoya/guestpass.txt

# 配置外网地址,这样tvbox的地址才会变成外网地址
vim docker_address.txt
https://xiaoya.kentxxq.com
vim docker_address_ext.txt
https://xiaoya.kentxxq.com

# 配置生效
docker restart xiaoya
```

### alist-tvbox 部署 (推荐)

**我没有使用上面的官方搭建方式**. 使用了 [别人封装的alist-tvbox](https://github.com/power721/alist-tvbox).
- 可以 ui 管理
- docker 部署运行, 而不是依赖 shell 脚本. 但是我不喜欢这种长 shell 脚本. 像是黑盒子
- 不需要 [xiaoyahelper](https://github.com/DDS-Derek/xiaoya-alist/tree/master/xiaoyahelper) 来定时清理临时文件夹的容器

下面开始部署

**第一步**. 创建一个文件夹 `mkdir xiaoya`, 保存 [[笔记/point/docker-compose|docker-compose]] 文件.

```yaml
services:
xiaoya-tvbox:
  image: haroldli/xiaoya-tvbox
  ports:
    - "127.0.0.1:4567:4567"
    - "10.1.237.15:4567:4567"
    - "127.0.0.1:5344:80"
    - "10.1.237.15:5344:80"
  environment:
    ALIST_PORT: "5344"
  volumes:
    - /etc/xiaoya:/data
  restart: always
  container_name: xiaoya-tvbox
```

- 4567 是管理界面端口. 5344 是小雅的端口
- 两个端口我都配置了只能本地和内网 ip 访问, 因为我准备用 [[笔记/point/nginx|nginx]] 反向代理 https.
- 数据在本地的 `/etc/xiaoya` 里面

**第二步**. 进入 5344 端口的管理界面

- 账号菜单: 添加账号. 把你的账号信息保存上去. 可以通过签到来确定是否配置成功
- 配置菜单
    - 强制登录 alist, 相当于禁用了 guest 账号, 保证安全性
    - 创建新的用户名密码. 用于你登录使用小雅
    - 重启等待一段时间生效. 因为需要抓取最新的资源, 所以通常小雅重启需要一段时间. 可以通过日志菜单确认

### 安装参考文档

- 原版小雅
    - 小雅的文档 [Notion – The all-in-one workspace for your notes, tasks, wikis, and databases.](https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f#11fe173d670a4cf59142de0a83c8056f)
    - [小雅 AList 🐂🐂🐂 - 掘金](https://juejin.cn/post/7304267413615869979#heading-14)
    - [Alist+小雅搭建家庭影视库服务器搭建保姆级教程\_哔哩哔哩\_bilibili](https://www.bilibili.com/video/BV1zc411X79z/?vd_source=3f8a7a9cfa796e140d94e90eb3af4c90)
- alist-tvbox
    - [alist-tvbox文档地址]( https://github.com/power721/alist-tvbox/blob/master/doc/README_zh.md#%E6%95%B0%E6%8D%AE%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D )
    - [Alist V3 无法套娃挂载 xiaoya · Issue #68 · power721/alist-tvbox · GitHub](https://github.com/power721/alist-tvbox/issues/68)
- alist, xiaoya 的周边工具 [GitHub - DDS-Derek/xiaoya-alist: 小雅Alist的相关周边](https://github.com/DDS-Derek/xiaoya-alist)

## 使用

### tvbox

- tvbox 下载地址 [TVBox开发版 – Telegram](https://t.me/s/TVBoxOSC) , 这个版本是开源的 [github构建纪录](https://github.com/o0HalfLife0o/TVBoxOSC)
- tvbox 源/接口地址
    - `alist-tvbox` 的订阅菜单. 有一个 `tvbox配置地址`. 可以给 tvbox 使用.
    - 进恩哥 [工具站点](https://jinenyy.vip/app/tvbox/) , [开源配置](https://github.com/jinenge/tvbox)
    - [一木TVBOX自用仓库](https://github.com/xianyuyimu/TVBOX-)
    - [GitHub - qist/tvbox: FongMi影视、tvbox配置文件，如果喜欢，请Fork自用。使用前请仔细阅读仓库说明，一旦使用将被视为你已了解。](https://github.com/qist/tvbox)
    - [GitHub - mengzehe/TVBox: TVBox自用源以及仓库源、直播源等](https://github.com/mengzehe/TVBox)

### Webdav

#### 播放器

- 安卓
    - [nova-video-player](https://github.com/nova-video-player/aos-AVP)
    - [Reex](https://gitee.com/lntls/reex/releases)
    - [kodi](https://kodi.tv/download/)
- windows
    - [Potplayer](https://potplayer.daum.net/)
- 苹果
    - [Infuse](https://apps.apple.com/us/app/infuse-video-player/id1136220934)
    - [VidHub](https://apps.apple.com/us/app/vidhub-video-library-player/id1659622164)

#### 小米电视

1. 安装当贝市场
2. 在当贝市场安装 KODI (自己搜索的版本没有声音,, 但是当贝市场的没问题)
3. 添加源 `设置=>文件管理=>添加网络位置`
    ![[附件/KODI-添加webdav源.jpg]]

### 离线下载

- 离线下载支持磁力链接, 例如 `magnet:?xt=urn:btih:EF7CE211B79187E4D8DDEB906095027534607EA6&dn=American%20Prometheus%3A%20The%20Triumph%20and%20Tragedy%20of%20J.R.%20Oppenheimer&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.bittor.pw%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Fbt.xxx-tracker.com%3A2710%2Fannounce&tr=udp%3A%2F%2Fpublic.popcorn-tracker.org%3A6969%2Fannounce&tr=udp%3A%2F%2Feddie4.nl%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.tiny-vps.com%3A6969%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce`
