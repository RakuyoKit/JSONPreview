<p align="center">
<img src="https://raw.githubusercontent.com/RakuyoKit/JSONPreview/master/Images/logo.png" alt="JSONPreview" title="JSONPreview" width="1000"/>
</p>

<p align="center">
<a href="https://swiftpackageindex.com/RakuyoKit/JSONPreview"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FRakuyoKit%2FJSONPreview%2Fbadge%3Ftype%3Dswift-versions"></a>
<a href="https://swiftpackageindex.com/RakuyoKit/JSONPreview"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FRakuyoKit%2FJSONPreview%2Fbadge%3Ftype%3Dplatforms"></a>
<a href="https://cocoapods.org/pods/JSONPreview"><img src="https://img.shields.io/github/v/tag/RakuyoKit/JSONPreview.svg?include_prereleases=&sort=semver"></a>
<a href="https://raw.githubusercontent.com/RakuyoKit/JSONPreview/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-black"></a>
</p>

`JSONPreview` 是一个 JSON 预览组件，您可以通过它来**格式化**您的 JSON 数据，并**高亮**展示。除此之外，`JSONPreview` 还提供了**折叠与展开**功能，您可以折叠那些您暂时不关注的节点，并在任意时刻重新展示它。

`JSONPreview` 继承自 `UIView`，并基于 `UITextView` 实现相关功能。整个框架完全基于原生框架实现，这意味着在 Apple 平台上使用本框架时，您可以获得较好的用户体验。

## 预览

下面是一个大约25秒的gif（**大约2.5M**），它展示了使用本库预览 JSON 时的效果。

![screenshot](Images/screenshot.gif)

## 基本要求

- 运行 **iOS 12** 及以上版本的设备。
- 使用 **Xcode 10** 及以上版本编译。
- **Swift 5.0** 及以上版本。

## 安装

### CocoaPods

```ruby
pod 'JSONPreview'
```

### Swift Package Manager

- 依次选择 File > Swift Packages > Add Package Dependency
- 输入 https://github.com/RakuyoKit/JSONPreview.git
- 选择 "Up to Next Major" 并填入 "2.2.3"

或者将下面的内容添加到 `Package.swift` 文件中：

```swift
dependencies: [
  .package(url: "https://github.com/RakuyoKit/JSONPreview.git", from: "2.2.3")
]
```

## 功能

- [x] 支持**格式化**显示 JSON 数据。
- [x] 支持**高亮** JSON 数据，提供多种颜色与字体配置选项。
- [x] 针对 `Array` 与 `Object` 提供**折叠与展开**功能。
- [x] 允许设置节点的初始状态，折叠或展开。
- [x] 基于 `UITextView` 实现。意味着您可以复制 `JSONPreview` 中的任意内容。

> 细节补充：
> 1. `JSONPreview` 提供有限的，不完整的格式检查功能，故该功能不作为主要功能提供。详情可以参考：[格式检查](#格式检查)。
> 2. [1.2.0](https://github.com/RakuyoKit/JSONPreview/releases/tag/1.2.0) 版本支持了对链接的渲染。在渲染的同时，`JSONPreview` 会进行有限的**去转义**操作：支持将 `"\\/"` 替换为 `"/"`。

## 使用

> 下载项目后，[`EntranceTableViewController.swift`](Demo/JSONPreviewDemo/Example/EntranceTableViewController.swift) 文件中包含部分示例代码，运行项目即可查看对应的效果。

### 基础用法及默认配置

1. 首先创建 `JSONPreview` 对象，并添加到界面上：

```swift
let previewView = JSONPreview()
view.addSubview(previewView)
```

2. 调用 `JSONPreview.preview` 方法，以默认样式预览数据：

```swift
let json = "{\"key\":\"value\"}"
previewView.preview(json)
```

### 自定义样式

如果您想要自定义高亮样式，可通过 `HighlightStyle` 与 `HighlightColor` 这两个类型来进行设置：

> [`ConvertibleToColor`](Sources/Entity/HighlightColor.swift#L117) 是一个用于提供颜色的协议。通过该协议，您可以直接使用 `UIColor` 对象，或轻松的将诸如 `0xffffff`、`#FF7F20` 以及  `[0.72, 0.18, 0.13]` 转换为 `UIColor` 对象。

```swift
let highlightColor = HighlightColor(
    keyWord: ConvertibleToColor,
    key: ConvertibleToColor,
    link: ConvertibleToColor,
    string: ConvertibleToColor,
    number: ConvertibleToColor,
    boolean: ConvertibleToColor,
    null: ConvertibleToColor,
    unknownText: ConvertibleToColor,
    unknownBackground: ConvertibleToColor,
    jsonBackground: ConvertibleToColor,
    lineBackground: ConvertibleToColor,
    lineText: ConvertibleToColor
)

let style = HighlightStyle(
    expandIcon: UIImage?,
    foldIcon: UIImage?,
    color: highlightColor,
    lineFont: UIFont?,
    jsonFont: UIFont?,
    lineHeight: CGFloat
)

previewView.preview(json, style: style)
```

您还可以通过 initialState 参数配置 json 子节点的初始状态。

```swift
// 预览时，所有节点默认均为折叠状态
previewView.preview(json, style: style, initialState: .folded)
```

其他更多功能请参考 demo。

## 格式检查

`JSONPreview` 在渲染 JSON 时只进行**有限**的格式检查。

目前已知的会触发 “错误渲染” 的条件，包括：

- Value 非常规 JSON 类型。支持的类型包括 `object`、`array`、`number`、`bool`、`string` 以及 `null`。
- 对于 `number` 格式的检查，例如科学计数法以及小数。
- 针对于 `true`、`false` 以及 `null` 的拼写检查。
- 针对科学计数法，`{E/e}` 的下一个节点必须是 `+`、`-` 或数字。
- `array` 元素之间没有使用 `,` 进行分隔。
- `object` 元素之间没有使用 `,` 进行分隔。
- `object` 的 key 后没有`:`。
- `object` 的 key 后有`:`，但是缺失 value。
- `object` 的 key 不是字符串。

除了上述明确提到的条件，其他错误也可能触发“错误渲染”。另外还有可能有一些错误在格式检查的范围之外，这些错误不会触发“错误渲染”。但是可能**会导致 json 内容的缺失**。

建议您不要过于依赖 `JSONPreview` 的格式检查功能，尽可能用于预览格式正确的 json。

## DFD

![DFD](Images/DFD.jpg)

## TODO

- [ ] 支持 intel 版本的 macOS。

## 致谢

感谢 [Awhisper](https://github.com/Awhisper) 在 `JSONPreview` 的开发过程中提出的宝贵意见。

## License

`JSONPreview` 在 **MIT** 许可下可用。 有关更多信息，请参见 [LICENSE](LICENSE) 文件。
