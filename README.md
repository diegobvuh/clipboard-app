# Clipboard

iPhone-first workspace for a resale shop. This repository currently contains an **early local prototype**, not the complete product described in the plan.

## What works in this version

- Create and edit unique garment records, save listing text, condition notes, purchase costs and manually tracked status.
- Take photos on a physical iPhone or import from the photo library. Mark listing versus reference photos and identify tag or flaw images.
- Start thrift sessions, record candidate and price-tag photos and manually entered prices, mark decisions, store a receipt photo and total, and add purchased candidates to inventory.
- Record expenses, sale proceeds and item costs; view item profit only for sales with all required amounts recorded. Shared expenses are shown separately.
- Read text from tag and receipt photos on device for manual review; recognition does not automatically change amounts.
- Save measurement and shop-voice preferences locally.

Data is stored on the device with SwiftData. There are no accounts, backup, sync, or export; deleting the app can delete its data. Do not use this prototype as the only copy of important business records.

## Not implemented

AI-generated descriptions, photo analysis, automatic tag/receipt field extraction, comparable-price research, chat or memory, cost allocation, Depop connection or automation, publishing, scheduling, message replies, social connections, analytics, subscriptions, server infrastructure, and multi-user support are not implemented. Manual statuses are not synced with Depop. See [the product plan](Clipboard_Full_Product_and_Implementation_Plan.md) for the intended scope and integration dependencies.

## Run

Requires Xcode with an iOS 17 or newer SDK. Open `Clipboard.xcodeproj`, choose the Clipboard scheme and an iPhone simulator, and run. For a physical iPhone, select your Apple Development team and a unique bundle identifier in Signing & Capabilities. Camera requires a physical device; the simulator can use its photo library.

Build and test:

```sh
xcodebuild -project Clipboard.xcodeproj -scheme Clipboard -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Clipboard.xcodeproj -scheme Clipboard -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO test
```

The app is independent and is not affiliated with Depop.

## Shared web app

The phone-friendly app lives in `web/` and is deployed at [Clipboard](https://clipboard-dashboard.vercel.app).

- Google-only sign-in through Supabase, with individual logins.
- Create one owned business and join other businesses through owner-created, email-bound invitations.
- Owners invite/remove members in Team. Invitations appear in-app after the invitee signs in; no email is sent.
- Inventory, trips, finances, preferences and private photos are business-scoped and stored in Supabase.
- Saves reject stale workspace revisions instead of overwriting a teammate. Use Reload teammate updates to fetch newer records.
- Inventory removal archives the database record; files are retained.
- Settings provides a records export and explicit import of the older browser-only workspace into an empty business.

Run `npm ci --prefix web`, `npm run build --prefix web`, then `python3 -m http.server 4173 --directory web`. The SDK browser bundle must exist at `web/vendor/supabase.js`. Local Google sign-in requires adding the exact local redirect in Supabase; production login returns to the deployed site. Local preview alone does not configure OAuth redirects.

Run access tests with `npm ci --prefix tooling`, `node tooling/test-access.mjs`, and `node --test tooling/test-cloud-races.mjs`. Deploy the prebuilt static app using `vercel deploy --prod --scope private-poker-app` from the linked root checkout. `vercel.json` includes the production content security policy.

The native Swift prototype remains device-local and is not automatically migrated. Earlier browser data stays in IndexedDB until explicitly imported. Export JSON references private image paths; it does not include image binaries. AI generation and Depop publishing are not connected. See [account setup](docs/ACCOUNT_STRUCTURE.md) and [Supabase setup](supabase/README.md).
