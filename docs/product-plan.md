# Clipboard: product plan

Working document · November 9, 2026

## Product direction

Clipboard is an iPhone app that helps a clothing reseller turn garment photos and details into clear listing drafts. The first customer is the owner's shop. The longer-term goal is a subscription product for Depop sellers, with a configurable AI assistant that can support listings, buyer communications, promotion, and business decisions.

The shop is currently idle with about 30 unlisted, one-of-a-kind thrifted garments. Photos already include brand, size, and other tags. The owner finds the work after taking pictures especially tedious and wants to take good photos and have Clipboard handle as much of the listing process as possible. The first release should prove that Clipboard saves meaningful time preparing accurate listings. It should be simple enough to use while photographing a batch of clothing. Over time, Clipboard should grow into a dashboard for a broader clothing business and brand; the owner is interested in both original clothing designs and secondhand curation. The immediate scope is Depop; other business directions are not current priorities.

## Pilot: the 30-garment backlog

Use these garments as the first real pilot. Start with a few varied items to surface unclear labels, missing sizes, and different condition issues; adjust the workflow before processing the rest. Record total time spent after photography, the number of listings ready for review, and what information had to be entered or corrected manually. Compare with the shop's ordinary process when a baseline is available; no time-saving target or baseline has been established.

A batch workflow is a proposed priority: photograph one garment at a time, group its images into a draft, then let AI prepare drafts in the background while the next garment is photographed. Present missing or uncertain information in a short review queue. Separate the actions of preparing, approving, and publishing so a draft is never falsely presented as a live listing. The owner wants the computer agent to perform the final posting; the Depop access and account-risk questions below remain unresolved.

## First-release workflow

1. Start a garment draft and take photos with the iPhone camera or select existing photos. Keep the garment's front, back, labels, and flaws together.
2. Let the seller choose which photos are intended for the public listing and which are reference-only. The default selection remains open. Flag a rip, stain, or other condition detail and add a note when needed.
3. Enter or correct information such as brand, size, condition, measurements, purchase cost, and asking price. Decide which fields are essential after trying the workflow with real garments.
4. Ask AI to produce a title and description and suggest a price, category, brand, and size from the supplied information and photos. Suggestions remain editable and need seller verification. Price research should seek relevant market evidence and balance a stronger sale price with the likelihood and timing of a sale; a price estimate is only as reliable as available evidence. The description should support the price with accurate, specific details and a compelling tone, without making unsupported claims. AI should distinguish what it can observe from what remains uncertain; it should not invent measurements, authenticity, material, or condition. The seller can edit the result.
5. Review the photos, condition disclosures, listing text, and price. Save a draft and return to it later. The owner prefers an AI-controlled computer to log in and complete the posting. This path faces the Depop terms and account risks described below; authorization is unconfirmed. A seller-operated handoff remains an available fallback, not the owner’s selected goal.

A good early test is to time a representative batch using the current workflow and Clipboard, then compare preparation time and the corrections needed. We have no baseline or performance targets yet.

## Initial screens

- **Listings:** draft list, status, and a clear action to start a garment.
- **Capture:** camera/photo selection, photo order, and a way to identify condition details.
- **Garment details:** editable fields and notes; clearly flag missing or uncertain information.
- **Draft review:** editable AI text, photos, condition disclosure, and manual handoff when defined.
- **Settings:** seller preferences and transparent controls for future assistant behavior.

These are proposed screens, not final visual designs. The user's direction is a simple, minimal interface reminiscent of Depop, adapted for iPhone.

## Pricing research and listing quality

The owner wants strategic pricing that balances reasonable sales velocity and profit, without missing potential profit unnecessarily. For each item, the proposed assistant should use available, appropriately authorized research sources to find relevant comparisons (such as the same brand, model, condition, and size where possible), distinguish sold prices from active asking prices, and show the seller its evidence, date, confidence, and limitations. It should suggest a starting price and, where evidence supports it, a negotiation floor or pricing range. No guarantee of a sale or maximum profit is possible; research access, market coverage, transaction costs, and shipping assumptions can affect recommendations. Do not invent comparables or imply access to Depop data that is unavailable.

The suggested description should explain real value using verified features, condition, and style, with compelling language suited to the shop. It must disclose known flaws and avoid invented authenticity, rarity, measurements, provenance, or materials. The seller should be able to edit the price, listing, and voice and give feedback on recommendations.

Measurement policy is configurable per business. For the owner's shop, the current practice is to measure when a customer asks, rather than measuring every item before listing. The assistant must not invent measurements or claim to have measured an item; future messaging should request the owner's input when measurements are needed.

## Inventory, sourcing sessions, and finances

Clipboard should maintain an inventory record for each unique garment, connecting its photos, condition notes, purchase cost, listing draft, eventual sale, and status. Proposed statuses: sourced, drafting, ready, listed, sold, and archived. A status must reflect an actual confirmed event, not an assumed Depop connection.

A live thrifting session is an interactive workspace used during a sourcing trip:

1. Quickly photograph every candidate garment and its store price tag. Create a candidate record and suggest the tag price for the seller to confirm or correct.
2. Keep a running estimated cart total while the seller considers items; distinguish tag prices from taxes, discounts, and expenses that are not yet known. A conversational assistant should be available during the session to help the seller make decisions using available information. Specific sourcing recommendations and research access require validation.
3. Let the seller remove items they decide not to buy. At checkout, confirm the purchased items and carry those records into inventory. Confirm the discard behavior and retention expectations before implementation; do not silently delete data that could be wanted later.
4. Photograph the receipt to record the trip total and assist with reconciliation. The owner says receipts do not identify garments reliably, so item costs come primarily from the photographed tags and seller corrections, not automatic receipt-line matching. Flag differences between the confirmed items and receipt total.
5. Record other expenses and let the assistant suggest an accurate treatment of taxes, discounts, and shared trip costs, explaining the calculation and remaining uncertainty. The seller can inspect and correct it; no allocation method is assumed to be universally right.

A session should survive interruption and show unsaved or failed uploads, subject to the chosen architecture. Continuous live camera support is an idea for later, not a requirement for the initial sourcing session. It would need a separate design for permissions, cost, connection, and control.

Finance should show recorded spending, sales proceeds, and estimated profit for items and selected periods. Keep item purchase cost, shipping, selling fees, other expenses, refunds, and proceeds distinct; mark missing amounts and show how each estimate was calculated. Unsold inventory costs and realized profit from completed sales should not be conflated. Automated bank feeds, tax preparation, formal accounting, and Depop sales synchronization are not yet specified or promised. The first version can start with seller-entered amounts, with integrations considered after access and needs are confirmed.

For the current 30 garments, allow costs to be added manually or marked unknown; do not fabricate historical receipts or profit figures. A limited inventory record and cost field can accompany the initial listing workflow; real-time sourcing sessions and a full finance dashboard should be prioritized against that first workflow before committing to release scope.

## Assistant and memory

The owner wants a conversational AI employee that can discuss the business, learn its practices, and eventually carry out the work autonomously. Initially, the assistant drafts content for a seller to review. The owner wants to increase independence gradually as the AI improves through review; the transition criteria, controls, and supported access require further definition. Longer term, each shop should be able to configure permissions by task and define a voice, shipping policies, offer limits, and escalation rules. Proposed memory should start as an editable shop profile and examples of approved responses, scoped to that shop. Seller edits or rejections should inform suggestions only when the feedback is meaningful; a single rejection should not silently rewrite policy. Provide ways to inspect, correct, and remove saved preferences. Do not claim that the system learns from decisions until the behavior is actually implemented and tested.

Potential future modes include draft-only, approval required, and automatic action within explicit rules. Availability depends on the action, integration permissions, and the seller's choices. Refunds, complaints, unusual circumstances, and uncertain answers should be escalated to a person by default. Whether and how messaging can be integrated must be confirmed before promising automatic replies.

## Depop and other integrations

Depop documents a private partner Selling API for listings, orders, and offers. The owner does not currently have access. API capabilities, terms, approval, commercial requirements, and support for buyer messages and analytics must be confirmed with Depop before designing a live integration around them. See [Depop's Selling API](https://partnerapi.depop.com/api-docs/) and [API terms](https://partnerapi.depop.com/api-docs/terms/).

Depop's published [terms of service](https://depophelp.zendesk.com/hc/en-gb/articles/360001773148-Terms-of-Service) prohibit bots and other third-party software on the service. The owner specifically requests a computer-use agent that logs in and operates Depop. A computer-use agent acting through its website is not a confirmed workaround, including for the owner's shop. The owner’s preference is recorded; any deployment requires an informed decision about these risks and the ability to operate within applicable authorization. Contract, account, and legal implications depend on the facts and jurisdiction; obtain legal advice for a commercial launch. Do not implement unapproved Depop automation on the assumption that it is authorized.

Instagram and other social channels are later integrations. Actual supported publishing, account types, permissions, and review requirements must be verified with each platform. Avoid inventing connection status or metrics.

## Later phases

1. **Validate listing preparation:** capture, store, edit, generate, review, and manually hand off drafts with the owner's shop.
2. **Pilot with sellers:** add accounts, secure per-shop data separation, onboarding, feedback, support, and subscription planning after the core workflow is useful.
3. **Authorized marketplace connection:** pursue Depop access, then implement and test only the supported permissions. Scheduling requires reliable server-side jobs, time zones, retries, and clear failure states; it is not accomplished by a local reminder alone.
4. **Assistant and communications:** build shop-specific rules, approval workflows, feedback, and audit history; introduce actions only where platform access and permissions allow.
5. **Social promotion and analytics:** connect available data sources, show actual data with its time range and source, and present AI suggestions as hypotheses grounded in evidence. Useful possible metrics include sales, fees, shipping costs, profit, sell-through, listing age, and response times, subject to data availability.

The longer-term dashboard could bring inventory, sales, costs and profit, customer operations, social promotion, and eventually brand activity together. Which of these matter first and what data sources can supply them are open questions.

These phases may overlap once dependencies are known. They are a sequence of validation, not a committed delivery schedule.

## Architecture to evaluate

- Recommend native SwiftUI for the iPhone app: iPhone is the first target, and native camera, photo selection, accessibility, and device integration are central. A cross-platform framework would be more attractive if Android becomes an immediate requirement. This is a recommendation delegated to us, not a finalized implementation.
- A backend will be needed for shared accounts, secure AI-provider access, future integrations, and reliable scheduled work. Provider, hosting, data model, and pricing remain open.
- Store photos and drafts durably with explicit upload states and recovery; design local-first behavior and offline scope after confirming the seller's actual workflow.
- Never embed private service keys in an iPhone app. Protect per-shop data, limit sensitive information sent to AI providers, and define retention and deletion before a public pilot.
- Keep integrations behind distinct interfaces so drafting can work independently of marketplace access. Avoid storing Depop passwords as a substitute for authorized connections.

## Decisions and questions

- The shop has approximately 30 one-of-a-kind thrifted garments; work after photography is the largest pain. Brand, size, and other tags are already photographed. Which other details, such as measurements and shipping, are available or needed?
- The seller will choose public and reference-only photos per listing. What should the default be, and should photos be enhanced or backgrounds removed?
- AI should suggest price, category, brand, and size. Which pricing sources are accessible and authorized, and what seller costs and desired margins should be considered?
- The owner wants computer-use posting after a gradual supervised period. Would a manual handoff be acceptable temporarily while authorization and account risks are investigated?
- What information should be required before a draft is ready, including condition and measurements?
- What business policies and tasks should the assistant learn, and which actions always need approval?
- The seller wants to capture all candidates before purchase, then discard unpurchased items and retain purchased items. Confirm the expected retention and recovery behavior for discarded candidates.
- Receipts do not reliably identify garments; their purpose is trip-level tracking. What allocation rules should apply to discounts, tax, shared trip expenses, and missing costs, and when should a seller confirm the AI’s recommendation?
- What financial information is already available, and should finance start with manual entry?
- Which social platforms and business metrics matter first?
- Native SwiftUI is recommended. Is Android needed soon enough to change that decision?
- What target geography, privacy expectations, subscription model, and budget apply to a later public launch?

## Current status

Planning only. No application, AI service, camera workflow, Depop or social connection, scheduling, analytics, subscription system, or live integration has been built or tested.
