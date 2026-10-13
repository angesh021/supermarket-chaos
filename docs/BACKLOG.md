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
- [x] Add a persisted server-owned customer satisfaction score tied to fulfillment and premium pricing; see Phase 33.
- [x] Phase 38: let high satisfaction attract deterministic Neighborhood regulars and apply a bounded server-measured checkout patience effect; see `operations/PHASE38_LOYALTY_AND_PATIENCE.md`.
- [x] Phase 39: expand the fixed storefront refresh to three previewable, persistent, server-allow-listed palettes; see `operations/PHASE39_STOREFRONT_PALETTE_CHOICES.md`.
- [x] Phase 40: add a persistent fixed freezer department and Freezer Meals SKU through stocking, delivery, pricing, baskets and customer routing; see `operations/PHASE40_FREEZER_DEPARTMENT.md`.
- [x] Phase 41: animate the storefront's automatic glass entrance doors for player and scripted customer traffic; see `operations/PHASE41_AUTOMATIC_ENTRANCE_DOORS.md`.
- [x] Phase 42 security increment: throttle malformed layout remotes before replies and allow only action-specific bounded request fields; see `operations/PHASE42_LAYOUT_REMOTE_HARDENING.md`.
- [x] Phase 43 Stage 3 increment: add a persistent second self-checkout terminal with deterministic customer lane assignment and shared server-priced sales; see `operations/PHASE43_SELF_CHECKOUT.md`.
- [x] Phase 44 Stage 3 increment: add a persistent server-priced grocery order packing station using validated warehouse backstock; see `operations/PHASE44_ONLINE_GROCERY_ORDERS.md`.
- [ ] Studio verification of order rotation, stock deduction, payout, role checks, v26-to-v27 migration and save/rejoin; see `operations/PHASE44_ONLINE_GROCERY_ORDERS.md`.
- [x] Phase 45 Stage 3 advanced employee increment: delivery worker can prepare one online order per completed shift using the shared transaction, with persisted shift idempotency and the existing automation toggle; see `operations/PHASE45_DELIVERY_WORKER_ONLINE_ORDERS.md`.
- [ ] Studio verification of automatic pickup, pause/resume, manual/worker races, v27-to-v28 migration and save/rejoin; see `operations/PHASE45_DELIVERY_WORKER_ONLINE_ORDERS.md`.
- [x] Phase 46 Stage 3 event increment: expand Customer Rush to six total shoppers with physical queue capacity, three bonus customers, a 90-second server timer and a proportional $30 clear reward; existing saved shift sales migrate through widened validation without a schema bump. See `operations/PHASE46_LARGER_CUSTOMER_EVENTS.md`.
- [ ] Studio verification of six-person queue flow, stock threshold, 90-second expiry, $30 reward, self-checkout routing and save/rejoin; see `operations/PHASE46_LARGER_CUSTOMER_EVENTS.md`.
- [x] Phase 47 Stage 4 increment: add a persistent Corner Café plaza business with a fixed-build storefront, coffee inventory, server-priced restocking/serving, Cashier/Stocker role boundaries, and v29 profile migration; see `operations/PHASE47_CORNER_CAFE.md`.
- [ ] Studio verification of warehouse prerequisite, purchase, café visuals, stock cap, coffee sale, role permissions, v28-to-v29 migration and save/rejoin; see `operations/PHASE47_CORNER_CAFE.md`.
- [x] Phase 48 Stage 4 increment: add persistent Market Table restaurant after the café, with a fixed dining storefront, four-meal prep batches, server-priced sales, Cashier/Stocker role boundaries and v30 migration; see `operations/PHASE48_MARKET_TABLE_RESTAURANT.md`.
- [ ] Studio verification of café prerequisite, restaurant purchase, visuals, stock cap, meal payout, role permissions, v29-to-v30 migration and save/rejoin; see `operations/PHASE48_MARKET_TABLE_RESTAURANT.md`.
- [x] Phase 49 Stage 4 increment: add a persistent Pixel & Plug electronics storefront after the restaurant, fixed headphone stock/sales, Cashier/Stocker role boundaries and v31 migration; see `operations/PHASE49_ELECTRONICS_STORE.md`.
- [ ] Studio verification of restaurant prerequisite, storefront layout, stock cap, payout, role permissions, v30-to-v31 migration and save/rejoin; see `operations/PHASE49_ELECTRONICS_STORE.md`.
- [x] Phase 50 Stage 4 increment: add persistent Little Sprout Garden specialty retail after Pixel & Plug, potted-herb stock/sales, Cashier/Stocker role boundaries and v32 migration; see `operations/PHASE50_SPECIALTY_RETAIL.md`.
- [ ] Studio verification of electronics prerequisite, garden storefront, stock cap, payout, role permissions, v31-to-v32 migration and save/rejoin; see `operations/PHASE50_SPECIALTY_RETAIL.md`.
- [x] Phase 51 Stage 4 increment: add a previewable, persistent plaza-wide Coastal Walk, City Lights or Harvest Lane palette after the specialty retailer; see `operations/PHASE51_PLAZA_CUSTOMIZATION.md`.
- [ ] Studio verification of palette preview/cancel/install, all storefront/path recolors, role permissions, v32-to-v33 migration and save/rejoin; see `operations/PHASE51_PLAZA_CUSTOMIZATION.md`.
- [x] Phase 52 Stage 4 increment: add four bounded server-created plaza visitors that browse open businesses over connected routes and then exit; visitors do not affect cash or stock; see `operations/PHASE52_SHARED_PLAZA_TRAFFIC.md`.
- [ ] Studio verification of visitor counts, routes, ownership gating, collision/camera behavior and cleanup after world reset; see `operations/PHASE52_SHARED_PLAZA_TRAFFIC.md`.
- [x] Phase 53 Stage 4 increment: let plaza visitors purchase one stocked item at their visited business using existing server sale transitions; per-business 15-second throttle and shared transaction lock prevent races; see `operations/PHASE53_PLAZA_CUSTOMER_SALES.md`.
- [ ] Studio verification of visitor purchases, exact prices/stock deduction, empty-stock behavior, rejoin persistence and concurrent grocery sales; see `operations/PHASE53_PLAZA_CUSTOMER_SALES.md`.
- [x] Phase 54 Stage 5 logistics increment: add a persistent two-truck delivery fleet after warehouse and delivery-worker ownership; worker automation can prepare up to three online orders per completed shift with bounded, migrated idempotency state; see `operations/PHASE54_DELIVERY_FLEET.md`.
- [x] Phase 55 Stage 5 logistics increment: add a persistent regional distribution center after fleet ownership, doubling backstock capacity per SKU from 500 to 1,000; schema v35 validates the upgrade and migrated inventory ceiling; see `operations/PHASE55_DISTRIBUTION_CENTER.md`.
- [ ] Studio verification of center prerequisites, purchase/visuals, 500/1,000 stock boundaries, delivery-in-flight behavior, role permissions, v34-to-v35 migration and save/rejoin; see `operations/PHASE55_DISTRIBUTION_CENTER.md`.
- [x] Phase 56 Stage 5 partnership increment: add a persistent regional supplier agreement after the distribution center, charging $2,500 once and discounting all inbound product deliveries by 20%; schema v36 persists the prerequisite-bound agreement; see `operations/PHASE56_SUPPLIER_PARTNERSHIP.md`.
- [ ] Studio verification of partnership prerequisites, $2,500 purchase, all six discounted shipment prices, role checks, v35-to-v36 migration and save/rejoin; see `operations/PHASE56_SUPPLIER_PARTNERSHIP.md`.
- [x] Phase 57 persistence foundation: add schema v37 `locations.neighborhood` migration, location snapshot integrity validation and a server-only defensive-copy accessor without changing balance/gameplay state.
- [x] Phase 57 world foundation: allow `WorldBuilder` to build a validated server-ID-named model at an explicit origin while preserving the legacy `neighborhood` world name at origin.
- [ ] Studio verification of v36-to-v37 preservation, default/session-only profile, exact neighborhood snapshot, and rejection of unknown/divergent location records; see `operations/PHASE57_MULTI_STORE_FOUNDATION.md`.
- [ ] Phase 57 multi-store runtime: split shift/world state and helper permissions by server-owned location ID, then add an independently managed second branch. See `operations/PHASE57_MULTI_STORE_FOUNDATION.md`.
- [ ] Studio verification of fleet prerequisites, purchase/trucks, one-vs-three automatic orders, pause control, manual/automatic races, v33-to-v34 migration and save/rejoin; see `operations/PHASE54_DELIVERY_FLEET.md`.
- [ ] Studio verification of satisfaction thresholds, patience timing, event pauses, cashier parity and rejoin; see `operations/PHASE38_LOYALTY_AND_PATIENCE.md`.
- [x] Phase 33: score customer satisfaction from preference fulfillment/price tiers and expose the bounded rating in the HUD; see `operations/PHASE33_CUSTOMER_SATISFACTION.md`.
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
- [ ] Phase 7 follow-up: complete purchasable plots, floor expansion and arbitrary department construction; existing shelves and checkout lane/queue can now be rearranged as Phases 32 and 34.
- [x] Phase 32: persist and server-validate rearrangement/rotation of the four customer-facing product shelves; see `operations/PHASE32_RETAIL_LAYOUT.md`.
- [x] Phase 34: persist and server-validate checkout lane and queue placement, rotate the composite fixture, and derive cashier/customer routes from its transform; see `operations/PHASE34_CHECKOUT_LAYOUT.md`.
- [x] Phase 35: add a persistent `$500` rear supermarket wing after the household aisle, with a walk-through wall opening, lighting, and an unlock-gated rear shelf zone; see `operations/PHASE35_REAR_FLOOR_EXPANSION.md`.
- [x] Phase 36: add a persistent buildable bakery with a fixed procedural fixture, SKU-specific Cinnamon Twists stocking/delivery/pricing, customer baskets, and server-validated layout clearance; see `operations/PHASE36_BAKERY_DEPARTMENT.md`.
- [x] Phase 37: resolve out-of-stock basket items through server-owned related SKU substitutions; charge and route using actual products and score partial fulfillment; see `operations/PHASE37_PRODUCT_SUBSTITUTION.md`.
- [ ] Studio verification of substitute/fallback basket resolution, stock depletion, routing, satisfaction, races and rejoin; see `operations/PHASE37_PRODUCT_SUBSTITUTION.md`.
- [ ] Studio verification of bakery purchase, stock, delivery, customer baskets, collision checks, permissions, schema v22 migration and save/rejoin; see `operations/PHASE36_BAKERY_DEPARTMENT.md`.
- [ ] Studio verification of Golden Apples shipment, produce stock, migration, basket math, helper permissions, and save/rejoin; see `operations/PHASE17_GOLDEN_APPLES.md`.
- [ ] Studio verification of employee automation toggles, delayed timer cancellation, roles, v1–v11 migration and save/rejoin; see `operations/PHASE18_EMPLOYEE_AUTOMATION.md`.
- [ ] Studio verification of the palette preview/reset, purchase, role permissions and save/rejoin; see `operations/PHASE19_STOREFRONT_PREVIEW.md`.
- [ ] Studio verification of delivery-worker hire/migration, SKU receipts, pause/resume, player races and save/rejoin; see `operations/PHASE20_DELIVERY_WORKER.md`.
- [ ] Studio verification of cereal stocking, order/receipt, basket math, HUD and v1–v13 migration; see `operations/PHASE21_SUNRISE_CEREAL.md`.
- [ ] Later phases: broader economy (including scheduled operations costs), seasonal/live operations, production commerce and release work remain gated by the specification, Studio validation and explicit release approval.
