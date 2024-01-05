# Change Log

All notable changes to this project are documented in this file.

-----

## [Unreleased](https://github.com/RakuyoKit/JSONPreview/compare/2.0.0...HEAD)

### Added

- The `JSONPreview.preview` method adds the `initialState` parameter to support setting the default folding and unfolding states when rendering json.
- `JSONPreview` supports hiding line number view.
- Opens access to the `highlightStyle` and `decorator` attributes in `JSONPreview` to support a more flexible rendering method.

### Changed

- [**Break**] The minimum iOS supported version of the project is upgraded to iOS 12. 
- [**Break**] Setting JSONSlice's main logic to internal.
- [**Break**] Adjusted the order of parameters of `JSONDecorator.highlight` method.
- Adjusted the code format of some codes.

---

## [2.0.0 - Performance Enhancement](https://github.com/RakuyoKit/JSONPreview/releases/tag/2.0.0) (2023-3-13)

### Changed
- [**Break**] The git repository was migrated. Resulting in a url change.
- [**Break**] Refers to the Swift Core Foundation framework, refactoring the entirety of parsing and rendering, with significant performance improvements.

---
