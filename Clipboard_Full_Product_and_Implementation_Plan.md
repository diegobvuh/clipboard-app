# Clipboard — Product and Implementation Plan

**Working title · Shareable planning draft · November 9, 2026**

**Status:** Planning only. No application or integrations have been built.

## Executive summary

Clipboard is an iPhone-first assistant for a Depop seller. The first goal is to reduce the tedious work between photographing a unique thrifted garment and having a high-quality listing ready. The owner has approximately 30 unlisted garments to use as an initial pilot.

The broader product combines photo-to-listing creation, sourcing sessions, inventory and cost tracking, financial insight, and a conversational AI assistant that gradually earns more autonomy. The owner intends to use it for their own shop first and eventually offer it to other sellers as a subscription. Automatic posting and messaging depend on access and authorization that have not yet been secured.

**Recommendation:** begin with a native iPhone listing and inventory workflow; test it on the existing backlog; then add sourcing and finance capabilities in small, validated slices. Pursue Depop access in parallel. This is a recommended order, not a fixed commitment or delivery schedule.

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

## Recommended release scope and acceptance criteria

### First usable pilot: photograph to reviewed draft

**Include:** create one-of-a-kind inventory records; take or import multiple photos; group and order them; identify tag and condition-detail photos; choose public versus reference-only images; record a known purchase cost or mark it unknown; save and reopen drafts; use AI to suggest garment attributes, listing copy, and an evidence-qualified price; edit every suggestion; review a batch and track draft status. Capture the time and corrections needed in the pilot.

**Acceptance criteria:**

- A seller can create and reopen a garment with its photos and details after restarting the app.
- The seller can distinguish public photos from reference-only photos and explicitly choose what to include.
- A draft shows AI suggestions and uncertainty, lets the seller edit them, and discloses recorded flaws. Unknown attributes remain unknown until confirmed.
- A suggested price shows its basis and limitations, or says that adequate evidence was unavailable; it never fabricates comparisons.
- A garment can have a known purchase cost or an explicit unknown cost. A cost or sale is never implied by an empty field.
- Draft, approved, and published states are distinguishable. A listing appears published only after an actual confirmed publication.
- The seller can work through a small batch of real garments and identify blockers before the remaining backlog is processed.

**Not promised for the pilot:** autonomous Depop posting or inbox access, supported live market comparisons, continuous video, automated bank connections, automatic posting to Instagram, subscriptions, or complete financial accounting. Each requires further work or access. AI functionality itself requires a working backend and model integration; a mock screen is not a completed AI feature.

### Next: sourcing and foundational finances

Add candidate capture, editable tag prices, a running cart, purchase confirmation, receipts, and item costs. Begin finance with user-entered expenses and proceeds and transparent calculations. Deliver slices in the order the pilot indicates, rather than waiting for a complete business dashboard.

### Later: connected operations and public subscription

Add only authorized marketplace connections and supported capabilities; then expand automation, scheduling, messaging, multi-shop onboarding, subscription infrastructure, social promotion, and richer analytics. These depend on platform access, product validation, and customer needs.

## Recommended screen map

- **Home:** an overview of what needs attention, recent activity, and a direct path to a new listing or sourcing session. All counts must come from real saved data.
- **Inventory:** unique garments, photos, cost, status, search, and filters.
- **Capture and draft:** photo grouping and selection; item details; AI results; uncertainty and edit controls; review and approval.
- **Thrift session:** candidate list, quick capture, running total, assistant, receipt, checkout and reconciliation.
- **Assistant:** conversation with the shop assistant, access to relevant shop information, and clear approvals when actions become available.
- **Finance:** item and trip costs, manually recorded proceeds and expenses, and understandable profit summaries.
- **Settings:** shop profile, measurement and pricing preferences, AI controls, data management, and eventual connected accounts.

The actual navigation and visual design are open. The interface should feel minimal and familiar to Depop users without implying affiliation with Depop.

## Technical blueprint

### Components

1. **iPhone client:** SwiftUI for screens and native camera/photo workflows. Retain state on interruption and make upload and AI-processing states clear. Support accessible text sizes, labels, and keyboard behavior.
2. **Application backend:** authenticated shop accounts, listing and inventory operations, AI orchestration, saved preferences, and later integrations. A single-shop pilot can start small but should not assume all future users share the same data.
3. **Database and private image storage:** persist shop-scoped items, photo metadata, drafts, sessions, expenses, sale records, and assistant preferences. Keep images private by default and use scoped access.
4. **AI services:** image understanding and text generation via server-side calls; receipt/tag extraction with correction; a research service only when appropriate sources and rights are available. Model results must be reviewable and traceable to input and evidence.
5. **Background processing:** use durable jobs for image analysis, research, and future scheduling. Persist progress and failure reasons; retry safely without duplicating uploads, listings, or external actions.
6. **Integration adapters:** define a separate boundary for Depop and other platforms. Support only confirmed capabilities and authorization; no access credentials embedded in the app.

Backend provider, database, hosting, AI vendor, pricing-data sources, and deployment design remain recommendations to evaluate, not selected vendors. Before implementation, compare their operational cost, data handling, capability, and ability to support per-shop isolation.

### Initial data model

- **Shop and user:** owner, shop settings, preferences, and permissions.
- **Garment:** unique ID, condition, brand/size/category, editable notes, source, status, and links to photos and costs.
- **Photo:** file reference, ordering, public/reference selection, optional tag or flaw role, and upload status.
- **Listing draft:** editable title, description, suggested and chosen price, review state, generation metadata, and eventual verified external identifier.
- **Sourcing session and candidate:** trip dates, candidate photos, tag prices, cart decision, purchased-item links, and reconciliation status.
- **Receipt and expense:** stored image, extracted or entered fields, actual amounts, allocation method, and corrections.
- **Sale and financial entry:** proceeds, fees, shipping, refunds, costs, dates, and provenance; link to an item where possible.
- **Assistant memory and feedback:** shop policies, approved examples, suggested changes, owner corrections, and action history. Separate seller-confirmed policy from model inference.

The schema must support unknown values, multiple photos, corrections, timestamps, and records added manually. Imported data, model output, and user-confirmed values should have distinguishable sources.

### Data and operational requirements

- Encrypt data in transit and use platform storage protections; restrict access to each shop's data. Keep AI and integration keys on the server.
- Define account recovery, data export, retention, and deletion before opening a public pilot. Do not store marketplace passwords as a substitute for an authorized integration.
- Treat garment labels, receipt text, buyer messages, and external web content as untrusted data; they cannot override seller policies or authorize actions.
- Log important changes and external actions without unnecessarily exposing personal or financial information. Include clear failure states and support a way to correct errors.
- Design for real-world interruption and spotty connectivity: preserve captured information, show pending work, and recover from failure. Exact offline capabilities remain to be determined.

## AI assistant operating model

- **Initial stage:** seller approves listing drafts and manually provides policies. Store explicit preferences and examples with owner controls to inspect, correct, and delete them.
- **Learning stage:** collect edits and accept/reject feedback, test whether suggestions improve, and present proposed preference changes for confirmation. Feedback is evidence, not automatic permission to change business rules.
- **Later autonomy:** offer per-task permissions and spending, pricing, messaging, and escalation limits. Explicit approval rules, platform permissions, monitoring, and the ability to pause or undo where feasible are prerequisites.
- **Conversation:** the assistant can answer questions about information it actually has, identify uncertainty, and request missing information. It must not claim it posted, sold, researched, measured, or contacted someone when it did not.
- **Evaluations:** test extraction on varied labels and flaws, evaluate factual accuracy and missed condition disclosures, compare pricing against known examples, and review failure cases before increasing authority. Do not promise that a model silently learns from every interaction.

## Pilot measurement and implementation sequence

1. Map the current process for a small sample and record the time after photography. Establish the sample, conditions, and baseline rather than inventing a time-savings target.
2. Design the item, photo, draft, and cost workflow; confirm the minimum data and recovery behavior.
3. Build and verify native capture and durable save/reopen behavior before relying on model output.
4. Integrate AI suggestions and evidence-qualified pricing; verify that uncertain or unavailable information remains visible and editable.
5. Test several varied items, fix problems, and work through the remaining 30-item backlog when the workflow is useful. Compare preparation time, corrections, factual errors, and missing condition disclosures against the baseline.
6. Use findings to prioritize sourcing sessions, expense tracking, and the finance view. Evaluate integration access in parallel and do not label a draft as posted without confirmation.

For each milestone, test the workflow on an iPhone or simulator as appropriate, including permission denial, interrupted capture, upload failure, bad or missing model output, and reopening saved work. Actual camera, photo quality, and live-session behavior need testing on a physical iPhone. A public launch also needs onboarding, support, privacy documentation, billing, and multi-shop isolation testing.

## Risks and dependencies

- **Depop access:** private Selling API access and supported endpoints are unconfirmed. The requested computer-use approach also carries terms and account risks, even for the owner's shop. Commercial legal review and any necessary authorization should precede relying on it.
- **Research data:** comparable sold-price data might be limited, costly, outdated, or unavailable. Research must state the source and limitations; low confidence should lead to review.
- **AI accuracy:** labels, defects, price tags, and receipts can be misread; seller review and robust correction are required.
- **Financial accuracy:** unknown costs, shared expenses, taxes, refunds, and sales fees can distort profit; show assumptions and incomplete data rather than false precision.
- **Business viability:** subscription demand, willingness to pay, user acquisition, support load, and unit economics have not been validated. AI/image and data-source costs must be measured before pricing the service.
- **Privacy and trust:** receipts, financial records, messages, and images may contain sensitive information. Per-shop isolation, minimal retention, and clear user controls are essential for a public product.

## Current status

Planning only. No application, AI service, camera workflow, Depop or social connection, scheduling, analytics, subscription system, or live integration has been built or tested.
