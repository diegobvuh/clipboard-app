# Clipboard: integration and functionality map

Updated November 9, 2026. This is an implementation guide, not a claim that services are connected.

## Current state

Clipboard is a local-only SwiftUI prototype. It stores inventory, photos, sessions, receipt photos and manually entered finances in SwiftData on the device. It has no accounts, cloud backup, AI, Depop connection, pricing data, publishing, chat, synchronization or subscription billing. Apple Vision is used to read visible text from chosen tag and receipt images on-device; the user reviews the text and enters amounts manually. Camera functionality requires a physical iPhone; recognition quality needs testing against real shop photos.

## Priority order

| Priority | Capability | Integration or dependency | Expected behavior | Status |
| --- | --- | --- | --- | --- |
| 1 | Secure persistence and sync | Backend, shop-scoped database, authentication, private image storage | Recover drafts and photos across sessions/devices; isolate shops | Not implemented; provider undecided |
| 2 | AI listing drafts | Image-capable model through a server-side API | Read selected photos and details; suggest editable copy and attributes; surface uncertainty | Not implemented; provider and account undecided |
| 3 | Strategic pricing | Authorized, commercially usable market data, ideally sold comparables | Show dates, sources and confidence; distinguish sold prices and asking prices | Data source/access not established |
| 4 | Sourcing assistance | Apple Vision text recognition plus future AI session assistant | Read price tag/receipt text, allow correction, keep cart and receipt distinct | On-device OCR for review implemented; automatic extraction and AI not implemented |
| 5 | Depop publishing and sales | Depop-approved integration | Supported listing and order actions with confirmed results | Private API; access not obtained |
| 6 | Assistant and memory | AI provider, backend, shop policies, approval/audit workflow | Conversational help with seller-controlled preferences and gradual autonomy | Not implemented |
| 7 | Social promotion | Platform-specific integrations and permissions | Prepare and publish content where supported | Not implemented |
| 8 | Subscriptions and public release | Apple StoreKit, App Store Connect, backend entitlements | Manage subscriptions and access across devices | Not implemented |

## First vertical slice: photo to reviewed draft

1. Seller creates or selects a garment, takes photos and chooses public versus reference images.
2. App preserves local changes and uploads selected photos to a private, shop-scoped backend with clear progress and recovery. Local-only behavior while offline needs its own design and tests.
3. An authenticated backend sends permitted garment information to an image-capable AI provider. Provider credentials remain on the server.
4. The service returns an editable title, description and attribute suggestions with uncertainty. The seller reviews flaws and approves the draft.
5. Pricing evidence and posting are independent integrations. If unavailable, the UI must say so rather than invent data or claim a listing is live.

**Done when:** a real garment survives app restart and sync; an authenticated request generates a draft from its photos; unknown information stays unknown; failures are recoverable; and tests verify shop isolation, input validation, and the review flow. Provider credentials and infrastructure setup will be required for a live end-to-end test.

## Integration decisions and access

- **AI:** choose an image-capable provider after comparing image support, cost, privacy, retention, and data handling. A working account and server-side key are required. Seller approval remains the initial default.
- **Backend:** select a provider based on auth, Postgres/database, private image storage, row-level or equivalent per-shop authorization, reliability, backups, and cost. Supabase is a candidate, not a configured service or a commitment.
- **Pricing research:** find a source with clear commercial rights, relevant item coverage, and sold-price access. [eBay's API support page](https://developer.ebay.com/api-docs/buy/ref-marketplace-supported.html) describes its Marketplace Insights API as restricted and unavailable to new users. Active listing prices are not sold prices; no invented comparisons or profit guarantees.
- **Depop:** [Depop's private Selling API](https://partnerapi.depop.com/api-docs/) documents inventory, orders, and offers, but access is not available to the general public. Ask Depop about access, multi-seller use, listing automation, sales, and messaging support. Its [terms](https://depophelp.zendesk.com/hc/en-gb/articles/360001773148-Terms-of-Service) restrict bots and third-party software. Computer-use posting is the owner's desired path but its authorization is unconfirmed; do not represent it as available or risk-free.
- **Apple Vision:** on-device OCR uses the OS framework rather than a separate cloud account. Text is advisory, and photos can contain sensitive data.
- **Social:** investigate account types, permissions, supported publishing actions and review for each chosen platform when promotion becomes a priority.
- **Billing:** use [Apple's in-app purchase infrastructure](https://developer.apple.com/documentation/storekit/in-app-purchase) for an iOS subscription flow as applicable, with entitlement verification and applicable regional rules reviewed before launch.

## Implementation dependencies and practical next steps

1. Decide on a backend and AI provider; set up projects and secrets privately. Never put private API keys in the iPhone binary or Git repository.
2. Define authenticated shop identity, private image uploads, draft data, and migration from existing local records. Verify per-shop access rules with real tests.
3. Build the AI draft API and iPhone review flow. Start with manual approval and log only the minimum necessary information.
4. Test using real garment photos, including tags and flaws, then add a pricing-data source when terms and access are confirmed.
5. Contact Depop for access and investigate permitted capabilities separately; add scheduled and automatic actions only after both technical and authorization requirements are satisfied.

The current product plan is in [Clipboard_Full_Product_and_Implementation_Plan.md](../Clipboard_Full_Product_and_Implementation_Plan.md). No production provider, pricing-data contract or integration access has been selected or configured.
