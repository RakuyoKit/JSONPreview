# JSONPreview

<p align="center">
<img src="https://raw.githubusercontent.com/rakuyoMo/JSONPreview/master/Images/logo.png" alt="JSONPreview" title="JSONPreview" width="1000"/>
</p>

<p align="center">
<a><img src="https://img.shields.io/badge/language-swift-ffac45.svg"></a>
<a href="https://github.com/rakuyoMo/JSONPreview/releases"><img src="https://img.shields.io/cocoapods/v/JSONPreview.svg"></a>
<a href="https://github.com/rakuyoMo/JSONPreview/blob/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/JSONPreview.svg?style=flat"></a>
</p>

`JSONPreview` 继承自 `UIView`。您可以通过它来**格式化**您的 JSON 数据，并**高亮**展示。

同时 `JSONPreview` 还提供**折叠与展开**功能，您可以折叠那些您暂时不关注的节点，并在任意时刻重新展示它。

`JSONPreview` 的全部功能都使用**原生方法**编写，这意味着您可以在 Apple 平台获得较好的使用体验。

## 基本要求

- 运行 **iOS 10** 及以上版本的设备。
- 使用 **Xcode 10** 及以上版本编译。
- **Swift 5.0** 以及以上版本。

## 安装

### CocoaPods

```ruby
pod 'JSONPreview'
```

## 功能

1. 支持**格式化**显示 JSON 数据。
2. 支持**高亮** JSON 数据，提供多种颜色与字体配置选项。
3. 针对 `Array` 与 `Object` 提供**折叠**与**展开**功能。

## 使用

> 下载项目后，[`ViewController.swift`](https://github.com/rakuyoMo/JSONPreview/blob/master/JSONPreview/JSONPreview/Other/ViewController.swift) 文件中包含部分测试代码，运行项目即可查看对应的效果。

1. 首先创建 `JSONPreview` 对象，并添加到界面上：

```swift
let previewView = JSONPreview()

view.addSubview(previewView)
```

2. 调用 `preview(_:style:)` 方法，以默认样式预览数据：

```swift
let json = ...
    
preview(json)
```

3. 如果您想要自定义高亮样式，可通过 `HighlightStyle` 与 `HighlightColor` 类型进行设置：

> 其中，[`ConvertibleToColor`](https://github.com/rakuyoMo/JSONPreview/blob/master/JSONPreview/JSONPreview/Core/HighlightColor.swift#L119) 是一个用于提供颜色的协议。


```swift
let highlightColor = HighlightColor(
    keyWord: <#T##ConvertibleToColor#>,
    key: <#T##ConvertibleToColor#>,
    link: <#T##ConvertibleToColor#>,
    string: <#T##ConvertibleToColor#>,
    number: <#T##ConvertibleToColor#>,
    boolean: <#T##ConvertibleToColor#>,
    null: <#T##ConvertibleToColor#>,
    unknownText: <#T##ConvertibleToColor#>,
    unknownBackground: <#T##ConvertibleToColor#>,
    jsonBackground: <#T##ConvertibleToColor#>,
    lineBackground: <#T##ConvertibleToColor#>,
    lineText: <#T##ConvertibleToColor#>
)

let style = HighlightStyle(
    expandIcon: <#T##UIImage?#>,
    foldIcon: <#T##UIImage?#>,
    color: highlightColor,
    lineFont: <#T##UIFont?#>,
    jsonFont: <#T##UIFont?#>,
    lineHeight: <#T##CGFloat#>
)

previewView.preview(json, style: style)
```
