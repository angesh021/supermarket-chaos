# Development backlog

G0 was approved on 2026-10-12. The user authorized continued phase implementation and will provide Studio verification at phase gates.

## Phase 0 — Foundation
- [x] Requirements, design, architecture, security model, traceability, setup and backlog.
- [x] Rojo project mapping, pinned tools, repository and CI structure.

## Phase 1 — First playable
- [x] Procedural supermarket blockout, first-shift objective HUD and server-owned shift flow.
- [x] Cart event, stocking, customer interaction, checkout, shift close and visible upgrade.
- [x] User-verified desktop Play Solo flow and corrected runtime/visibility issues.
- [ ] Verify mobile/device emulation and touch targets.
- [ ] Verify multiplayer interactions after Phase 3 roles exist.

## Phase 2 — Progression and persistence (implemented; G2 user-verified)
- [x] Decide player-owned persistence and server store ownership in ADR-0002.
- [x] Add schema-versioned per-player profiles and UpdateAsync session leases.
- [x] Persist balance, in-progress shift, sales, completed shifts and the shelf upgrade.
- [x] Resume saved shift state and start repeat shifts from the shift board.
- [x] User confirmed the requested Studio progression and persistence tests passed.
- [ ] Extend the upgrade catalog and customization beyond the fixed storefront style.
- [x] Phase 15: add a persistent, server-purchased Coastal Market storefront palette and v10 migration; see `operations/PHASE15_STOREFRONT_STYLE.md`.
- [x] Phase 19: add a temporary preview/cancel action before the existing palette purchase; see `operations/PHASE19_STOREFRONT_PREVIEW.md`.

## Phase 3 — Cooperative multiplayer
- [x] Join request and owner approval/decline/removal workflow.
- [x] Four-player server cap and server-owned Manager, Cashier, Stocker and Maintenance roles.
- [x] Role-specific prompt authorization; shared shift state and the owner's profile remain authoritative.
- [ ] Multi-client Studio verification.

## Phase 4 — Employees and operations (first employee increment implemented)
- [x] Hire a persistent cashier for $100 after a shift; show the cashier in the store.
- [x] Cashier automatically serves a stocked customer after a short delay; sale uses the existing server economy.
- [x] Hire a persistent stock clerk for $80; the clerk automatically stocks the introductory product after the cart objective.
- [ ] Studio verification of hire, save/rejoin, automatic service and helper permissions.
- [x] Add a persistent cleaner role for $120; it automatically resolves the checkout spill through the normal economy transition.
- [x] Add persistent cashier, stocker and cleaner automation pause/resume controls; see `operations/PHASE18_EMPLOYEE_AUTOMATION.md`.
- [x] Add a warehouse-gated delivery employee who receives arrived shipments; see `operations/PHASE20_DELIVERY_WORKER.md`.
- [x] Turn the pantry fixture into the fourth functional SKU, Sunrise Cereal, with v14 inventory migration; see `operations/PHASE21_SUNRISE_CEREAL.md`.
- [x] Add persistent Owner/Manager control of three bounded price choices per SKU, with shelf tags and server-priced checkout; see `operations/PHASE22_PRODUCT_PRICING.md`.
- [x] Make deterministic basket quantities respond to price tier and available stock; see `operations/PHASE23_PRICE_SENSITIVE_BASKETS.md`.
- [x] Extend stocker automation to replenish the next preferred empty SKU and allow repeat Citrus Pop restocking; see `operations/PHASE24_STOCKER_REPLENISHMENT.md`.
- [x] Add a persistent Customer Assistant employee who speeds customer browsing without changing checkout authority; see `operations/PHASE25_CUSTOMER_ASSISTANT.md`.
- [x] Add a development-only repeat-shift funnel using server-confirmed milestones and ephemeral IDs; see `operations/PHASE26_REPEAT_SHIFT_ANALYTICS.md`.
- [x] Phase 27: add a persistent, server-priced second fixed household aisle slot behind the first shelf expansion; see `operations/PHASE27_HOUSEHOLD_AISLE_EXPANSION.md`.
- [x] Phase 28: charge fixed employee wages once per completed shift and surface payroll in the existing HUD status line; see `operations/PHASE28_SHIFT_PAYROLL.md`.
- [x] Phase 29: add a persistent warehouse shelf editor with server-validated placement, movement, rotation, collision limits and removal; see `operations/PHASE29_WAREHOUSE_LAYOUT_EDITOR.md`.
- [x] Phase 30: add reproducible weighted customer shopping preferences with visible customer labels; see `operations/PHASE30_CUSTOMER_PREFERENCES.md`.
- [ ] Add more departments and main-floor customization; warehouse layout editing is implemented but not full store construction.
- [ ] Add customer satisfaction, product substitution and patience effects to the Phase 30 preference profiles.
- [ ] Studio verification of cleaner hire/migration, save/rejoin, automatic cleanup and player/employee races.

## Phase 4 — Customer operations (checkout queue increment implemented)
- [x] Show a bounded three-customer checkout queue with varied original procedural appearances.
- [x] Serve customers through the existing server economy transaction; close the shift only when the queue is cleared.
- [x] Reconstruct remaining queue positions from the persisted shift sales count after rejoin.
- [x] Script bounded entrance, aisle browse, checkout queue and exit waypoints; add a 12-second queue recovery path.
- [x] Add reproducible weighted shopping preferences; event reactions are implemented in Phase 16. See Phase 30.
- [x] Phase 16: add stage-derived customer reactions for spill, outage and rush with normal labels restored after recovery; see `operations/PHASE16_CUSTOMER_EVENT_REACTIONS.md`.
- [x] Phase 14: add deterministic Citrus Pop/Berry Bites basket preferences, stock-aware fulfillment, atomic multi-item checkout and basket display; see `operations/PHASE14_CUSTOMER_BASKETS.md`.
- [ ] Studio verification of three sales, queue visibility, cashier automation, helper races, and rejoin mid-queue.

## Phase 4 — Chaos operations (checkout spill increment implemented)
- [x] Trigger a customer spill after the first sale and pause the queue.
- [x] Require an authorized player to clean the spill; pay a small server-owned cleanup reward and resume the queue.
- [x] Persist the interruption using the versioned shift stage so rejoin restores the cleanup objective.
- [x] Add a bounded Power Outage with a physical breaker, role permissions, persisted deadline and automatic recovery; Phase 31 varies the event schedule per player and completed shift.
- [x] Phase 31: replace the fixed spill/outage order with a reproducible server-side Chaos Director; see `operations/PHASE31_CHAOS_DIRECTOR.md`.
- [x] Add Customer Rush after the normal three sales: two bonus customers, a persisted 60-second deadline, server-priced checkout, a one-time `$20` clear bonus and safe no-bonus timeout.
- [ ] Studio verification of the Customer Rush queue, payout, timeout, cashier behavior and save/rejoin; see `operations/PHASE13_CUSTOMER_RUSH.md`.
- [ ] Studio verification of customer baskets, mixed/double-item totals, stock fallback, role races and save/rejoin; see `operations/PHASE14_CUSTOMER_BASKETS.md`.
- [ ] Studio verification of storefront style price, roles, visible changes, v1–v9 migration and save/rejoin; see `operations/PHASE15_STOREFRONT_STYLE.md`.
- [ ] Studio verification of customer reactions and label restoration during route recovery and save/rejoin; see `operations/PHASE16_CUSTOMER_EVENT_REACTIONS.md`.
- [ ] Studio verification of Power Outage, including early/manual recovery, auto recovery, save/rejoin and helper roles; see `operations/PHASE12_POWER_OUTAGE.md`.
- [ ] Studio verification of role permissions, reward idempotency, save/rejoin and cashier behavior during the event.

## Later phases
- [x] Phase 5 security increment: finite/schema-bounded profile versions, server role checks, bounded remotes, and visitor-state data minimization.
- [x] Phase 5 analytics increment: a first-shift funnel is sent through Roblox AnalyticsService only in the configured development universe, without custom fields or game-owned player IDs (the platform associates events with the required Player argument).
- [ ] Phase 5: broader adversarial security checks, persistence recovery, fair commerce and deeper analytics.
- [x] Phase 5 persistence increment: serialize each player's gameplay/autosave/release DataStore writes; add a manual contention and recovery checklist.
- [ ] Phase 5 manual verification of the save guard, active-session lease, outage fallback and recovery.
- [x] Phase 6 UI increment: touch devices get a collapsed top-center objective card, a centered resizable team panel, and larger role controls.
- [x] Phase 6 visual increment: make the procedural storefront, department layout, produce/refrigeration, checkout, cart return, signage and character silhouettes read clearly as a neighborhood supermarket.
- [ ] Phase 6: device emulation/touch QA, performance review, external beta, staging and release approval.
- [ ] Review the new visual pass in Studio from exterior approach, entrance, aisle and checkout camera positions; refine any collision, sightline or mobile issues.
- [x] Phase 7 first increment: server-authoritative $200 warehouse annex purchase, physical buildout and per-player persistence.
- [x] Phase 7 delivery increment: persistent backroom Citrus Pop stock, server-priced supply order, delayed shipment, receive prompt and stock HUD.
- [x] Phase 7 follow-up increment: Citrus Pop and Berry Bites have separate server-owned shelf/backroom quantities, prices, shelf visuals and product-specific delivery.
- [x] Phase 17: add Golden Apples as a produce SKU with v11 inventory migration, server-priced shipment/checkout, stocking visuals and customer baskets; see `operations/PHASE17_GOLDEN_APPLES.md`.
- [x] Phase 4 customer increment: server-derived five-pattern shopping baskets with atomic multi-item checkout, visible customer order, department browsing and no schema migration.
- [x] Phase 7 follow-up: persistent warehouse storage layout with bounded free grid placement and 90-degree rotation; see `operations/PHASE29_WAREHOUSE_LAYOUT_EDITOR.md`.
- [ ] Phase 7 follow-up: purchasable plots, main-floor shelf/checkout placement, department construction and Studio verification of construction/delivery/save/rejoin.
- [ ] Studio verification of Golden Apples shipment, produce stock, migration, basket math, helper permissions, and save/rejoin; see `operations/PHASE17_GOLDEN_APPLES.md`.
- [ ] Studio verification of employee automation toggles, delayed timer cancellation, roles, v1–v11 migration and save/rejoin; see `operations/PHASE18_EMPLOYEE_AUTOMATION.md`.
- [ ] Studio verification of the palette preview/reset, purchase, role permissions and save/rejoin; see `operations/PHASE19_STOREFRONT_PREVIEW.md`.
- [ ] Studio verification of delivery-worker hire/migration, SKU receipts, pause/resume, player races and save/rejoin; see `operations/PHASE20_DELIVERY_WORKER.md`.
- [ ] Studio verification of cereal stocking, order/receipt, basket math, HUD and v1–v13 migration; see `operations/PHASE21_SUNRISE_CEREAL.md`.
- [ ] Later phases: broader economy (including scheduled operations costs), seasonal/live operations, production commerce and release work remain gated by the specification, Studio validation and explicit release approval.
