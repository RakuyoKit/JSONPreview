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

Also, `JSONPreview` provides **fold and expand** features that allow you to collapse nodes that you are not interested in at the moment and re-display them at any moment.

All of the features in `JSONPreview` are written using **native methods**, which means you get a great experience on Apple platforms.

## Screenshot

Below is a gif of about 30 seconds (**about 3M**) that shows the effect of previewing JSON using this library.

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

- [x] Supports **formatting** to display JSON data.
- [x] Supports **highlighting** JSON data, with multiple color and font configuration options.
- [x] Provides **fold** and **expand** features for `Array` and `Object`.
- [x] Based on `UITextView`, which means you can copy any content from `JSONPreview`.

- `JSONPreview` provides limited, incomplete format checking functionality, so it is not provided as a primary feature. For details, see: [Format check](#format-check)

## Usage

> After downloading the project, [`ViewController.swift`](https://github.com/rakuyoMo/JSONPreview/blob/master/JSONPreview/JSONPreview/Other/ViewController.swift) file contains part of the test code, just run the project Check the corresponding effect.

1. Create the `JSONPreview` object and add it to the interface.

```swift
let previewView = JSONPreview()

view.addSubview(previewView)
```

2. Call the `preview(_:style:)` method to preview the data in the default style:

```swift
let json = "{\"key\":\"value\"}"

previewView.preview(json)
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

### Rendering

For rendering, `JSONPreview` performs only **limited** format checks, including:

> The following references to "previous node" do not include `space`, `\t`, or `\n`.

- The JSON to be previewed must begin with `{` or `[`.
- The last node of `:` must be `.string`.
- The previous node of `,` can only be one of `.null`, `.link`, `.string`, `.number`, `.boolean`, `}`, and `]`.
- `{` must exist in the previous node, and the previous node cannot be `{`.
- `}` must exist in pairs with `{`.
- `[ ` must exist on the previous node, while the previous node cannot be `]`.
- `]` must exist in pairs with `[`.
- The `"` must appear in pairs.
- The previous node of `"` can only be one of `{`, `[`, `,`, and `:`.
- Spell-checking for `null`, `true`, and `false`.

Syntax errors other than these do not trigger rendering errors.

### Link

In *1.2.0*, `.link` rendering has been added. While rendering, `JSONPreview` performs limited **de-escaping** operations.

The following de-escaping operations are supported in different versions.

> Unless otherwise specified, the following functions are cumulative.

- 1.2.0: Supports replacing `"\\/"` with `"/"`.

## Data Flow Diagram

![image](https://github.com/rakuyoMo/JSONPreview/blob/master/Images/DFD.png)

## Known issues

1. After the first display, slide to a non-terminal position, rotate the screen, and the subviews will be misaligned. The subview will be misaligned. This problem does not occur when screen rotation is disabled.
2. When collapsing/expanding nodes, there is a possibility of JSON flickering.
3. On some systems (a more comprehensive test has not been performed yet), when the JSON is very complex, there will be flickering problems, and the console will output `CoreAnimation: failed to allocate xxx bytes`. (The problem may be an iOS system problem)

## TODO

- [ ] Fix known issues.
- [ ] Add new integration methods, such as `Carthage` and `Swift Package Manager`.
- [ ] Support for macOS.
- [ ] Better copy operation.

## Thanks

Thanks to [Awhisper](https://github.com/Awhisper) for his valuable input during the development of `JSONPreview`.

## License

`JSONPreview` is available under the **MIT** license. For more information, see [LICENSE](https://github.com/rakuyoMo/JSONPreview/blob/master/LICENSE).
