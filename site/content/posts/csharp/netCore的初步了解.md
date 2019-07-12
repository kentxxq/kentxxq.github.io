---
title:  netCore的初步了解
date:   2019-06-13 10:21:00 +0800
categories: ["笔记"]
tags: ["C#",".NET Core"]
keywords: ["C#",".NET Core","visual studio","微软","跨平台开发","委托","事件","匿名函数","linq"]
description: "如果让我来搭建一个web项目。那我肯定采用前后端分离。如果要选择用什么语言来进行后端开发。快速开发我一定选择python。而需要性能且服务器数量少的时候，静态语言我会选c#。所以就选择来初步了解一下net core以及一些语法特性。文章中很多都只是给到了文档的链接，是因为官方文档非常详细。自己抄过来没有意义，同时链接到的地址也会有最新变化。要学好编程，官方文档是必看的。哪怕是英文版"
---


> 如果让我来搭建一个web项目。那我肯定采用前后端分离。

> 如果要选择用什么语言来进行后端开发。快速开发我一定选择python。而需要性能且服务器数量少的时候，静态语言我会选c#。

> 所以就选择来初步了解一下net core以及一些语法特性。

> 文章中很多都只是给到了文档的链接，是因为官方文档非常详细。自己抄过来没有意义，同时链接到的地址也会有最新变化。要学好编程，官方文档是必看的。哪怕是英文版


安装所需工具
===

[Visual Studio](https://docs.microsoft.com/zh-cn/visualstudio)是宇宙第一ide这句话，大家也多多少少有过了解了。安装好以后，开发环境就弄好了。


初步搭建
===

看[官方文档的Web API](https://docs.microsoft.com/zh-cn/aspnet/core/web-api)就ok。


C#开发的方便之处
===

1. models模块直接自动生成！直接可以配合linq使用。
2. 新增控制器，直接把增删改查都做好了。只需要加入一丢丢的业务逻辑即可！
3. 如果使用的是Azure云服务，还可以一键上云，也太方便了。。

上面的几点，让我觉得比python开发速度还要快。

C#的委托
---

根据一点基础的了解。我认为委托让C#有了**把函数作为参数传递**的解决方案。

C#的匿名函数其实是委托的一种简写。

C#的箭头函数其实就是匿名函数的另一种表达方式。

C#的linq语法可以完全等价转换到箭头函数，也可以说是基于委托实现的。

C#的事件是特殊的委托。

我所遇到的问题
===

测试API
---

一直用postman来对后端测试。老是切换来切换去。还得自己一个一个路径来写文档。

然后发现有[Swagger](https://swagger.io/tools/swagger-ui/)。神器啊！

用Nuget安装依赖Swashbuckle.AspNetCore后，在`Startup.cs`的**ConfigureServices**加入代码

```cs
services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Info { Title = "My API", Version = "v1" });
});

```

Configure的`app.UseMvc()`前加入代码

```cs
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
});
app.UseMvc();
```

之后访问`https://localhost:5001/swagger`就能看到惊喜了！

数据库连接池
---

按照官方文档，我的Models文件夹是通过`Scaffold-DbContext`命令生成的。之后移除掉

在`appsettings.json`中加入**连接字符串**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "BloggingDatabase": "Data Source=your_server_ip;Database=your_database_name;User ID=your_username;Min Pool Size=10;Password=your_password;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False"
  }
}
```


在`Startup.cs`的**ConfigureServices中移除AddDbContext**，加入代码

```cs
services.AddDbContextPool<BloggingContext>(
    options => { options.UseSqlServer(Configuration.GetConnectionString("BloggingDatabase")); },poolSize:64
) ;
```

请求`https://localhost:5001/api/blogs`,报错

An unhandled exception occurred while processing the request.  

InvalidOperationException: The DbContext of type 'BloggingContext' cannot be pooled because it does not have a single public constructor accepting a single parameter of type DbContextOptions.  

Microsoft.EntityFrameworkCore.Internal.DbContextPool<TContext>..ctor(DbContextOptions options)  


百思不得其解。解决办法是

在`BloggingContext`的代码中，BloggingContext有两个构造函数。

```cs
//删掉我
public BloggingContext()
{
}
//
public BloggingContext(DbContextOptions<BloggingContext> options)
    : base(options)
{
}
```

只需要删除掉无参构造函数即可!

sqlite的Models生成
---

在使用的时候要注意netCore的2.2版本有ef命令，但是3开始就会分离出来。

如果web项目无法运行(存在报错)，极有可能无法成功执行！
```bash
dotnet ef dbcontext  scaffold "Data Source=test.db" -o Models Microsoft.EntityFrameworkCore.Sqlite -c "TestDbContext" -f
```

从Models生成数据库
---

cli
```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

vs的pm包管理控制台
```bash
Add-Migration InitialCreate
Update-Database
```

EF Core的使用
---

`EF Core`是c#的orm框架。支持查询语法和linq。非常好用！

在我所了解到的语言中，我认为是完善度和易用性最高的了！几乎杜绝了我使用裸sql语句的可能！

在我的web api中，我试着写了这么一段linq代码
```c#
[HttpGet]
public async Task<ActionResult<IEnumerable<dynamic>>> GetUsers()
{
    var a = from user1 in _testDbContext.Users
            join user2 in _testDbContext.TUsers
            on new { username = user1.Username, password = user1.Password }
            equals new { username = user2.Username, password = user2.Password }
            select new
            {
                user1.Username,
                user2.Password
            };
    // return await a.ToAsyncEnumerable(); 错误示例
    // return await a.ToAsyncEnumerable().ToList(); 纠正
    return await a.ToListAsync();
}
```

先说明几点:

1. 由于返回的数据是`select new`出来的对象，所以我的返回值使用了`dynamic`。方便以后更改字段。也不用再新建字段。
2. `async`方法代表异步，后面必须要跟`Task`。而`ActionResult`代表返回特定的类型。而对比指定的类型返回有什么好处呢？它可以通过`IActionResult`简化操作。**并且**可以返回多个类型。比如存在数据则返回200，不存在则返回404错误，很明显它们两个的结构类型不一致。

而我在编写这段代码的时候，产生了疑惑。我最开始是按照上面的注释代码写的。发现报错，怎么都不对。

这里需要注意的是。我的返回类型是`IEnumerable<dynamic>`,所以我就写了`ToAsyncEnumerable`。而Enumerable的用法是循环取出数据。无法直接await后去返回。

参考这[一篇博客](https://www.claudiobernasconi.ch/2013/07/22/when-to-use-ienumerable-icollection-ilist-and-list/)，总结一下使用方法。

1. `public interface IEnumerable<out T> : IEnumerable`只能遍历使用
2. `public interface ICollection<T> : IEnumerable<T>, IEnumerable`你关心它的大小
3. `public interface IList<T> : ICollection<T>, IEnumerable<T>, IEnumerable`你要修改它并且需要排序
4. `List<>`则是一个实现。

List是继承于接口IEnumerable的，所以返回List是可以的。



总结
===

现在学习一下netcore，以后net5统一平台后，估计我就要全面深入使用了。

最近蛮堕落的。。没有写什么代码，也没有更新什么文章。就连电影都没怎么看。赶紧写完去撸我的app。