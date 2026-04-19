# Monetization Methods

Potential revenue strategies for WhatsTheScore, ordered roughly by fit for a leaderboard/ranking app.

## Subscription (most likely primary revenue)

- **Free tier** capped at ~1–2 active leaderboards, 4–6 members, 30-day match history
- **Pro tier** unlocks:
  - Unlimited boards and members
  - Full match history
  - Advanced stats (head-to-head, form over time, win-rate trends)
  - CSV export
  - Custom point systems

## Cosmetics (fits the rank-badge aesthetic perfectly)

- Premium badge styles (animated, holographic, seasonal variants)
- Custom leaderboard themes / gradients
- Profile flair, title cards
- Seasonal "skins" tied to real sports seasons

## B2B / Group plans

- Bars, gaming cafés, run clubs, office leagues pay per venue/team
- White-label tier for sports clubs (their branding, our backend)

## Tournament / Events layer

- Paid bracket generation, seeded tournaments
- Season passes with unlockable rewards
- Sponsored seasons (brand pays to put logo on a season's badges)

## One-off revenue

- Physical merch: printed certificates, stickers, patches of a user's current rank
- Lifetime unlock as an alternative to subscription

## Avoid early

- **Ads** — kills the premium feel of the current glassmorphism UI
- **Wagering / pools** — legal minefield in many regions

## Recommended starting point

Lead with **Pro subscription + cosmetic badge packs**. Both lean into what's already built (ranks, badges, glass UI) and don't require new backend work beyond entitlements and a StoreKit integration.

### Implementation notes for later

- StoreKit 2 for in-app purchases and subscriptions
- Entitlements can be stored on the `AppUser` model in Firestore and verified via receipt validation
- Badge cosmetics would extend `RankTheme` / the badge asset sets in `Assets.xcassets`
- Stats features would mostly be new aggregations over the existing `matches` sub-collection — no schema changes required
