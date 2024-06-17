---
title: echarts
tags:
  - point
  - echarts
date: 2024-06-12
lastmod: 2024-06-14
categories:
  - point
---

`echarts` 是一个流行的图表 js 库.

- 开源
- 用的人多

## 常用

### 折线图

```ts
const option = ref<EChartsOption>({
    title: {
        text: "请求数走势图"
    },
    tooltip: {
        trigger: 'axis'
    },
    toolbox: {
        show: true,
        feature: {
            dataView: { readOnly: false },
            // restore: {},
            saveAsImage: {}
        }
    },
    xAxis: {
        type: 'category',
        boundaryGap: false,
        data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    },
    yAxis: {
        type: 'value'
    },
    series: [
        {
            data: [150, 230, 224, 218, 135, 147, 260],
            type: 'line',
            smooth: true
        }
    ]
});
```

### 日期折线图

主要区别在于 `xAxis.type` 是 `time`

```ts
const option = ref<EChartsOption>({
    title: {
        text: "请求数走势图"
    },
    tooltip: {
        trigger: 'axis'
    },
    toolbox: {
        show: true,
        feature: {
            dataView: { readOnly: false },
            // restore: {},
            saveAsImage: {}
        }
    },
    xAxis: {
        type: 'time',// type为time时,不要传xAxis.data的值,x轴坐标的数据会根据传入的时间自动展示
    },
    yAxis: {
        type: 'value'
    },
    series: [
        {
            data: [['2020-10-1', 450], ['2020-10-2', 100], ['2020-10-3', 100], ['2020-10-4', 100], ['2020-10-5', 100], ['2020-10-6', 100], ['2020-10-7', 100]],
            type: 'line',
            smooth: true
        }
    ]
});
```

## 其他

- `2024-06-14` 的全量引入大小为 517/186 kb , 719/236 kb
