# Architecture decision records

Record decisions that change product scope, trust boundaries, persistence, dependencies, deployment, or data contracts. Each record includes context, decision, alternatives, consequences, verification needs and date. Keep unresolved items open until evidence supports a choice.

## ADR-0001 — Keep Phase 0 limited to the foundation
- **Status:** Accepted — 2026-10-12
- **Context:** The master brief defines G0 as architecture/foundation approval and requires stopping before Phase 1.
- **Decision:** Establish the documentation and project scaffold, assess local tooling, and stop for G0 review. Do not add gameplay implementation in this milestone.
- **Consequences:** Runtime assumptions remain proposed; Phase 1 may revise them after Studio/toolchain validation.

## ADR-0002 — Player-owned store profiles
- **Status:** Accepted — 2026-10-12; see [ADR-0002](ADR-0002-player-owned-store-profiles.md).
- **Decision:** Persistent progression belongs to an individual Roblox player. The first player in a server owns that server's one store; multiplayer helpers and role permissions are a Phase 3 feature.

## ADR-0003 — Persistent warehouse expansion
- **Status:** Accepted — 2026-10-12; see [ADR-0003](ADR-0003-persistent-warehouse-expansion.md).
- **Decision:** Add a server-validated $200 warehouse annex as the first Phase 7 increment; persist ownership per player and rebuild its procedural world model on load.

## ADR-0004 — Serialize profile saves
- **Status:** Accepted — 2026-10-12; see [ADR-0004](ADR-0004-serialize-profile-saves.md).
- **Decision:** Serialize DataStore writes for each player profile so gameplay, autosave and release writes cannot overlap for the same in-memory entry.

## ADR-0005 — Keep warehouse deliveries server-authoritative
- **Status:** Accepted — 2026-10-12; see [ADR-0005](ADR-0005-warehouse-delivery-loop.md).
- **Decision:** Persist backstock and one pending shipment; the server charges, times, validates and receives the shipment.

## ADR-0006 — Keep customer traffic bounded and server-owned
- **Status:** Accepted — 2026-10-12.
- **Context:** The first shift had one static customer and one sale, which did not establish a customer operations loop.
- **Decision:** Each shift serves at most three customers using a server-scripted entrance, browse, queue, checkout and exit route. The server's existing sale transition owns stock and revenue; the persisted sales count reconstructs remaining customer traffic.
- **Consequences:** No customer persistence fields, PathfindingService loops or client remotes are needed. Fixed routes are bounded and have a 12-second queue-position recovery. Product choice and baskets are implemented through the later multi-product increments; broader preference simulation and larger traffic events remain future work.
- **Verification:** See `docs/operations/PHASE8_CUSTOMERS.md`; Roblox Studio runtime checks remain pending.

## ADR-0007 — Persist chaos interruptions in the shift stage
- **Status:** Accepted — 2026-10-12.
- **Context:** A temporary event must survive player rejoin without trusting client event state or adding unnecessary event records.
- **Decision:** The checkout spill is represented by the versioned `Spill` shift stage. The server owns eligibility, role authorization, cleanup reward and resume transition. Profile schema v5 admits this stage; older profile shapes migrate through the existing normalizer.
- **Consequences:** The event has no client remote, deadline or destructive failure state. If cleanup is delayed, the queue waits safely until an authorized player resumes it. Customer Rush and Power Outage require separate eligibility and recovery rules before implementation.
- **Verification:** See `docs/operations/PHASE9_CHAOS.md`; persistence and Studio runtime checks remain pending.

## ADR-0008 — Route employee automation through existing economy transitions
- **Status:** Accepted — 2026-10-12.
- **Context:** New employees should reduce repetitive work without receiving client authority over currency, inventory, or stage.
- **Decision:** A persistent Cleaner flag unlocks a five-second spill response. It calls the same server-owned cleanup transition as a player; the first valid cleanup changes the stage and makes any racing response a no-op.
- **Consequences:** Profile schema v6 adds only a validated employee boolean. No employee remote, independent reward code, wage loop, or client-driven automation is introduced.
- **Verification:** See `docs/operations/PHASE10_EMPLOYEES.md`; Studio migration, purchase, persistence, and race checks remain pending.

## ADR-0010 — Bound and recover the checkout power outage
- **Status:** Accepted — 2026-10-12.
- **Context:** The master spec calls for manageable chaos events with eligibility, duration, objectives, cleanup and safe recovery.
- **Decision:** Persist the active outage stage and a 30-second server deadline. Since Phase 31, the server-derived shift plan schedules it after sale 1 or 2. Owner, Manager or Maintenance can restore power early at a physical breaker; the server restores it automatically at the deadline if no one acts.
- **Consequences:** Profile schema v8 adds one timestamp and allows `PowerOutage`; previous profiles migrate to zero/no outage. The event does not grant an extra reward, destroy stock, or punish players if unattended. Lighting and checkout readiness are presentation controlled by the server stage.
- **Verification:** See `docs/operations/PHASE12_POWER_OUTAGE.md`; Studio timing, save/rejoin and role tests remain pending.

## ADR-0011 — Make Customer Rush a bounded bonus queue
- **Status:** Accepted — 2026-10-12.
- **Context:** The core supermarket needs a meaningful rush event without making normal shift completion depend on an optional event.
- **Decision:** After the three baseline customers, open a 60-second queue with two bonus customers. Serving both grants `$20` once; timeout closes only the bonus queue and leaves the normal shift available for closeout.
- **Consequences:** Profile schema v9 saves the rush deadline; up to five customers are reconstructed from sales and the active deadline. Sales still use server catalog prices and inventory. The client timer is display-only; the server validates sale deadline, completion reward and timeout.
- **Verification:** See `docs/operations/PHASE13_CUSTOMER_RUSH.md`; Studio timing, cashier, race and rejoin tests remain pending.

## ADR-0012 — Derive customer baskets from shift progress
- **Status:** Accepted — 2026-10-12.
- **Context:** Two products are available, but checkout still represents each shopper as a single-item purchase and the next SKU is chosen by a fixed one-product rule.
- **Decision:** Generate a bounded five-pattern basket intent from the server's next customer number; resolve it against server shelf quantities and transact all included item deductions and catalog-price credits as one customer sale. Derive the display and intent again after rejoin rather than persisting redundant basket data.
- **Consequences:** A two-unit basket consumes two units but increments customer sales once. Out-of-stock preferences can reduce to the available items, with a one-item fallback when no preferred item is available. Existing schema v9 needs no migration. The behavior remains deterministic and does not model discounts or customer-specific negotiation.
- **Verification:** See `docs/operations/PHASE14_CUSTOMER_BASKETS.md`; checkout, fallback, race and save/rejoin cases await Studio verification.

## ADR-0013 — Persist one server-purchased storefront palette
- **Status:** Accepted — 2026-10-12.
- **Context:** Store growth should be visible in the environment, and the master specification identifies store customization as a Phase 2 foundation.
- **Decision:** Offer one fixed Coastal Market palette for `$180` at a physical pad after shift completion. Validate and charge on the server, persist a boolean ownership flag, and apply it to selected original procedural storefront parts.
- **Consequences:** Profile schema v10 adds `ownedUpgrades.marketStyle`; schemas v1–v9 default to the original palette. This is a first customization step, not arbitrary editing. No product/economy changes or external assets are introduced.
- **Verification:** See `docs/operations/PHASE15_STOREFRONT_STYLE.md`; purchase, visual and migration checks await Studio verification.

## ADR-0014 — Derive customer reactions from the active shift stage
- **Status:** Accepted — 2026-10-12.
- **Context:** Customers should visibly acknowledge operational chaos without gaining authority over the event or checkout.
- **Decision:** Set customer queue billboard text from the current server-owned `Spill`, `PowerOutage`, and `CustomerRush` stages, and restore normal labels when the stage resolves.
- **Consequences:** Reactions are presentation-only, use existing stage updates and queue recovery, and require no remotes, profile fields, or migration. Animation/audio/patience behaviors remain future work.
- **Verification:** See `docs/operations/PHASE16_CUSTOMER_EVENT_REACTIONS.md`; Studio reaction and recovery checks await verification.

## ADR-0015 — Extend the catalog with warehouse-backed Golden Apples
- **Status:** Accepted — 2026-10-12.
- **Context:** The visible produce department was decorative and the existing product flow supported only drinks/snacks.
- **Decision:** Add Golden Apples as a third server-catalog product, with a bounded shelf, warehouse backstock, one product-tagged pending shipment, produce shelf, customer baskets, and catalog-priced checkout. Persist the quantities using the existing profile and shipment structures.
- **Consequences:** Profile schema v11 adds Golden Apples counts and accepts its shipment ID. Existing warehouse profiles missing the new field migrate to six backstock apples; profiles without a warehouse get zero. Restock quantity is three, shelf cap 24, order is 18 for `$35`, and retail unit price is `$12`.
- **Verification:** See `docs/operations/PHASE17_GOLDEN_APPLES.md`; gameplay, migration and shipment checks await Studio verification.

## ADR-0016 — Persist per-employee automation controls
- **Status:** Accepted — 2026-10-12.
- **Context:** Employees currently act automatically whenever their existing stage becomes eligible, with no owner control over the behavior.
- **Decision:** Add one persistent enabled flag per hired cashier, stock clerk, and cleaner. Owner/Manager prompts toggle each flag. Automation callbacks carry generation tokens and recheck the current flag and session lease before using the existing economy action.
- **Consequences:** Profile schema v12 defaults v1–v11 profiles to enabled, preserving prior behavior. Pausing does not unhire staff or disable player-operated actions. The controls do not add wages or expand employee behavior.
- **Verification:** See `docs/operations/PHASE18_EMPLOYEE_AUTOMATION.md`; Studio permissions, pause timing, races and migration checks remain pending.

## ADR-0017 — Keep storefront previews temporary until purchase
- **Status:** Accepted — 2026-10-12.
- **Context:** The fixed Coastal Market upgrade had no way to inspect its visual result before paying.
- **Decision:** Add an Owner/Manager-only preview action on a separate pad. The server applies the fixed palette transiently and restores the saved/default palette when canceled or when the completed-shift state ends. Purchase remains a separate server-priced action.
- **Consequences:** Existing schema v10 ownership remains unchanged and no preview state is persisted. The preview is visible to the entire server because the store world is shared; isolated per-player previews and additional palettes remain future work.
- **Verification:** See `docs/operations/PHASE19_STOREFRONT_PREVIEW.md`; Studio palette, permission and purchase checks remain pending.

## ADR-0018 — Let a hired delivery worker receive arrived stock
- **Status:** Accepted — 2026-10-12.
- **Context:** Warehouse owners had to manually receive every shipment at the dock even after hiring other employees.
- **Decision:** Add a persistent warehouse-only delivery worker who can automatically receive an arrived shipment through the existing server receipt transaction. The worker has the same owner-controlled automation setting as other employees; paused workers leave shipments available for manual receipt.
- **Consequences:** Profile schema v13 adds the hire and automation flags. Existing profiles default to no worker with automation enabled. Shipment prices, IDs, quantities, backstock limits, and the one-pending-shipment rule do not change.
- **Verification:** See `docs/operations/PHASE20_DELIVERY_WORKER.md`; Studio migration, timer and race checks remain pending.

## ADR-0019 — Add Sunrise Cereal through the existing SKU pipeline
- **Status:** Accepted — 2026-10-12.
- **Context:** The pantry/cereal fixture was present but remained decorative, leaving the retail loop limited to three stocked products.
- **Decision:** Add fictional Sunrise Cereal as a fourth catalog SKU, wired through bounded shelf/backstock counts, the existing one-shipment system, customer baskets and atomic catalog-priced sales.
- **Consequences:** Profile schema v14 stores cereal quantities and allow-lists the shipment product ID. Warehouse profiles missing the new field receive six backstock boxes; non-warehouse profiles receive none. Shipment ordering remains one-at-a-time and uses the existing delivery worker/manual receipt.
- **Verification:** See `docs/operations/PHASE21_SUNRISE_CEREAL.md`; Studio visual, migration, basket and receipt checks remain pending.

## ADR-0020 — Keep player pricing within a bounded catalog range
- **Status:** Accepted — 2026-10-12.
- **Context:** Fixed retail prices left no store-management choice, while arbitrary client-selected prices would make checkout and persistence unsafe.
- **Decision:** Let the owner or authorized Manager cycle each SKU through a server-derived 80%, 100%, and 125% price option. Persist the exact allow-listed integer per SKU and use it in basket display and checkout.
- **Consequences:** Profile schema v15 stores four prices; schemas v1–v14 use catalog prices. Phase 33 later connects premium pricing to the separate satisfaction score, but prices still do not change customer demand or sale probability.
- **Verification:** See `docs/operations/PHASE22_PRODUCT_PRICING.md`; Studio role, transaction, tag and migration checks remain pending.

## ADR-0021 — Keep price response bounded and reconstructable
- **Status:** Accepted — 2026-10-12.
- **Context:** Price controls need a measurable effect on store demand without introducing random outcomes or redundant saved state.
- **Decision:** A below-catalog single-SKU basket buys one additional unit when stock permits; an above-catalog multi-unit request buys one fewer. Mixed baskets and catalog-priced quantities remain unchanged.
- **Consequences:** Basket quantity is derived from the existing sales count, current saved price and shelf inventory; no new schema fields or random customer state are needed. Satisfaction and product substitution remain future work.
- **Verification:** See `docs/operations/PHASE23_PRICE_SENSITIVE_BASKETS.md`; Studio quantity, stock, race and rejoin checks remain pending.

## ADR-0022 — Reuse player restock transitions for the stock clerk
- **Status:** Accepted — 2026-10-12.
- **Context:** The first stock clerk only filled Citrus Pop at shift start, leaving the warehouse SKUs and later empty shelves to manual restocking.
- **Decision:** After the initial objective, let a hired enabled stocker inspect the next server-owned basket and restock one preferred empty SKU when a complete batch is in backstock. Manual and employee work share existing SKU transitions; repeated Citrus Pop restocking uses the same bounded batch path.
- **Consequences:** Citrus Pop shelf stock is now capped at 24 in schema v15 validation. No new employee profile fields or client-selected SKU/quantity are introduced. Forecasting, wages and full shelf maintenance remain future work.
- **Verification:** See `docs/operations/PHASE24_STOCKER_REPLENISHMENT.md`; Studio timer, stock, permission and recovery checks remain pending.

## ADR-0023 — Keep Customer Assistant benefits in presentation
- **Status:** Accepted — 2026-10-12.
- **Context:** The employee specification calls for a Customer Assistant while customer basket and checkout rules must remain server-authoritative and reproducible.
- **Decision:** Hire a persistent assistant for a fixed `$160` after a completed shift. The employee shortens only customer aisle-browsing travel time by a fixed 30%; it cannot select products, alter basket math or grant sales.
- **Consequences:** Profile schema v16 adds one optional hire flag; older profiles default to not hired. The existing customer route and server sale transaction remain authoritative.
- **Verification:** See `docs/operations/PHASE25_CUSTOMER_ASSISTANT.md`; timing, role and migration checks remain pending in Studio.

## ADR-0024 — Measure repeat play with a server-side funnel
- **Status:** Accepted — 2026-10-12.
- **Context:** The existing funnel measured only the first shift, while the specification calls for repeat-engagement measurement.
- **Decision:** Add a three-step repeat-shift funnel from server-confirmed first completion, another shift start and repeat completion. Existing profiles begin at a returning-profile step. Keep IDs in server memory and gate all events to the configured development universe.
- **Consequences:** No schema, client remote, custom player identifier or economic payload is added. Analytics API failure is non-blocking; dashboard ingestion and retention interpretation still require platform verification.
- **Verification:** See `docs/operations/PHASE26_REPEAT_SHIFT_ANALYTICS.md`; Studio/dashboard and failure-isolation checks remain pending.

## ADR-0025 — Begin store construction with a fixed server-approved slot
- **Status:** Accepted — 2026-10-12.
- **Context:** The store-building requirements call for persistent construction, but free-form client transforms would add a large unreviewed input surface and collision risk.
- **Decision:** Add one sequential `$220` department expansion after the first shelf bay. The server chooses a fixed interior slot and persists only the allow-listed ownership flag in profile schema v17.
- **Consequences:** This visibly grows the store and exercises purchase, prerequisite, permission and persistence paths. Free placement, rotation, plot ownership and editable inventory layout remain future work.
- **Verification:** See `docs/operations/PHASE27_HOUSEHOLD_AISLE_EXPANSION.md`; Studio and DataStore checks remain pending.

## ADR-0026 — Settle fixed employee wages during shift closeout
- **Status:** Accepted — 2026-10-12.
- **Context:** The economy had employee purchase costs but no recurring operating expense, so the store owner could not see the ongoing cost of staffing.
- **Decision:** Assign each hired role a small fixed wage per completed shift. Credit the existing shift bonus and deduct total wages within the one guarded server closeout transition. Pausing automation does not waive wages.
- **Consequences:** The current balance remains the single persisted monetary source; no wage debt or profile schema field is introduced. More detailed schedules and other operating expenses remain future work.
- **Verification:** See `docs/operations/PHASE28_SHIFT_PAYROLL.md`; Studio transaction, HUD and persistence checks remain pending.

## ADR-0027 — Keep warehouse layout edits server-authoritative
- **Status:** Accepted — 2026-10-12.
- **Context:** The store-building specification calls for placement, rotation, collision validation and persistent layouts. Free client transforms could intersect fixed warehouse structure or bypass costs and ownership.
- **Decision:** Start with an editable fixture type in a bounded, snapped warehouse zone. The client previews proposed changes; server-side `LayoutService` checks each position/orientation against the grid, bounds and other fixtures, then the server creates and persists the result.
- **Consequences:** Profile schema v18 stores compact versioned shelf records. Layouts cap at six shelves, rotate in 90-degree increments, cost `$50` to place and refund `$25` to remove. Main-floor placement, other object types and plots remain future work.
- **Verification:** See `docs/operations/PHASE29_WAREHOUSE_LAYOUT_EDITOR.md`; Studio and DataStore checks remain pending.

## ADR-0028 — Make customer preference variety reproducible
- **Status:** Accepted — 2026-10-12.
- **Context:** The short customer loop repeated a fixed five-basket sequence and showed no shopping persona, while rejoin reconstruction must remain stable.
- **Decision:** Draw Everyday, Value shopper, Family shop, and Treat stop preferences with respective 40/25/20/15 weights using completed-shift count and sale number. Keep stock resolution, price response, and checkout totals in Economy; send only display strings to the world presentation layer.
- **Consequences:** No new profile schema or remote is required. A deterministic weighted sample may not match the nominal ratios in a small number of visits. Customer archetypes currently influence product preference only; deeper budget, patience and loyalty behavior remains future work.
- **Verification:** See `docs/operations/PHASE30_CUSTOMER_PREFERENCES.md`; Studio and DataStore checks remain pending.

## ADR-0029 — Derive a repeatable chaos schedule per shift
- **Status:** Accepted — 2026-10-12.
- **Context:** Spill and power outage always occurred in the same order, making repeat shifts predictable, while saving a client-authored plan would create an unnecessary authority boundary.
- **Decision:** Derive one of four bounded spill/outage plans from the server-known owner UserId and validated completed-shift count. Recompute the same plan after rejoin; continue persisting only active event stage and existing deadlines.
- **Consequences:** No extra profile field, remote argument, or randomness dependency is introduced. Schedules vary across shifts but remain reproducible; they currently cover only spill and outage. Power outage may now be active after sale 1 or 2, so saved-stage validation accepts either.
- **Verification:** See `docs/operations/PHASE31_CHAOS_DIRECTOR.md`; Studio schedule, recovery, multiplayer and rejoin checks remain pending.

## ADR-0030 — Persist and validate customer-facing shelf positions
- **Status:** Accepted — 2026-10-12.
- **Context:** The store-building specification calls for shelf repositioning and rotation. Fixed product shelves made the store look static and made department routes independent of physical layout.
- **Decision:** Keep the four existing SKU shelf models, prompts and price tags server-owned. Let Owner/Manager move each on a bounded two-stud retail grid and rotate it by 90 degrees. Persist only product-keyed coordinates/orientations in profile schema v19 and derive customer browse targets from those positions.
- **Consequences:** v1-v18 profiles receive the known starter positions. Server validation blocks malformed records, out-of-bounds placement, product shelf overlap and fixed expansion bays. No new economy charge or arbitrary object placement is introduced; checkout positioning, floor expansion, plots and new department construction remain future work.
- **Verification:** See `docs/operations/PHASE32_RETAIL_LAYOUT.md`; Studio controls, migration, collision, routing and save/rejoin checks remain pending.

## ADR-0031 — Score customer satisfaction without changing checkout accounting
- **Status:** Accepted — 2026-10-12.
- **Context:** Weighted product preferences and price tiers create visible fulfillment differences, but players had no persistent signal showing whether the store met demand.
- **Decision:** Persist an integer satisfaction score from 0 to 100, initialize legacy profiles at 75, raise it by 3 for complete preferred quantities, lower it by 6 for partial/fallback baskets, and subtract 2 per premium-priced SKU. Apply the bounded delta only inside a successful server sale and show the score to authorized store members.
- **Consequences:** Profile schema v20 adds one validated score. It does not alter cash, stock, sales, rush eligibility or rewards. Loyalty, demand, substitution, patience and reputation effects remain future work.
- **Verification:** See `docs/operations/PHASE33_CUSTOMER_SATISFACTION.md`; Studio transaction, migration, rejoin and privacy checks remain pending.

## ADR-0032: Move checkout as one saved fixture
- **Decision:** Persist a bounded checkout lane transform with retail shelf layout; move its props, cashier, customer queue and derived approach routes together. Server validates bounds and fixture collisions.
- **Consequences:** Profile schema v21 migrates existing shelf layouts without moving their departments. Rotated display readability and customer navigation need Studio verification.
- **Verification:** See `docs/operations/PHASE34_CHECKOUT_LAYOUT.md`.

## ADR-0033: Persist a fixed rear store expansion
- **Decision:** Unlock a fixed rear retail wing after the household aisle; charge once, construct it server-side, and only allow shelf layout records in its marked zone when owned.
- **Consequences:** Profile schema v22 stores the purchase and migrates older profiles with the wing disabled. Customer routes use the fixed opening; the existing product inventory and checkout remain authoritative.
- **Verification:** See `docs/operations/PHASE35_REAR_FLOOR_EXPANSION.md`.

## ADR-0034: Add a persistent, fixed bakery department
- **Decision:** Add a `$350` bakery after the rear wing and warehouse. Build its fixture server-side and connect Cinnamon Twists to saved stock, price, supplier delivery, customer baskets and checkout.
- **Consequences:** Profile schema v23 migrates old profiles with bakery ownership off; shelf layout validation reserves the bakery fixture.
- **Verification:** See `docs/operations/PHASE36_BAKERY_DEPARTMENT.md`.

## ADR-0035: Resolve unavailable basket items through server-owned substitutes
- **Decision:** Select related substitutes from an ordered server catalog, charge and route using the actual SKU, label the change, and score partial fulfillment.
- **Consequences:** No schema migration or client authority is added; satisfaction reflects substitute and unfilled quantities.
- **Verification:** See `docs/operations/PHASE37_PRODUCT_SUBSTITUTION.md`.

## ADR-0036: Derive customer regulars and patience from satisfaction and queue time
- **Decision:** High satisfaction adds a deterministic Neighborhood regular basket; server-measured front-of-line wait affects satisfaction with a bounded penalty.
- **Consequences:** No schema migration. Offline time and blocked operations do not count toward patience.
- **Verification:** See `docs/operations/PHASE38_LOYALTY_AND_PATIENCE.md`.

## ADR-0009 — Keep product inventory and supplier orders SKU-specific
- **Status:** Accepted — 2026-10-12.
- **Context:** The retail loop needs visible department variety and product-specific stock behavior while keeping stock and money authoritative.
- **Decision:** Add Citrus Pop and Berry Bites to a server-only catalog. Persist separate shelf/backroom quantities and tag the one pending delivery with a product ID. Checkout chooses products from server shift state and available shelf stock.
- **Consequences:** Profile schema v7 migrates old warehouses with 12 Berry Bites backstock and assigns old untagged shipments to Citrus Pop. Berry Bites orders cost `$45`, supply 24 packs, and stock in groups of four; the existing Citrus Pop values remain unchanged. Client messages/HUD display only sanitized store data.
- **Verification:** See `docs/operations/PHASE11_PRODUCTS.md`; Studio purchase, save/rejoin, permission and race checks remain pending.
