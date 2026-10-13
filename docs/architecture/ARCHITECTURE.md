# Technical architecture (proposed)

## Boundaries
```mermaid
flowchart LR
  UI[Client UI and input] -->|intent only| Gateway[Server request gateway]
  Gateway --> Auth[Validation, permission, rate limit]
  Auth --> Domain[Business Engine: pure rules]
  Domain --> Services[Server gameplay services]
  Services --> Store[Store / customer / shift state]
  Services --> Persistence[Persistence adapter]
  Services -->|sanitized state/events| UI
  UI --> Presentation[Local animation, sound, effects]
```

## Authority and modules
- **Client:** input, contextual UI, camera, animations and non-authoritative effects. It requests actions and renders server-confirmed outcomes.
- **Server request gateway:** narrow RemoteEvent/RemoteFunction entry points; payload schema, size, rate, ownership, permission, range and state checks; no arbitrary client-selected object paths or prices.
- **Business Engine:** pure Luau domain rules for catalog, stock, checkout math, upgrade eligibility/cost, shift results and event state transitions. No Roblox service access or persistence side effects; deterministic functions are unit-testable.
- **Gameplay services:** server-owned orchestration for store, inventory, customers, checkout, shift, chaos, upgrades and permissions. Services call domain functions and emit state changes.
- **Persistence adapter:** versioned schema, migration, session/write coordination, retries and recovery; never let stale saves overwrite newer state. `ProfileService` serializes writes per player across gameplay commits, autosave and release. Roblox DataStore specifics and budgets still need Studio/platform verification.
- **Content/config:** server-validated product catalog, upgrade definitions, event definitions, UI copy, and buildable layout definitions. Client may receive only safe display data.

## Initial proposed layout
`src/ServerScriptService/` server bootstrap and services; `src/ReplicatedStorage/Shared/` shared types/catalog/domain-safe definitions; `src/StarterPlayer/StarterPlayerScripts/` client controllers; `src/StarterGui/` interface; `default.project.json` Rojo mapping; `docs/` product, design, architecture, security, operations. Mapping is a foundation only; Studio sync and runtime are unverified.

## Business Engine boundaries
Expose pure functions for validate/price/compute transitions and return explicit success or typed failure results. Accept normalized domain records, not raw remotes or Instances. The server resolves player, store and object ownership before calling rules. Keep rendering, pathfinding, DataStore access, analytics transport and Marketplace calls outside the engine.

## Persistence/economy invariants
Currency and stock changes occur only after server-side validation. Transactions have stable IDs and idempotent application. A receipt or saved operation cannot be granted twice. Schema has version and migration path. Session coordination and conflict strategy must be tested against actual DataStore semantics before release.

## Phase 2 profile implementation
- `ProfileService` owns server-only DataStore access. The client receives only a sanitized shift snapshot and a save-status label.
- Each profile is keyed by `Player.UserId`, stores an explicit schema version, balance, current shift, owned upgrades and progression counters, and is normalized before use.
- An atomic `UpdateAsync` claim writes a unique server lease with expiry. Saves and lease refreshes verify the lease; autosave, PlayerRemoving and BindToClose attempt final writes/releases.
- A per-profile save guard ensures only one `UpdateAsync` save is in flight for the same profile; later gameplay/autosave/release saves wait and recheck the profile's current lease state.
- Store interactions are rejected for visitors and while the owner's profile is loading or its lease is known lost. One server has one store owner until the Phase 3 guest/role model.
- DataStore failures fall back to a fresh session-only profile; that profile is never written over the persistent record. The HUD exposes this state.
- G2 remains pending actual Studio testing, including two-server lock contention and failure recovery. This custom lease is a first implementation and is not yet a security certification.

## Phase 7 warehouse delivery and Phase 9–10 operations increments
- Profile schema v5 stores warehouse Citrus Pop backstock, pending shipment quantity and a Unix ready timestamp. Schemas v1–v4 receive 12 initial backstock cans; malformed or out-of-bound quantities/timestamps reject the profile rather than being silently trusted. Schema v5 adds `Spill` to the bounded shift-stage allowlist without introducing client-provided event data.
- `Economy.orderDelivery` owns the $60 transaction, 24-can shipment size, single-pending-order rule and 500-can backstock cap. `Economy.receiveDelivery` applies a due shipment once, then clears its pending fields.
- `ShiftService` authorizes both delivery prompts through Owner/Manager roles, server-side proximity and the common interaction rate limit. The shipment timer is reconstructed from the saved timestamp after a rejoin.
- Delivery presentation is created by `WorldBuilder`; the client receives only sanitized counters for store members. Developer commerce and Robux are not involved.
- `Economy.sellProduct` activates a bounded checkout-spill event after the first shift sale. `Economy.cleanSpill` pays the fixed $5 reward once and restores `Checkout`; server role, stage, range and rate checks gate the physical prompt. If a player leaves during the event, the persisted `Spill` stage reconstructs the objective. There is no event timer or destructive failure path.
- `WorldBuilder` presents at most three customers on a fixed, server-scripted enter/browse/queue/exit route. Shift sales reconstruct how many remain; a 12-second route fallback moves them to safe checkout positions. Customer models never grant currency; only the existing server sale transaction does.
- Profile schema v6 adds a validated `cleaner` employee boolean. Schemas v1–v5 default to no Cleaner; hiring takes the server-defined $120 once. A five-second server timer rechecks owner, save lock, employee flag and `Spill` stage before using the shared cleanup transition.

## Phase 7 multi-product increment
- Profile schema v7 persists Berry Bites shelf and backroom counters plus a product ID for the single pending warehouse shipment. Prior profiles normalize to zero shelf stock and 12 Berry Bites backstock if they already own the warehouse; legacy untagged shipments migrate as Citrus Pop.
- `Economy.PRODUCTS` defines server-owned Citrus Pop (`$25` sale, `$60`/24-can shipment), Berry Bites (`$18` sale, `$45`/24-pack shipment), Golden Apples and Sunrise Cereal. Product stock shares the per-SKU backroom cap and one-pending-shipment rule; each SKU retains its own price, shipment size, and restock limit.
- Checkout chooses the next SKU from server shift progress and available shelf stock, and the customer route/shelf visuals follow that choice. No client product/price argument is accepted.
- Owner/Manager can order either SKU; Owner/Manager/Stocker can stock Berry Bites. Existing prompt checks still enforce owner profile readiness, membership, role, distance and cooldown. See `operations/PHASE11_PRODUCTS.md` for acceptance and Studio verification.

## Phase 4 Power Outage increment
- Profile schema v8 persists the `PowerOutage` shift stage and a bounded Unix recovery timestamp. The normalizer accepts this pair only when the stage is active and a timestamp is present; older profiles default to no outage.
- The second server-priced sale starts a 30-second outage. Manual restoration at the checkout breaker returns to `Checkout` immediately; a server timer restores the queue after the deadline if nobody responds. Neither path adds a separate reward or sale.
- Owner/Manager/Maintenance may restore power, with the common prompt range, role, profile lease and rate checks. Cashier automation is paused by the stage and restarts on recovery. `WorldBuilder` owns only presentation: lighting, breaker sign and prompt.
- See `operations/PHASE12_POWER_OUTAGE.md`; Studio timer, persistence, role and visual behavior remain unverified.

## Phase 4 Customer Rush increment
- Profile schema v9 persists a `customerRushUntil` timestamp with the `CustomerRush` stage. Earlier schema versions default to no active rush; inconsistent stage/deadline pairs reject the profile.
- Completing the three normal sales starts a 60-second rush with two additional shoppers only when two shelf units remain. All rush sales use `Economy.sellProduct` and the existing product catalog. Clearing both pays one `$20` reward and proceeds to closeout; timeout drops only the unserved bonus queue and offers normal closeout without the reward. Insufficient stock proceeds to ordinary closeout without a rush.
- Customer models are bounded to five and reconstructed from saved sales/deadline. Cashier automation is allowed during the rush but the economy checks its deadline. `ShiftService` expires it only after checking the owner and save lock.
- See `operations/PHASE13_CUSTOMER_RUSH.md`; Studio queue, payout, timeout, automation and persistence checks remain pending.

## Phase 4 customer basket increment
- `Economy.getNextCheckoutBasket` derives a bounded basket pattern from the next server-owned customer number and resolves it against current shelf quantities for all catalog SKUs. It returns item names, quantities and catalog prices for display; `sellProduct` recomputes the basket and applies all deductions and credits as one customer transaction.
- Each basket increments `sales` once, so customer queues and chaos thresholds remain customer-based. If a preferred SKU is unavailable, its item is omitted; when no preferred item can be supplied, one stocked SKU is used. Empty shelves reject checkout without mutation.
- The next intent is reconstructed from the persisted sales count and current saved inventory. Profile schema v9 does not change. The world route and HUD only display the server decision and cannot control it.
- See `operations/PHASE14_CUSTOMER_BASKETS.md`; runtime pricing, stock, routing and rejoin checks remain pending.

## Phase 2 storefront customization increment
- `Economy.buyMarketStyle` checks the completed-shift state, existing ownership and fixed `$180` cost. `ShiftService` enforces Owner/Manager authorization, prompt distance, save readiness and interaction rate before calling the domain transition.
- Profile schema v10 persists `ownedUpgrades.marketStyle`; older schemas normalize to false. `WorldBuilder` changes a fixed set of fascia, sign, canopy and header colors and disables its purchase prompt after ownership. The palette is reapplied on profile load and is independent of shift restart.
- See `operations/PHASE15_STOREFRONT_STYLE.md`; Studio purchase, appearance, migration and rejoin checks remain pending.

## Phase 4 customer event reaction increment
- `WorldBuilder.setStage` changes visible queue labels for `Spill`, `PowerOutage` and `CustomerRush`. Customer route completion and queue recovery consult the same stage-derived label helper.
- Reactions are client-visible world presentation driven by server state. They do not alter `Economy`, persistence, deadlines or interaction permissions and add no remotes or profile fields.
- See `operations/PHASE16_CUSTOMER_EVENT_REACTIONS.md`; Studio appearance and route recovery checks remain pending.

## Phase 7 produce SKU increment
- Golden Apples use the existing product catalog, product-ID shipment, basket transaction, warehouse ownership and remote/prompt security boundaries. Order/receive/stock/sale transitions remain in the pure economy module; services orchestrate presentation, persistence and server authorization.
- Profile schema v11 persists `shift.goldenAppleStock`, `warehouseInventory.goldenApples`, and the already-generic shipment product ID. Legacy warehouse profiles with no apple field receive six backstock apples; no-warehouse profiles receive zero. Existing Citrus/Berry values and pending shipments normalize unchanged.
- The physical produce shelf and HUD are projections of authoritative counts. Customer baskets derive apple intent from customer number and use current stock; they require no saved order field.
- See `operations/PHASE17_GOLDEN_APPLES.md`; Studio migration, sale and shipment verification remain pending.

## Phase 4 employee automation controls
- `Economy` allow-lists cashier, stocker and cleaner automation changes and rejects toggles unless the selected employee is hired. Separate fixed board prompts are Owner/Manager-only through the existing ShiftService authorization gate.
- Profile schema v12 stores the three boolean settings. Missing values in v1–v11 profiles normalize to enabled, preserving earlier automation behavior.
- Each delayed automation uses a generation token and rechecks hire state, the saved automation flag, current stage, owner readiness and profile lease. Toggling off invalidates pending work; each eventual action still goes through the existing economy transition.
- Board prompt text and employee visibility are presentation only. See `operations/PHASE18_EMPLOYEE_AUTOMATION.md`; Studio behavior and migration checks remain pending.

## Phase 2 storefront preview
- Coastal Market preview is transient server state. Owner/Manager can apply or cancel the fixed palette at a separate prompt; leaving the completed-shift state resets an unpurchased preview.
- Purchase remains the existing server economy transaction and profile v10 ownership flag. No preview preference or schema migration is saved. The shared physical store means all current server players see the preview. See `operations/PHASE19_STOREFRONT_PREVIEW.md`; Studio verification remains pending.

## Phase 4 delivery worker
- The worker is gated on warehouse ownership and a completed shift. Its Owner/Manager automation toggle is saved with the other employees in profile schema v13.
- A delayed pickup is keyed to the current shipment ready timestamp and generation token; it rechecks hire, automation, owner/session and save-lock state before using `Economy.receiveDelivery`. Manual receipt and auto-receipt converge on that same transaction.
- The shipment remains singular and SKU-specific. See `operations/PHASE20_DELIVERY_WORKER.md`; Studio timer, race and migration checks remain pending.

## Phase 7 Sunrise Cereal SKU
- Sunrise Cereal uses the existing catalog-driven order, receipt, basket and checkout paths. Shelf stock and backstock are separate server-owned quantities; restocking moves three boxes, each worth `$16`, with an 18-box `$45` shipment.
- Profile schema v14 validates cereal counters and warehouse ownership, adds the SKU to the single pending shipment allow-list, and migrates older warehouse profiles with six boxes when absent. The delivery worker and manual dock use the same receipt transaction.
- The pantry shelf, customer route, order label and four-SKU HUD reflect current server state only. See `operations/PHASE21_SUNRISE_CEREAL.md`; Studio acceptance remains pending.

## Phase 2 product pricing
- The owner or Manager cycles each shelf through three fixed prices derived from its catalog base. Shelf tags and the next basket total reflect the saved server state.
- Profile schema v15 allow-lists four product IDs and their exact integer price options; schemas v1–v14 default to catalog prices. Checkout recomputes each unit price before applying an atomic basket sale.
- See `operations/PHASE22_PRODUCT_PRICING.md`; demand response and Studio checks remain pending.

## Phase 4 price-sensitive customer baskets
- Basket intent is reconstructed from server shift sales. A discounted single-product basket adds one unit only when shelf stock permits; a premium multi-unit request removes one. Mixed and base-price baskets keep their intent quantities.
- Basket labels and totals are projections; checkout recomputes the same bounded quantities and price and commits one atomic sale. No new persistence fields or random demand state are introduced.
- See `operations/PHASE23_PRICE_SENSITIVE_BASKETS.md`; customer behavior and recovery checks remain pending in Studio.

## Phase 4 stocker replenishment
- The stock clerk handles the introductory Citrus Pop action and later checks the next server-owned basket intent. It restocks at most one empty preferred SKU when a full batch exists in backstock, using the same bounded economy transitions as player prompts.
- Citrus Pop can be restocked in Checkout or Customer Rush and uses a 24-can shelf cap. Profile schema remains v15; malformed/out-of-bound saved shelf stock is rejected.
- See `operations/PHASE24_STOCKER_REPLENISHMENT.md`; timers, stock races and rejoin recovery remain pending in Studio.

## Phase 4 Customer Assistant
- Hiring is an Owner/Manager-only server transaction after a completed shift. Profile schema v16 persists the employee; older profiles default to not hired.
- The visible assistant shortens only the procedural browse route. Basket intent, inventory, checkout readiness and sale math remain unchanged and server-owned.
- See `operations/PHASE25_CUSTOMER_ASSISTANT.md`; route timing and persistence checks remain pending in Studio.

## Phase 5 repeat-shift analytics
- `TelemetryService` records first-shift completion, another shift start and repeat completion using server-confirmed commits. Returning profiles start at the profile-loaded step.
- Funnel UUIDs and successful-step counters are ephemeral. Events remain gated to development universe `10770581249`; API failures do not affect gameplay or profile saving.
- See `operations/PHASE26_REPEAT_SHIFT_ANALYTICS.md`; dashboard ingestion remains pending.

## Phase 7 fixed-slot department expansion
- `Economy.buyAisleExpansion` accepts only a completed shift, existing first shelf bay, sufficient server cash and no prior expansion; the cost is fixed at `$220`.
- Profile schema v17 persists one allow-listed `ownedUpgrades.aisleExpansion` flag and rejects malformed or prerequisite-free records. Older profiles default to no expansion.
- `ShiftService` authorizes Owner/Manager through its shared prompt gate; `WorldBuilder` creates the fixture in one fixed, reviewed slot and reconstructs it on profile load. Arbitrary placement and rotation are future work.
- See `operations/PHASE27_HOUSEHOLD_AISLE_EXPANSION.md`; Studio purchase, multiplayer and save/rejoin checks remain pending.

## Phase 4 employee payroll
- `Economy.getShiftPayroll` totals fixed wages from server-owned employee hire flags. Automation pause state does not alter employment.
- `Economy.closeShift` credits the existing shift bonus and deducts the computed wages exactly once after validating the closeout stage/flag. Existing profile serialization persists only the resulting balance; schema v17 is unchanged.
- `ShiftService` exposes a computed per-shift estimate only to store members; the existing HUD status line displays it without an additional panel.
- See `operations/PHASE28_SHIFT_PAYROLL.md`; Studio transaction and save/rejoin checks remain pending.

## Phase 7 warehouse layout editor
- `LayoutService` owns pure validation for version-1 records, a bounded two-stud warehouse grid, a six-shelf cap, 0/90-degree orientations, fixture overlap and the fixed layout-board clearance.
- Owner/Manager opens the editor from a physical warehouse prompt. The client previews and proposes edits, while `ShiftService` rechecks membership, stage, warehouse ownership, profile lock, proximity, rate, action ID and payload before creating/moving/removing a shelf.
- Placement/removal cash changes and compact layout records persist via the existing serialized profile path. Schema v18 migrates old profiles to an empty layout; `WorldBuilder` rebuilds from validated records.
- See `operations/PHASE29_WAREHOUSE_LAYOUT_EDITOR.md`; client preview, Studio authorization, collision and DataStore recovery checks remain pending.
- Phase 39 stores one of three server-allow-listed storefront palette IDs beside the existing style purchase. Preview/cancel state remains in server memory; the purchase persists in profile schema v24. Legacy `marketStyle=true` profiles without an ID migrate to Coastal Market. See `operations/PHASE39_STOREFRONT_PALETTE_CHOICES.md`; Studio appearance and migration checks remain pending.
- Phase 40 adds Freezer Meals after the rear wing, warehouse and bakery. Schema v25 stores freezer ownership, shelf/backroom counts and a bounded price. Existing `Economy` flows handle SKU deliveries, restock, customer selection, substitution, checkout and stocker automation; `RetailLayoutService` rejects conflicting retail shelves. Stock and price prompts exist before the department is bought, then reparent onto the server-built fixture to retain their existing event connections. See `operations/PHASE40_FREEZER_DEPARTMENT.md`; Studio route, collision and migration verification remains pending.
- Phase 41 animates the entrance glass panels from a server-created touch sensor and explicit scripted-customer route hooks. Tween targets are fixed, the close timer is generation-guarded, and glass is non-collidable so animation cannot block traffic. No remote, profile field or economy transition is involved; see `operations/PHASE41_AUTOMATIC_ENTRANCE_DOORS.md`.
- Phase 42 applies the existing per-player layout cooldown before parsing warehouse/retail payloads, drops requests during cooldown without a response, and accepts only action-specific top-level key sets of at most five fields. Coordinate, role, range, collision and save checks still control all mutations; see `operations/PHASE42_LAYOUT_REMOTE_HARDENING.md`.
- Phase 43 adds a persistent self-checkout terminal to the movable checkout fixture. Profile schema v26 requires rear-wing and warehouse ownership. Server customer indexes select one lane, queue routes and front-of-line prompts follow that lane, and both prompt callbacks invoke the same `Economy.sellProduct` transaction. A server sale lock spans persistence and route refresh so helpers/cashier cannot race one customer twice. The cashier employee can serve either lane; see `operations/PHASE43_SELF_CHECKOUT.md`.
- Customer basket preferences use a deterministic weighted draw from completed-shift count and sale number. Only server logic reads stock/prices to fulfill the preference; billboards receive display strings. See `operations/PHASE30_CUSTOMER_PREFERENCES.md`.
- Chaos event order is derived from the server-known owner ID and completed-shift count. Rejoin reconstructs the same plan without persisting a client-controlled seed; active stages and outage deadlines continue through profile persistence. See `operations/PHASE31_CHAOS_DIRECTOR.md`.
- Profile schema v19 stores a validated layout for the four retail SKU shelves. Server movement updates shelf prompts/tags and the customer browse route together; the client only previews and proposes grid positions. See `operations/PHASE32_RETAIL_LAYOUT.md`.
- Profile schema v20 stores a bounded customer satisfaction score. The server updates it in the successful sale transaction from preferred quantity fulfillment and premium SKU pricing; authorized HUDs only display the value. See `operations/PHASE33_CUSTOMER_SATISFACTION.md`.

## Open technical decisions
See `docs/decisions/README.md` for accepted ownership policy. Remaining decisions include multi-store/guest permissions, production Studio place configuration, analytics implementation/privacy review, and any changes to persistence recovery. Verify platform APIs against official documentation when implementation starts.

## Phase 44 online grocery packing
- `Economy.getNextOnlineOrder` derives a bounded four-order rotation from the saved fulfilled-order count. The server selects item IDs and quantities, reads current server prices, and checks warehouse backstock; clients supply no basket, price or quantity.
- `Economy.fulfillOnlineOrder` is a single between-shifts transaction. It rechecks warehouse ownership, stage and all stock before deducting units and crediting the computed total. Manager and Stocker prompts share the normal proximity, rate, owner and profile-save gates, plus the transaction lock.
- Profile schema v27 persists only the bounded fulfilled-order counter; orders are regenerated from that counter on load. Warehouse board text contains display-only item names, amounts and readiness.

## Phase 45 delivery worker online order automation
- The existing delivery worker now checks both ready inbound shipments and the next online grocery order. Online packing is eligible only after a completed shift and only once per `completedShifts` value.
- The worker uses the existing automation toggle. A saved shift marker prevents rejoin or scheduler retries from packing a second automatic order during the same completed shift.
- The worker delegates to `Economy.fulfillOnlineOrder`, the same state transition as the physical packing prompt. Both paths share the transaction lock through profile save and schedule refresh.
- Profile schema v28 migrates the marker to zero for older profiles; automation remains disabled for non-development DataStore universes as before.

## Phase 46 larger Customer Rush
- Customer Rush remains triggered by the deterministic shift logic after the three regular sales, but now adds three customers (six total), allows 90 seconds, and pays `$30` only on a timely clear.
- `WorldBuilder` provisions six bounded customer models and six main queue positions; the self-checkout split gives three positions to each lane. Recovery reconstructs these positions from persisted sales and deadline state.
- Profile normalization accepts up to six sales and the expanded in-progress rush range. This widens validation only; no profile schema field or migration is needed.
# Cooperative ownership and cashier extension
- One owner profile remains the persistence boundary. Per-server membership grants temporary action permissions but does not load a guest's profile into the owner's economy.
- Server role map: Owner (all), Manager (all shift actions including staff hiring), Cashier (checkout), Stocker (stock), Maintenance (cart recovery).
- Client-to-server membership remotes carry only an action, target UserId and allow-listed role. Server validates owner authority, current membership, capacity and rate limits.
- The Phase 4 cashier stores one boolean in profile schema v2. Its delayed checkout reuses `Economy.sellProduct`, so revenue and stock consume the same authoritative state transition as a player checkout.
- DataStore access is restricted to development universe `10770581249`; configuring a production ID is a future deployment task.
- `TelemetryService` emits the first-shift funnel through Roblox AnalyticsService only in the development universe. Roblox associates each event with the required Player argument. The game sends no custom fields or identifiers, stores the ephemeral funnel session ID only in server memory, and contains AnalyticsService errors so gameplay continues.
- Touch clients lay out the HUD around the viewport and start with the objective card collapsed at top center. The team panel stays a local presentation layer and closes independently of server membership.
