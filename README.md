# WhatsTheScore?

A competitive leaderboard iOS app where friends can create leaderboards, play ranked games, and track their rank progression through a tier system.

## Features

- **Apple Sign In** — Quick, secure authentication
- **Multiple Leaderboards** — Create separate leaderboards for different friend groups or game categories
- **Invite Codes** — Share a 6-character code for friends to join your leaderboard
- **Ranked System** — Progress through 24 tiers: Iron, Bronze, Silver, Gold, Platinum, Diamond, Ascendant, and Immortal (each with tiers 1-3)
- **Flexible Scoring** — Choose from preset point systems (±25, ±50) or define custom points per placement
- **2-4 Player Games** — Support for head-to-head or small group games
- **Match History** — Full history of every game played, including results and point changes
- **Real-time Sync** — All data syncs across devices via Firebase

## Tech Stack

- SwiftUI
- Firebase Auth (Sign in with Apple)
- Cloud Firestore
- Swift Package Manager

## Setup

1. Clone the repository
2. Open `WhatsTheScore?.xcodeproj` in Xcode
3. Set up a Firebase project at [Firebase Console](https://console.firebase.google.com)
4. Add an iOS app with bundle ID `com.VPTechnology.WhatsTheScore-`
5. Download `GoogleService-Info.plist` and add it to the Xcode project
6. Enable **Authentication > Sign-in method > Apple** in Firebase Console
7. Enable **Cloud Firestore** and create a database
8. In Xcode, add the "Sign in with Apple" capability
9. Build and run

## Ranking System

| Rank | Tier 1 | Tier 2 | Tier 3 |
|------|--------|--------|--------|
| Iron | 0–99 | 100–199 | 200–299 |
| Bronze | 300–399 | 400–499 | 500–599 |
| Silver | 600–699 | 700–799 | 800–899 |
| Gold | 900–999 | 1000–1099 | 1100–1199 |
| Platinum | 1200–1299 | 1300–1399 | 1400–1499 |
| Diamond | 1500–1599 | 1600–1699 | 1700–1799 |
| Ascendant | 1800–1899 | 1900–1999 | 2000–2099 |
| Immortal | 2100–2199 | 2200–2299 | 2300+ |

Points can go negative — you'll still display as Iron 1 but must climb back above 0 to rank up.

## License

Private — All rights reserved.
