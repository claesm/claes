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

---

# 1000 Miles - iOS/iPadOS Card Racing Game

A beautifully designed, universal iPhone & iPad recreation of the classic "1000 Miles" (Mille Bornes) road-race card game, built entirely with SwiftUI.

## Features

- Full solo game against an AI rival, first to 1000 miles wins
- Authentic 106-card deck: distance, hazard, remedy, and safety cards
- Speed limits, hazards, remedies, safety cards, and Coup Fourré bonus scoring
- Polished, code-drawn card graphics (gradients, SF Symbols, shadows) — no external art assets, so it stays crisp at every resolution
- Adaptive layout: stacked boards on iPhone, side-by-side boards on iPad/landscape
- Animated turn indicators, progress bars, and a live game log
- Dark, cinematic "night road" backdrop

## Requirements

- Xcode 15.0 or later
- iOS 17.0 / iPadOS 17.0 or later

## Building the App

1. Open `MilleBornes.xcodeproj` in Xcode
2. Select an iPhone or iPad simulator (or a connected device) as the run destination
3. Click Run (`Cmd + R`)

## Project Structure

```
MilleBornes/
├── MilleBornesApp.swift          # App entry point
├── Models/
│   ├── Card.swift                # Card types and the shuffled 106-card deck
│   ├── Player.swift               # Per-player state (hand, piles, safeties, score)
│   └── GameEngine.swift          # Turn flow, rules, scoring, and the AI opponent
├── Views/
│   ├── RootView.swift             # Menu screen and shared background
│   ├── GameView.swift             # Main game board and turn controls
│   ├── PlayerBoardView.swift      # Battle pile / speed / distance display per player
│   └── CardView.swift             # Card face and card-back rendering
└── Assets.xcassets/               # App icon and accent color
```

## How to Play

- Each turn you draw a card, then either play it or discard it.
- Play a **Go** remedy card to start rolling, then play **distance** cards to rack up miles.
- Play **hazard** cards on your rival to stop them, and **remedy** cards to recover from a hazard played on you.
- **Safety** cards give permanent immunity to one hazard type; playing one the instant you're hit earns a **Coup Fourré** bonus and an extra turn.
- First to 1000 miles wins the race.
