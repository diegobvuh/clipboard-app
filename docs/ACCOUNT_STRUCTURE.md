# Clipboard business accounts

Each person signs in with their own Google account. A business is the shared workspace, not a shared Google password or a Depop login.

## First owner

1. Open https://clipboard-dashboard.vercel.app/ and continue with Google.
2. Create a business. Its creator becomes the owner atomically.
3. The owner's workspace contains inventory, thrifting, finance, preferences, and Team.

`vigilklinecollective` was created for `diegobvuh@gmail.com` on November 10, 2026.

## Add someone

1. Owner opens Team and enters the person's exact Google email.
2. Owner creates an invitation and shares the app URL themselves.
3. The person signs in with that Google account, sees the pending invitation, and chooses Join business.
4. They gain shared workspace access as a member. They cannot invite/remove people or change the owner.

No invitation email is sent. The invitation is discoverable in the app and expires in seven days. Owner can revoke a pending invitation or remove a member. Existing Google sign-in alone grants no access to another business.

Use the business name in the header to open the workspace picker and check invitations. One person can own one business and belong to other businesses as a member. Owner transfer is not implemented.

## Shared records

Changes save to Supabase. Reload teammate updates fetches the latest state. Concurrent stale saves are rejected, with a message asking the editor to preserve their unsaved text and reload. This is shared persistence with manual refresh, not realtime collaborative editing or offline sync.

Private photos belong to the business. Listing/reference selections describe intended listing use; they never expose a public Supabase bucket. Inventory removal archives it. Stored images are retained.

## Existing local records and exports

The former browser-only data remains in that browser's IndexedDB. Settings offers explicit import into an empty business. It uploads records and photos for that business's members to see; it does not clear the old browser store. Native SwiftData is separate and has no migration in this release.

Settings exports record JSON with image paths. It is not a complete image backup or a one-click restore format. Keep exports private.

## Current verification limits

Google owner login, business creation and owner Team UI were verified live. Owner/member/outsider access and invitation flows were tested locally using PostgreSQL fixtures. A second real Google user has not completed the live join flow yet. The OpenAI secret is saved, but AI generation and Depop integration are not connected.
