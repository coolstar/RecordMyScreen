## RecordMyScreen

Record the display even on non-jailbroken iPhones.

Licenced with the MIT Licence with the following 2 clauses added onto it:
You may not use the source code for any commercial product.
You may use the videos created from RecordMyScreen for commercial use.

## Credits

* CoolStar (@coolstarorg) - Started the project, and created the initial code.
* ProtoSphere (@protosphere7) - Helped transition to encoding the video on-the-fly
* John Coates (@punksomething) - Improved the framerate of the video captured, fixed the screen tearing, and made RecordMyScreen usable on <= A4
* Brandon Etheredge (@brandonEtheredg) - Added support for the iPad on the UI
* Nicolas Gomollon (@gomollon) - Prevented other apps from stopping our recording (unfortunately using an iOS 6 only API)
* Aditya KD (@caughtinflux) - Moved the recording stuff to a separate class. Makes it a lot easier for us to start on the tweak version :)

## Technical Specs

1. ARMv7 device (A5 recommended)
2. iOS 5 or higher (iOS 6 recommended, may work on iOS 4)
3. Developer Account or Jailbreak to install
4. XCode 4.4.1 or higher

## Device Compatibility

iPhones

1. iPhone 3GS
2. iPhone 4
3. iPhone 4S
4. iPhone 5

Notes:

* iPhone 2G - Not supported: iOS 3 is too ancient, armv6, way too slow, no h.264 encoding support
* iPhone 3G - Not supported: armv6, too slow, does this even support h.264 encoding?

iPod touch

1. iPod touch 3G
2. iPod touch 4
3. iPod touch 5

Notes:

* iPod touch 1G - Not Supported: No microphone, iOS 3 is too ancient, armv6, way too slow, no h.264 encoding support
* iPod touch 2G - Not Supported: armv6, probably doesn't support h.264 encoding
* iPod touch 2G and 3G will need a headset with mic plugged into the headphone jack for backgrounding to work

iPad's

1. iPad 1 (maybe, test please?)
2. iPad 2
3. iPad 3 (requires additional setup)
4. iPad 4 (should work with same settings as iPad 3, but needs testing)

Note: iPads with Retina Display have Issue [#8](https://github.com/coolstar/RecordMyScreen/issues/8)
Note for Retina iPads:
1. You MUST set Video size to 50% scale, as the video encoder doesn't work with the 2048x1536 screen res.
2. There is a little tearing in the video on retina iPads. We will fix it once we can take a look at it.

## Jailbroken users without access to a working iOS toolchain

You may download the latest build of the last stable release (1.0) here: http://d.pr/f/Hnsw
