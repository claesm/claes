# Christmas Countdown - Apple Watch App

A festive Apple Watch app that counts down the days until Christmas Eve!

## Features

- Real-time countdown to December 24th
- Beautiful festive UI with Christmas tree emoji
- Red and green gradient background
- Automatically calculates days remaining
- Shows special messages when Christmas Eve arrives or has passed
- Updates every minute to keep the countdown current

## Requirements

- Xcode 14.0 or later
- watchOS 9.0 or later
- Apple Watch Series 4 or later (recommended)

## Building the App

1. Open `ChristmasCountdown.xcodeproj` in Xcode
2. Select an Apple Watch simulator or connected Apple Watch as the target device
3. Click the Run button or press `Cmd + R`

## Project Structure

```
ChristmasCountdown/
├── ChristmasCountdown.xcodeproj/
│   └── project.pbxproj
└── ChristmasCountdown Watch App/
    ├── ChristmasCountdownApp.swift  # App entry point
    ├── ContentView.swift             # Main UI and countdown logic
    └── Assets.xcassets/              # App assets and icons
```

## How It Works

The app calculates the number of days from today until December 24th of the current year. If Christmas Eve has already passed this year, it automatically calculates the countdown to next year's Christmas Eve.

The countdown updates every minute and displays:
- The number of days remaining (in large, bold text)
- A Christmas tree emoji at the top
- "Christmas Eve" as the title
- Special messages when Christmas Eve is today or has passed

## Customization

You can customize the app by modifying `ContentView.swift`:
- Change the emoji (currently 🎄)
- Adjust colors in the gradient background
- Modify the font sizes and styles
- Change the update interval (currently 60 seconds)

## License

Feel free to use and modify this app for your personal projects!
