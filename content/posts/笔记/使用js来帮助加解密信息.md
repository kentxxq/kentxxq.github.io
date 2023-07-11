---
title: 使用js来帮助加解密信息
tags:
  - blog
  - js
date: 2019-05-29
lastmod: 2023-07-11
categories:
  - 笔记
keywords:
  - "js"
  - "nodejs"
  - "express"
  - "解密"
description: "编程语言多种多样。但是常见在视野中的，就那么一些。其中js就是一个无法忽视的存在。自从有了nodejs，前端迅速得开始了自己的工程化道理。各种框架满天飞。号称一切能用js来写的东西，都可以用js写出来。我本人对js是无感的。论性能没有静态语言好，论快捷没有python好，论黑魔法没有ruby好。要说跨平台展示，也有很多的方案不比js差。但是你架不住它的确是web的标准。。再怎么不搭理它，你也要懂它"
---

## 简介

编程语言多种多样。但是常见在视野中的，就那么一些。其中 [[笔记/point/js|js]] 就是一个无法忽视的存在。

自从有了 nodejs，前端迅速得开始了自己的工程化道理。各种框架满天飞。号称一切能用 js 来写的东西，都可以用 js 写出来。

我本人对 js 是无感的。论性能没有静态语言好，论快捷没有 python 好，论黑魔法没有 ruby 好。要说跨平台展示，也有很多的方案不比 js 差。

但是你架不住它的确是 web 的标准。。再怎么不搭理它，你也要懂它。

## 初衷

最近是一直在看 flutter，同时在学着做一个 app。以后要是有需要，我起码也有个东西可以展示一下。

现在的网站大多数都进行了反爬虫，反盗链等等处理。算是对自身版权的一种保护措施。无可厚非。也让你在学习的道路上接触到了更多的知识面。

出于学习的目的，我也就要迎难而上了。

## html 代码被 js 加密

### 分析页面

在 `91porn` 的**视频播放页**。

在 chrome 浏览器中有 mp4 地址，但是我在抓取完页面以后，没有找到 video 标签的 mp4 信息。

原因就在下面这一段

```js
document.write(strencode("Y31+QVcpMF49ISQcEQIVdn5TEn8xJyV6CBMJTiEHLgIYWSNwO1JWS3Q8BU88TV4sESYmFwQIOhYnFHhxIyYCRTcuflgPGAVXegUkFDkeNDQrWhJtXC8CERcaFAc8JS8vES41RQUKMwF7IDBTejdeSBgQEBM+DB4lGTIdYQBsMwsHVBtFFCUVMCtXVh19dlMc","35073qz4grffroXO4azOUodLDj16nSIwU3vAw8128Vn8p4gXrbwmHrwnhP5DmO71Tj/wl+Tn+Rruh/rsr6uY9kXaFORTYNCBEyc1asim+tub4c50UDIkqHGKPzOTc+f2MgA5NbCFgegj","Y31+QVcpMF49ISQcEQIVdn5TEn8xJyV6CBMJTiEHLgIYWSNwO1JWS3Q8BU88TV4sESYmFwQIOhYnFHhxIyYCRTcuflgPGAVXegUkFDkeNDQrWhJtXC8CERcaFAc8JS8vES41RQUKMwF7IDBTejdeSBgQEBM+DB4lGTIdYQBsMwsHVBtFFCUVMCtXVh19dlMc"));
```

我对 js 的方法不是很熟，于是谷歌了一下，发现 strencode 是一个编码库，或者说是一个加密库。

于是我在页面请求的资源中，搜索 strencode，定位到了 md5.js 中。

```js
;var encode_version = 'sojson.v5', lbbpm = '__0x33ad7',  __0x33ad7=['QMOTw6XDtVE=','w5XDgsORw5LCuQ==','wojDrWTChFU=','dkdJACw=','w6zDpXDDvsKVwqA=','ZifCsh85fsKaXsOOWg==','RcOvw47DghzDuA==','w7siYTLCnw=='];(function(_0x94dee0,_0x4a3b74){var _0x588ae7=function(_0x32b32e){while(--_0x32b32e){_0x94dee0['push'](_0x94dee0['shift']());}};_0x588ae7(++_0x4a3b74);}(__0x33ad7,0x8f));var _0x5b60=function(_0x4d4456,_0x5a24e3){_0x4d4456=_0x4d4456-0x0;var _0xa82079=__0x33ad7[_0x4d4456];if(_0x5b60['initialized']===undefined){(function(){var _0xef6e0=typeof window!=='undefined'?window:typeof process==='object'&&typeof require==='function'&&typeof global==='object'?global:this;var _0x221728='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';_0xef6e0['atob']||(_0xef6e0['atob']=function(_0x4bb81e){var _0x1c1b59=String(_0x4bb81e)['replace'](/=+$/,'');for(var _0x5e3437=0x0,_0x2da204,_0x1f23f4,_0x3f19c1=0x0,_0x3fb8a7='';_0x1f23f4=_0x1c1b59['charAt'](_0x3f19c1++);~_0x1f23f4&&(_0x2da204=_0x5e3437%0x4?_0x2da204*0x40+_0x1f23f4:_0x1f23f4,_0x5e3437++%0x4)?_0x3fb8a7+=String['fromCharCode'](0xff&_0x2da204>>(-0x2*_0x5e3437&0x6)):0x0){_0x1f23f4=_0x221728['indexOf'](_0x1f23f4);}return _0x3fb8a7;});}());var _0x43712e=function(_0x2e9442,_0x305a3a){var _0x3702d8=[],_0x234ad1=0x0,_0xd45a92,_0x5a1bee='',_0x4a894e='';_0x2e9442=atob(_0x2e9442);for(var _0x67ab0e=0x0,_0x1753b1=_0x2e9442['length'];_0x67ab0e<_0x1753b1;_0x67ab0e++){_0x4a894e+='%'+('00'+_0x2e9442['charCodeAt'](_0x67ab0e)['toString'](0x10))['slice'](-0x2);}_0x2e9442=decodeURIComponent(_0x4a894e);for(var _0x246dd5=0x0;_0x246dd5<0x100;_0x246dd5++){_0x3702d8[_0x246dd5]=_0x246dd5;}for(_0x246dd5=0x0;_0x246dd5<0x100;_0x246dd5++){_0x234ad1=(_0x234ad1+_0x3702d8[_0x246dd5]+_0x305a3a['charCodeAt'](_0x246dd5%_0x305a3a['length']))%0x100;_0xd45a92=_0x3702d8[_0x246dd5];_0x3702d8[_0x246dd5]=_0x3702d8[_0x234ad1];_0x3702d8[_0x234ad1]=_0xd45a92;}_0x246dd5=0x0;_0x234ad1=0x0;for(var _0x39e824=0x0;_0x39e824<_0x2e9442['length'];_0x39e824++){_0x246dd5=(_0x246dd5+0x1)%0x100;_0x234ad1=(_0x234ad1+_0x3702d8[_0x246dd5])%0x100;_0xd45a92=_0x3702d8[_0x246dd5];_0x3702d8[_0x246dd5]=_0x3702d8[_0x234ad1];_0x3702d8[_0x234ad1]=_0xd45a92;_0x5a1bee+=String['fromCharCode'](_0x2e9442['charCodeAt'](_0x39e824)^_0x3702d8[(_0x3702d8[_0x246dd5]+_0x3702d8[_0x234ad1])%0x100]);}return _0x5a1bee;};_0x5b60['rc4']=_0x43712e;_0x5b60['data']={};_0x5b60['initialized']=!![];}var _0x4be5de=_0x5b60['data'][_0x4d4456];if(_0x4be5de===undefined){if(_0x5b60['once']===undefined){_0x5b60['once']=!![];}_0xa82079=_0x5b60['rc4'](_0xa82079,_0x5a24e3);_0x5b60['data'][_0x4d4456]=_0xa82079;}else{_0xa82079=_0x4be5de;}return _0xa82079;};if(typeof encode_version!=='undefined'&&encode_version==='sojson.v5'){function strencode(_0x50cb35,_0x1e821d){var _0x59f053={'MDWYS':'0|4|1|3|2','uyGXL':function _0x3726b1(_0x2b01e8,_0x53b357){return _0x2b01e8(_0x53b357);},'otDTt':function _0x4f6396(_0x33a2eb,_0x5aa7c9){return _0x33a2eb<_0x5aa7c9;},'tPPtN':function _0x3a63ea(_0x1546a9,_0x3fa992){return _0x1546a9%_0x3fa992;}};var _0xd6483c=_0x59f053[_0x5b60('0x0','cEiQ')][_0x5b60('0x1','&]Gi')]('|'),_0x1a3127=0x0;while(!![]){switch(_0xd6483c[_0x1a3127++]){case'0':_0x50cb35=_0x59f053[_0x5b60('0x2','ofbL')](atob,_0x50cb35);continue;case'1':code='';continue;case'2':return _0x59f053[_0x5b60('0x3','mLzQ')](atob,code);case'3':for(i=0x0;_0x59f053[_0x5b60('0x4','J2rX')](i,_0x50cb35[_0x5b60('0x5','Z(CX')]);i++){k=_0x59f053['tPPtN'](i,len);code+=String['fromCharCode'](_0x50cb35[_0x5b60('0x6','s4(u')](i)^_0x1e821d['charCodeAt'](k));}continue;case'4':len=_0x1e821d[_0x5b60('0x7','!Mys')];continue;}break;}}}else{alert('');};
```

这一大串密密麻麻/花里胡哨的东西，了解过代码混淆的人，应该就知道是混淆过的代码。

用 [js工具](http://jsnice.org/) 解析后变成了比较容易理解的代码，这是一个解密的算法实现。格式化后的代码可以跳到 `解密代码` 部分查看。

### 解决办法

到这里，一般有 3 种方法来继续你的工作

1. 把这一大段的 js 翻译成 dart。缺点是耗时耗力，如果加密算法修改，你可能要重新来过。之前我的 python 爬虫就是这样的，不过那个加密算法才几行而已。
2. 如果语言有工具支持运行 js，那么就好办了。js 自己跑 js 代码肯定没问题。而 v8 就是用 c++ 写的，c++ 肯定有库可以调用。java1.8 版本也有 js 引擎。c#则有 jint。而 python 则是调用本机的 node 环境，速度不理想。而我写 flutter 没有找到这种方法。
3. 用 headless 浏览器来解析页面，然后把拿到最终结果。把地址解析出来。在 flutter 中也就是使用 webview 插件。缺点很慢很重。

于是我想到了远程 api 来执行代码。

## 搭建基于 nodejs 的 web 服务

### web 代码

搜了一下，[express](https://expressjs.com/zh-cn/starter/hello-world.html) 貌似在 nodejs 里是很火的 web 框架。

于是基于 helloWorld 改了一点点。代码如下

```js
//web框架
var express = require('express');
//body的解析工具
var bodyParser = require('body-parser');
var app = express();
var f = require('./decode')

//一些解析设置
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.get('/', function (req, res) {
    res.send('Hello World!');
});

app.post('/', function (req, res) {
    //验证是不是合法的请求
    if (req.body.token === 'qwer') {
        data = f(req.body.param1, req.body.param2)
        res.send(data)
    } else {
        res.send('fuck you!');
    }
});

app.listen(3000, function () {
    console.log('Example app listening on port 3000!');
});
```

### 解密代码

这个是 `decode.js` 文件的代码,我包成了一个方法，补上了几个用到的的变量。

```js
'use strict';

module.exports = function (data1, data2) {
    //补上的变量
    var len;
    var code;
    var i;
    var k;

    /** @type {string} */
    var encode_version = "sojson.v5";
    /** @type {string} */
    var lbbpm = "__0x33ad7";
    /** @type {!Array} */
    var __0x33ad7 = ["QMOTw6XDtVE=", "w5XDgsORw5LCuQ==", "wojDrWTChFU=", "dkdJACw=", "w6zDpXDDvsKVwqA=", "ZifCsh85fsKaXsOOWg==", "RcOvw47DghzDuA==", "w7siYTLCnw=="];
    (function (data, i) {
        /**
         * @param {number} isLE
         * @return {undefined}strencode
         */
        var write = function (isLE) {
            for (; --isLE;) {
                data["push"](data["shift"]());
            }
        };
        write(++i);
    })(__0x33ad7, 143);
    /**
     * @param {string} name
     * @param {string} ll
     * @return {?}
     */
    var _0x5b60 = function (name, ll) {
        /** @type {number} */
        name = name - 0;
        var result = __0x33ad7[name];
        if (_0x5b60["initialized"] === undefined) {
            (function () {
                var jid = typeof window !== "undefined" ? window : typeof process === "object" && typeof require === "function" && typeof global === "object" ? global : this;
                /** @type {string} */
                var listeners = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
                if (!jid["atob"]) {
                    /**
                     * @param {?} i
                     * @return {?}
                     */
                    jid["atob"] = function (i) {
                        var str = String(i)["replace"](/=+$/, "");
                        /** @type {number} */
                        var bc = 0;
                        var bs;
                        var buffer;
                        /** @type {number} */
                        var Y = 0;
                        /** @type {string} */
                        var pix_color = "";
                        for (; buffer = str["charAt"](Y++); ~buffer && (bs = bc % 4 ? bs * 64 + buffer : buffer, bc++ % 4) ? pix_color = pix_color + String["fromCharCode"](255 & bs >> (-2 * bc & 6)) : 0) {
                            buffer = listeners["indexOf"](buffer);
                        }
                        return pix_color;
                    };
                }
            })();
            /**
             * @param {string} data
             * @param {!Object} fn
             * @return {?}
             */
            var testcase = function (data, fn) {
                /** @type {!Array} */
                var secretKey = [];
                /** @type {number} */
                var y = 0;
                var temp;
                /** @type {string} */
                var testResult = "";
                /** @type {string} */
                var tempData = "";
                /** @type {string} */
                data = atob(data);
                /** @type {number} */
                var val = 0;
                var key = data["length"];
                for (; val < key; val++) {
                    /** @type {string} */
                    tempData = tempData + ("%" + ("00" + data["charCodeAt"](val)["toString"](16))["slice"](-2));
                }
                /** @type {string} */
                data = decodeURIComponent(tempData);
                /** @type {number} */
                var x = 0;
                for (; x < 256; x++) {
                    /** @type {number} */
                    secretKey[x] = x;
                }
                /** @type {number} */
                x = 0;
                for (; x < 256; x++) {
                    /** @type {number} */
                    y = (y + secretKey[x] + fn["charCodeAt"](x % fn["length"])) % 256;
                    temp = secretKey[x];
                    secretKey[x] = secretKey[y];
                    secretKey[y] = temp;
                }
                /** @type {number} */
                x = 0;
                /** @type {number} */
                y = 0;
                /** @type {number} */
                var i = 0;
                for (; i < data["length"]; i++) {
                    /** @type {number} */
                    x = (x + 1) % 256;
                    /** @type {number} */
                    y = (y + secretKey[x]) % 256;
                    temp = secretKey[x];
                    secretKey[x] = secretKey[y];
                    secretKey[y] = temp;
                    testResult = testResult + String["fromCharCode"](data["charCodeAt"](i) ^ secretKey[(secretKey[x] + secretKey[y]) % 256]);
                }
                return testResult;
            };
            /** @type {function(string, !Object): ?} */
            _0x5b60["rc4"] = testcase;
            _0x5b60["data"] = {};
            /** @type {boolean} */
            _0x5b60["initialized"] = !![];
        }
        var functionEntry = _0x5b60["data"][name];
        if (functionEntry === undefined) {
            if (_0x5b60["once"] === undefined) {
                /** @type {boolean} */
                _0x5b60["once"] = !![];
            }
            result = _0x5b60["rc4"](result, ll);
            _0x5b60["data"][name] = result;
        } else {
            result = functionEntry;
        }
        return result;
    };
    if (typeof encode_version !== "undefined" && encode_version === "sojson.v5") {
        /**
         * @param {?} key
         * @param {!Object} object
         * @return {?}
         */
        var strencode = function (key, object) {
            var self = {
                "MDWYS": "0|4|1|3|2",
                "uyGXL": function _cancelTransitioning(cb, TextureClass) {
                    return cb(TextureClass);
                },
                "otDTt": function handleSlide(isSlidingUp, $cont) {
                    return isSlidingUp < $cont;
                },
                "tPPtN": function handleSlide(isSlidingUp, $cont) {
                    return isSlidingUp % $cont;
                }
            };
            var callbackVals = self[_0x5b60("0x0", "cEiQ")][_0x5b60("0x1", "&]Gi")]("|");
            /** @type {number} */
            var callbackCount = 0;
            for (; !![];) {
                switch (callbackVals[callbackCount++]) {
                    case "0":
                        key = self[_0x5b60("0x2", "ofbL")](atob, key);
                        continue;
                    case "1":
                        /** @type {string} */
                        code = "";
                        continue;
                    case "2":
                        return self[_0x5b60("0x3", "mLzQ")](atob, code);
                    case "3":
                        /** @type {number} */
                        i = 0;
                        for (; self[_0x5b60("0x4", "J2rX")](i, key[_0x5b60("0x5", "Z(CX")]); i++) {
                            k = self["tPPtN"](i, len);
                            code = code + String["fromCharCode"](key[_0x5b60("0x6", "s4(u")](i) ^ object["charCodeAt"](k));
                        }
                        continue;
                    case "4":
                        len = object[_0x5b60("0x7", "!Mys")];
                        continue;
                }
                break;
            }
        };
    } else {
        alert("");
    }
    ;
    return strencode(data1, data2)
}
```

### 测试

把代码跑起来。测试成果 ojbk！

![[附件/js解密_测试.png]]

## 总结

后续我就只要把页面的参数用正则表达式弄出来。然后发送给我自己的服务器，就能获得地址啦！

为什么我这样做呢？因为我有一台自己的服务器。后续在一些其他的应用中，我也会有更多这样的需求。所以搭建一个这样的 web 服务是非常值得的。

不得不说哪怕你再怎么骂，js 都是程序员的必经之路。
