### CarMovie - CarPlay Local Video Player (TrollStore)

Play local videos through CarPlay. Optimized for Mazda rotary knob control.

### Build

```bash
# No external tools needed - .xcodeproj is committed
xcodebuild archive \
  -project CarMovie.xcodeproj \
  -scheme CarMovie \
  -configuration Release \
  -sdk iphoneos \
  -archivePath build/CarMovie.xcarchive \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=NO

# Package IPA
mkdir -p build/Payload
cp -R build/CarMovie.xcarchive/Products/Applications/CarMovie.app build/Payload/
cd build && zip -r CarMovie.ipa Payload
```

Install IPA with TrollStore.

### GitHub Actions

Push to main or trigger manually. Workflow uses `macos-13` runner (no queuing).

### Mazda Rotary Knob Controls

| Control | Action |
|---------|--------|
| Rotate knob | Navigate list items |
| Press knob | Select / Play |
| Back button | Return to previous menu |

All UI is built with CPListTemplate and CPNowPlayingTemplate, which natively support focus-based input.

### Add Videos

iTunes File Sharing: drag videos into CarMovie Documents folder, then scan in the app.

### Credits

TrollStore by opa334. Original concept by Dcsyhi([@linux_n1](https://twitter.com/linux_n1/)).
