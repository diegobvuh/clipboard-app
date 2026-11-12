# Shared AI pilot: implementation and release status

This document describes local changes, not a claim that they are deployed or verified with live accounts. Apply the AI usage migration and deploy the `clipboard-api` Edge Function before deploying the updated web client; the old function does not support the new request contract. Do not deploy either half alone to production.

The shared web workspace keeps assistant messages, item suggestions, and pending listing drafts in its existing business-scoped versioned workspace. Team members can see these records. A listing draft is separate from the item until applied, and an item suggestion must be approved. A changed item or a concurrent workspace save prevents stale application. AI cannot publish or send messages. Existing workspace size and revision limits also apply to shared AI history.

The backend loads the current workspace with the caller's authenticated RPC, checks business AI enablement, and uses selected private photos for drafts. Chat includes at most 150 pieces, 40 trips and 200 expenses and reports those limits to the model. Research uses OpenAI web search and displays returned URL citations; source coverage and actual reliability have not been evaluated. API failures and rate limits are surfaced; attempts reserve allowance even when the provider fails.

## Billing is not verified

The migration reserves 10 cents per chat or draft attempt, and 50 cents per research attempt, capped at 2,000 cents per business per UTC month and 100 attempts per UTC day. These are conservative **accounting units**, not actual cost estimates or provider billing, and do not establish a hard $20 paid-spend cap. The reservation also counts while free credits remain. OpenAI's organization balance and billing controls must be configured and independently monitored before use. The existing server secret's identity, model access, credit balance, credit expiration, and account-level spending controls have not been checked in this work.

The research route depends on model/account access to the Responses API web search tool. The selected model is `gpt-4.1-mini` by default and may be set server-side with `OPENAI_MODEL`; neither model access nor live web search was verified. Direct ChatGPT plan use for hosted applications is restricted; it is not implemented or presumed available. OpenAI documents [eligibility](https://developers.openai.com/siwc/token-sharing-open-source) and [subscription API credits](https://developers.openai.com/api/docs/guides/chatgpt-api-credits).

## Before release

1. Verify account ownership, model availability, claimed Pro credits and expiration, and OpenAI billing controls privately; never paste keys into chat or a browser bundle.
2. Apply the migration and deploy the matching function and web client together in an appropriate test environment; test rollback and the exact deployed versions.
3. Test two real team members and a separate business, real garment photos and flaws, actual research citations, failure handling, stale edits, and the paid/credit usage behavior. The local automated tests use simulated providers and identities.
4. Record pilot timing and corrections on several varied real garments before processing the rest. Do not describe this as a completed release until these checks pass.

Run local checks with `node tooling/test-access.mjs`, `node --test tooling/test-cloud-races.mjs`, and `node --test tooling/test-ai.mjs`.
