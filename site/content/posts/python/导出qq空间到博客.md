---
title:  python导出qq空间到博客
date:   2019-01-13 00:00:00 
categories: ["笔记"]
tags: ["python"]
keywords: ["oracle","qq空间","博客"]
description: "既然有了自己的博客，把以前的黑历史啥的都搬过来吧。毕竟这个网站我是打算用很久很久的。我只保存了所有的照片，所有的留言板都是对我单独的对话，所有的说说都是我的一个日记。"
---

> 既然有了自己的博客，把以前的黑历史啥的都搬过来吧。毕竟这个网站我是打算用很久很久的。我只保存了所有的照片，所有的留言板都是对我单独的对话，所有的说说都是我的一个日记。

1. 先用一个[老哥的开源代码](https://github.com/wwwpf/QzoneExporter)把数据跑下来
2. 把照片都传到google相册
3. 把留言板弄成md，然后把e101类似的表情手动对比替换了。。。主要是没有文档，还不如手动来得快

```python
# coding:utf-8

import os
import json
import arrow
import re

head = """
---
title:  qq空间黑历史
date:   2019-01-14 00:00:00 
categories: ["黑历史"]
tags: ["留言板"]
---
"""

path = '/Users/kentxxq/kent_code/QzoneExporter/805429509/msg_board'

files = os.listdir(path)
files = sorted(files)

p_html = re.compile('\[.*?\]')


with open('/Users/kentxxq/kent_code/blog/site/content/posts/lines/qq空间黑历史.md', 'w') as f:
    f.write(head)
    f.write('\n')
    f.write('\n')
    for file in files:
        with open(path + '/' + file, 'r') as m:
            datas = json.load(m)['data']['commentList']
            for data in datas:
                pubtime = data['pubtime']
                f.write(pubtime+'\n')
                f.write('===' + '\n')
                nickname = data['nickname']
                f.write(nickname + '\n')
                f.write('\n')
                content = data['ubbContent']
                content = p_html.sub('', content)
                f.write(content + '\n')
                f.write('\n')

```
**把说说制作成md文章,同时把``去掉**
```python
# coding:utf-8

import os
import json
import arrow
import re

head = """
---
title:  qq空间说说
date:   2019-01-15 00:00:00 
categories: ["黑历史"]
tags: ["说说"]
---
"""

path = '/Users/kentxxq/kent_code/QzoneExporter/805429509/shuoshuo'

files = os.listdir(path)
files = sorted(files)

p_html = re.compile('\[.*?\]')


with open('/Users/kentxxq/kent_code/blog/site/content/posts/life/qq空间说说.md', 'w') as f:
    f.write(head)
    f.write('\n')
    f.write('\n')
    for file in files:
        if file.endswith('.json'):
            with open(path + '/' + file, 'r') as m:
                datas = json.load(m)['msglist']
                for data in datas:
                    createTime = data['createTime']
                    f.write(createTime + '\n')
                    f.write('===' + '\n')

                    f.write('**')
                    content = data['content']
                    f.write(content)
                    f.write('**')
                    f.write('\n')
                    f.write('\n')
                    if 'lbs' in data.keys():
                        if data['lbs'] is not None:
                            f.write('`')
                            f.write(data['lbs']['name'])
                            f.write('`')
                            f.write('\n')
                    f.write('\n')
                    f.write('\n')
                    if 'commentlist' in data.keys():
                        for comment in data['commentlist']:
                            f.write('-=-=-=-=-'+comment['name'] + ':')
                            f.write(comment['content'])
                            f.write('\n')
                            f.write('\n')
                    f.write('\n')

```