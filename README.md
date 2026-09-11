# StikJIT

An iOS **and tvOS** XCFramework that enables JIT for another process over the device's RSD tunnel.

StikJIT is self-contained and bundles the idevice FFI and its JIT scripts.

## Platforms

| Target | Framework | Notes |
|---|---|---|
| iOS / iPadOS | `StikJIT.framework` | Upstream behaviour, unchanged |
| tvOS (Apple TV) | `StikJITTV.framework` | Same RSD/debugserver protocol — tvOS 17.4+ uses the same CoreDevice/RSD tunnels |

## Apple TV notes

- tvOS has **no IOKit**, so TXM detection returns `unknown`; the universal
  script is always used, which the debug server handles regardless of TXM
  presence.
- The tvOS target does not link `IOKit.framework`; `iokit/` module is skipped.
- `BundledScript` resolves `universal.js`/`legacy.js` from the framework's
  own bundle (falls back to the `com.stik.StikJITTV` bundle identifier).
- Pairing, DDI mounting and the debug session work over the same RSD tunnel
  as iOS; a pairing file obtained via AFC/Finder/`idevice_pair` is required.

## Integration

For iOS 26 JIT support, StikDebug URL integration, Built-in StikJIT setup, API usage, requirements, and recommended app settings, see [Integrating StikJIT](INTEGRATION.md).

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/StephenDev0/StikJIT)

## Build

### iOS

```sh
xcodegen generate
xcodebuild archive -scheme StikJIT -destination 'generic/platform=iOS' \
  -archivePath build/StikJIT BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild -create-xcframework \
  -framework build/StikJIT.xcarchive/Products/Library/Frameworks/StikJIT.framework \
  -output StikJIT.xcframework
```

### tvOS

```sh
xcodegen generate
xcodebuild archive -scheme StikJITTV -destination 'generic/platform=tvOS' \
  -archivePath build/StikJITTV BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild -create-xcframework \
  -framework build/StikJITTV.xcarchive/Products/Library/Frameworks/StikJITTV.framework \
  -output StikJITTV.xcframework
```

Both targets are built automatically by GitHub Actions (`.github/workflows/build.yml`).

## License

StikJIT is licensed under the MPL-2.0 (see [`LICENSE`](LICENSE)). It uses StikDebug as a reference, with the bundled [idevice](https://github.com/jkcoxson/idevice), universal.js, and legacy.js retaining their own licenses.
