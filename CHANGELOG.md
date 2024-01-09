# Change Log

All notable changes to this project are documented in this file.

-----

## [Unreleased](https://github.com/RakuyoKit/JSONPreview/compare/2.0.0...HEAD)

### Added

- The `JSONPreview.preview` method adds the `initialState` parameter to support setting the default folding and unfolding states when rendering json.
- `JSONPreview` supports hiding line number view.
- Opens access to the `highlightStyle` and `decorator` properties in `JSONPreview` to support a more flexible rendering method.
- In the closure callback of the `preview` method, add a judgment flag for whether the preview was successful or not.
- Add delegate callback when json slice node state changes.
- Add some easy access properties to `JSONPreview`.

### Changed

- [**Break**] The minimum iOS supported version of the project is upgraded to iOS 12. 
- [**Break**] Setting JSONSlice's Initialization method to internal.
- [**Break**] Adjusted the order of parameters of `JSONDecorator.highlight` method.
- [**Break**] Because `highlightStyle` is now publicly accessible, and to allow for more complex scenarios, the `JSONPreview.preview` method now removes the `style` parameter.
- Provide default implementation for `JSONPreviewDelegate`.
- Refine the timing of json completion preview callback calls.
- Adjusted the code format of some codes.

### Fixed

- Fix the problem of miscalculation of line number height when `Value` is too long.

---

## [2.0.0 - Performance Enhancement](https://github.com/RakuyoKit/JSONPreview/releases/tag/2.0.0) (2023-3-13)

### Changed

- [**Break**] The git repository was migrated. Resulting in a url change.
- [**Break**] Refers to the Swift Core Foundation framework, refactoring the entirety of parsing and rendering, with significant performance improvements.

---

## [1.3.6 - Support for scientific notation](https://github.com/RakuyoKit/JSONPreview/releases/tag/1.3.6)

### Added

- Supports using scientific notation to represent numbers in json. The supported format is `{E/e}[+/-]`.

---

## [1.3.5 - Support for SPM](https://github.com/RakuyoKit/JSONPreview/releases/tag/1.3.5)

### Added

- Support SPM.

### Changed

- Adjusted the directory structure.

### Fixed

- Fixed a crash caused by clicking on a blank area.
- Modified the determination of the url.

## [1.3.2 - Available for iOS 15](https://github.com/RakuyoKit/JSONPreview/releases/tag/1.3.2)

### Changed

- Uses a new method for calculating the height of the row number view Cell.

### Fixed

- Adapted for iOS 15.

## [1.3.1 - Fix Click Error](https://github.com/RakuyoKit/JSONPreview/releases/tag/1.3.1)

### Fixed

- Fixed the issue that the behavior is not normal after clicking the fold/expand button in some cases.

## [1.3.0 - Compromise Updates](https://github.com/RakuyoKit/JSONPreview/releases/tag/1.3.0)

### Added

- Add `JSONPreviewDelegate`, which is used to replace the previous use of `UITextViewDelegate` to realize the URL click.

### Changed

- [**Break**] Removed the diagonal swipe feature.
- Since JSON is now displayed in line breaks, the line height is no longer a fixed value.
- Improved the judgment rules for URLs, and now IP addresses can be correctly identified as URLs.

---
