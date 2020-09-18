# JSONPreview

<p align="center">
<img src="https://raw.githubusercontent.com/rakuyoMo/JSONPreview/master/Images/logo.png" alt="JSONPreview" title="JSONPreview" width="1000"/>
</p>

<p align="center">
<a><img src="https://img.shields.io/badge/language-swift-ffac45.svg"></a>
<a href="https://github.com/rakuyoMo/JSONPreview/releases"><img src="https://img.shields.io/cocoapods/v/JSONPreview.svg"></a>
<a href="https://github.com/rakuyoMo/JSONPreview/blob/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/JSONPreview.svg?style=flat"></a>
</p>

> [中文](https://github.com/rakuyoMo/JSONPreview/blob/master/README_CN.md)

`JSONPreview` inherits from `UIView`. You can use it to **format** your JSON data and **highlight** it.

At the same time, `JSONPreview` also provides **folding and unfolding** functions. You can fold the nodes that you don't care about temporarily, and redisplay them at any time.

All functions of `JSONPreview` are written using **native methods**, which means you can get a better experience on the Apple platform.

## Screenshot

![image](https://github.com/rakuyoMo/JSONPreview/blob/master/Images/screenshot.gif)

## Prerequisites

- **iOS 10 or later**.
- **Xcode 10.0 or later** required.
- **Swift 5.0 or later** required.

## Install

### CocoaPods

```ruby
pod 'JSONPreview'
```

## Features

- [x] Support formatting and displaying JSON data.
- [x] Support highlighting JSON data, and provide a variety of color and font configuration options.
- [x] Provide **fold** and **expand** functions for `Array` and `Object`.
- [x] Based on `UITextView`, you can copy any content in `JSONPreview`.

- `JSONPreview` provides a limited and incomplete format check function, so this function is not provided as a main function. For details, please refer to: [Format check](#format_check)

## Usage

> After downloading the project, [`ViewController.swift`](https://github.com/rakuyoMo/JSONPreview/blob/master/JSONPreview/JSONPreview/Other/ViewController.swift) file contains part of the test code, just run the project Check the corresponding effect.

1. Create a `JSONPreview` object and add it to the interface:

```swift
let previewView = JSONPreview()

view.addSubview(previewView)
```

2. Call the `preview(_:style:)` method to preview the data in the default style:

```swift
let json = ...
    
preview(json)
```

3. If you want to customize the highlight style, you can set it through the `HighlightStyle` and `HighlightColor` types:

> Among them, [`ConvertibleToColor`](https://github.com/rakuyoMo/JSONPreview/blob/master/JSONPreview/JSONPreview/Core/HighlightColor.swift#L119) is a protocol for providing colors. Through this protocol, you can directly use the `UIColor` object, or easily convert such objects as `0xffffff`, `#FF7F20` and `[0.72, 0.18, 0.13]` to `UIColor` objects.

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

## Format Check

`JSONPreview` only provides limited format checking functions, including:

> The "previous node" mentioned below does not include ` `, `\t` and `\n`

- The JSON to be previewed must start with `{` or `[`.
- The previous node of `:` must be `String`.
- The previous node of `,` can only be one of `null`, `String`, `Number`, `Boolean`, `}` and `]`.
- `{` must have the previous node, and the previous node cannot be `{`.
- `}` must be paired with `{`.
- `[` The previous node must exist, and the previous node cannot be `]`.
- `]` must be paired with `[`.
- `"` must appear in pairs.
- The previous node of `"` can only be one of `{`, `[`, `,` and `:`.
-Spell check for `null`, `true` and `false`.

## Known issues

1. After the first display, slide to a non-end position, rotate the screen, and the sub-view will be misaligned. Return to normal after sliding. This problem does not occur when screen rotation is prohibited.
2. When collapsing/expanding nodes, there is a possibility of JSON flickering.

## TODO

- [x] Fix known issues.
- [x] Add new integration methods, such as `Carthage` and `Swift Package Manager`.
- [x] Support MacOS.
- [x] More complete copy operation.

## License

`JSONPreview` is available under the **MIT** license. See the [LICENSE](https://github.com/rakuyoMo/JSONPreview/blob/master/LICENSE) file for more info.
