# schema设计原则

```json
{
  "uuid": "",
  "name": "顶部带图片的上图下文式多功能入口模块",
  "label": "快捷功能模块",
  "sub_label": "横向",
  "usage": "横向排列多个功能入口，包含每个功能的图标，功能的标题以及功能的描述；功能入口上方有一个引导图，适合用于政务办事类的场景，比如带一个社保卡的图片，下方摆几个社保卡的功能入口",
  "layout": "整体使用Grid容器，每个格栅内部对应一个功能item，每个功能item的布局左面是两行文字，右面是表示功能的图标；格栅容器上方放置一张宽度填满的Banner图",
  "en_name": "Grid_BannerHorizontalTextFunctionItem",
  "module_code": "",
  "module_arguments": "icon(Resource):格栅内图标资源,title(string):格栅内标题",
  "module_layout_arguments": "",
  "model": "Grid_BannerHorizontalTextFunctionItemModel",
  "model_code": "",
  "model_arguments": "ICONS(Resource):多功能入口图片,TITLES(StringList):多功能入口标题，不能超过五个字,BANNER_IMAGE(Resource):顶部引导图片",
  "route": [
    {
      "file_name": "EmptyPagePathStack"
    }
  ]
}
```

## 字段说明

| 字段 | 说明 |
| --- | --- |
| name | 模块名称 |
| label | 模块标签，目前仅有搜索模块、订单信息展示模块、图文信息展示模块、快捷功能模块、账号信息模块、订票模块、导航入口模块、店铺信息模块、新闻展示模块 |
| sub_label | 子标签，用于粒度较大的模块，如快捷功能模块、图文信息展示模块，进行 label 内细化 |
| usage | 模块用途说明 |
| layout | 模块外观描述 |
| en_name | 模块代码名称，用于定位模块代码 |
| module_code | 模块代码内容 |
| module_arguments | 模块代码参数，通常为模块大标题等属性，用于模型内容填充 |
| module_layout_arguments | 模块布局参数，用于调整高度、圆角等布局属性，用于模型外观微调 |
| model | 模块用于数据结构封装的 model 文件 |
| model_code | model 文件代码 |
| model_arguments | 模块内容参数，用于模型内容填充 |
