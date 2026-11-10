# Clipboard Supabase setup

Project `rgqnbtszblhtzgmnnchc` in the Clipboard organization. Google Cloud project **clipboard app** (`crack-petal-514318-r5`) is the selected OAuth project; do not use its similarly named duplicate.

## Applied on November 10, 2026

Migrations 001 through 006 are applied to the live database. Version 001 records the initial SQL originally applied through the dashboard. Later migrations establish membership policies, owner-managed expiring invitations, private photos, AI counters, Google onboarding, and versioned shared workspace saves.

Google is enabled. Email/password and anonymous sign-in are disabled. New Google account registration is enabled. The Site URL is `https://clipboard-dashboard.vercel.app/`. The Google OAuth client's only redirect is `https://rgqnbtszblhtzgmnnchc.supabase.co/auth/v1/callback`. Client secret is stored in Supabase provider settings, never in this repository.

The owner signed in as `diegobvuh@gmail.com`, created `vigilklinecollective`, and the live Team page showed the owner role. No friends were invited by the agent. Multi-person live acceptance remains untested; local PostgreSQL tests cover invitation binding and access isolation.

## Access boundaries

Individual Google logins belong to businesses. Verified Google users can create one owned business. Other business data remains hidden until an owner invitation is accepted. Owners manage invitations and membership through narrowly scoped functions. Clients cannot directly change ownership or membership. Invitations are bound to verified email, expire in seven days, can be revoked, and are limited to 20 creations per business per UTC day. Removal revokes outstanding invitations for that member's current email.

Members can read shared records. Full workspace writes use `save_business_workspace` and an expected revision. Direct client inventory writes and direct workspace table access are revoked. Any stale save is rejected. Item removal archives the record; trip/expense removal updates the current versioned workspace JSON. No permanent image deletion is granted to the browser.

The `garment-photos` bucket is private, permits JPEG/PNG/WebP up to 5 MiB, and uses business-scoped paths. Photo downloads require membership; signed URLs last 60 seconds. The UI's listing/reference checkbox does not make storage public. Membership removal prevents new access; previously viewed/downloaded images cannot be recalled.

## Verification

`node tooling/test-access.mjs` runs 42 checks on isolated PostgreSQL via PGlite with synthetic Auth/Storage fixtures. It validates member isolation, owner-only controls, expiry/revocation, private photos, quota enforcement, stale writes, direct-write restrictions, and workspace access after removal. It does not exercise live Google or Supabase Storage services. `node --test tooling/test-cloud-races.mjs` covers three cross-account/workspace loading races. Actual Google login, business creation, owner directory and desktop/phone Team UI were checked in the deployed app. Anonymous production business reads were denied.

## Secrets and unfinished integrations

`OPENAI_API_KEY` exists in Edge Function Secrets. Its value was not retrieved. The protected `clipboard-api` Edge Function is deployed and the `vigilklinecollective` business has AI enabled. AI limits are 20 attempts per business per UTC day, one per user per minute. The app calls the function only from the saved-item “Generate Depop draft” action; it never publishes directly to Depop.

Do not put service-role credentials, Google client secrets, or OpenAI keys in `web/`, Git, or browser settings. Only the Supabase publishable key is in the browser bundle.

## Recovery

Settings exports records with private photo paths, not photo binaries. Store exports privately. A complete backup requires a separately verified database export and storage-file backup; neither is claimed to be automated here. Managed backup availability has not been verified. Earlier browser records remain untouched unless the owner/member explicitly imports them. See `docs/ACCOUNT_STRUCTURE.md` for user flow and limitations.
