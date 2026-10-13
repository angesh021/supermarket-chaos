# Product requirements — Phase 1 first playable

## Product
**Supermarket Chaos: Retail Empire** is a colorful, cooperative Roblox retail management game. Players personally operate a small neighborhood supermarket, respond to funny disruptions, and visibly improve the store. Tagline: **Start Small. Build Big. Survive the Chaos.**

## Audience and experience
- New Roblox players should understand the next action without a long tutorial.
- Solo play must complete the introductory objectives; cooperative play may assist but cannot bypass ownership or permissions.
- Desktop and touch controls are first-class. Keep UI readable and gameplay unobstructed.
- Long-term progression is earned through enjoyable play. Do not require purchases or coercive daily attendance for core progression.

## Phase 1 scope
Deliver one polished small supermarket and its immediate streetscape; one complete solo-playable shift; stocking, customer interaction, checkout, a manageable chaos event, rewards, one purchasable upgrade, and the “First Shift: Welcome to Chaos” onboarding. Show one visible upgrade in the world. Leave later businesses, logistics, deep employee simulation, and production commerce for later phases.

## Acceptance criteria (design targets; verification pending)
1. A first-time player can identify and complete the runaway-cart objective with concise contextual guidance and an immediate reward.
2. A player can stock a fictional product, serve at least one customer, complete a checkout sale, and receive clear feedback.
3. A complete shift has a start, active play, one chaos event, summary/reward, and a clean end state; solo completion is possible.
4. A first upgrade has server-validated cost and eligibility, visibly changes the store, and gives an understandable confirmation.
5. Invalid, stale, duplicated, unauthorized, or excessive client requests cannot alter authoritative state.
6. Core UI and interactions remain usable at desktop and mobile aspect ratios and with touch input.
7. The small store is visually cohesive and has a readable route from entrance through aisles to checkout and storage.
8. Progression and operations have documented failure handling and a reproducible Studio verification procedure.

## Non-goals for first playable
Multiple business types; regional map; online grocery logistics; employee automation; production monetization; live operations analytics beyond privacy-conscious event definitions; guaranteed revenue outcomes.

## Success measures
Instrument funnel events for first interaction, first stock, first sale, first upgrade, first shift completion and voluntary return. The master specification's completion percentages are hypotheses to validate with actual playtests, not external benchmarks or promises.

## Phase 2 progression requirements
- Each player's currency, current shift, owned store upgrades and progression counters are stored in a versioned profile keyed by Roblox UserId.
- A returning owner resumes the saved shift and sees already-purchased physical upgrades.
- One server session has one store owner. Visitors are read-only until Phase 3 defines explicit guest roles and permissions.
- Profile loading/saving is server-only and uses session ownership; a known lost lock blocks store interactions.
- A DataStore outage may allow session-only play, but the UI must disclose that progress will not persist and the fallback must never overwrite the saved profile.
- Profiles can start another shift after completing the current shift; rewards and upgrades remain server-authoritative.
- G2 is not complete until the save/rejoin, lease conflict, session-only fallback, and shutdown paths are verified in a private Studio test experience.

## Phase 3 cooperative store requirements
- A visitor can request access; only the store owner can approve, decline, or remove a helper.
- A store has at most four active players including its owner. Membership and role grants are server-session scoped.
- The server assigns one of Manager, Cashier, Stocker, or Maintenance and checks role permission, current shift stage, ownership, prompt range and rate limit for every action.
- Helpers act on the owner's shared shift and currency; they do not load or write the owner's profile as their own.
- G3 requires multi-client Studio verification of each role, removal, capacity and rejected remote/event misuse.

## Phase 4 employee requirements
- On a completed shift, the owner or authorized manager may purchase a persistent cashier for $100 or stock clerk for $80 in fictional currency.
- The server checks the stage, balance and ownership before taking payment and saving the employee flag.
- A hired cashier is visibly represented in the store and automatically completes a stocked checkout after a short delay using the ordinary sale path exactly once. A hired stock clerk visibly appears and automatically stocks the starting product after the cart stage.
- Profile schema v2 safely defaults legacy profiles to no employees. Saved schema version values must be finite bounded integers; read-only visitors receive no balance, stock or sales values.
- Owners and Managers can pause/resume each hired employee's automation at its staff board. The server persists these settings independently; schemas v1–v11 migrate to enabled to preserve existing behavior. Pausing does not prevent player-operated actions.
- G4 requires Studio verification of both purchases, persistence, automatic actions and races with players/helpers at the same prompts.
- Employee automation control acceptance and migration cases are listed in `operations/PHASE18_EMPLOYEE_AUTOMATION.md`.
- With warehouse ownership and a completed shift, Owner/Manager may hire a delivery worker for `$140`. Its optional automation receives one arrived shipment through the ordinary server receipt path; pausing it preserves manual receipt. Profile schema v13 persists the hire/automation flags and safely defaults legacy profiles. See `operations/PHASE20_DELIVERY_WORKER.md`.

## Phase 5 analytics requirements (development increment)
- Track the first-shift funnel through Store Ready, Cart Recovered, Product Stocked, First Sale, First Shift Closed and First Shelf Upgrade.
- Emit funnel steps only in the configured development universe using Roblox AnalyticsService. The API associates events with the required Player argument; do not add custom fields or game-owned player identifiers.
- Analytics failures must not affect gameplay or persistence. Verify event availability in the development Creator Dashboard before using results for decisions.

## Phase 6 touch UI requirements (first increment)
- On touch devices, the objective HUD starts compact and clear of the movement thumbstick; the player can expand it when needed.
- The team panel resizes to the viewport, has an in-panel close control, and lays out role actions into tap-sized rows on narrow screens.
- G6 requires Studio device emulation on phone and tablet sizes, including Roblox core touch controls and safe areas.

## Phase 7 retail expansion requirements (first increment)
- At the completed-shift state, the owner or authorized Manager may buy one warehouse annex for $200 of server-owned fictional currency.
- The server validates stage, ownership/role, proximity, request rate and balance; it deducts once and saves the owned-upgrade flag with the player's profile.
- The purchased annex appears on the reserved exterior plot, and a returning owner sees it without being charged again.
- Legacy profiles default to no warehouse. Other universes remain session-only unless separately configured; production remains disabled.
- G7 requires Studio verification of insufficient funds, unauthorized roles, exact charge, duplicate interaction, visible buildout, save/rejoin and non-development session-only behavior.

### Phase 7 delivery increment
- A warehouse owner starts with 12 Citrus Pop cans in persistent backstock; older profiles migrate safely to that starting inventory.
- The owner or Manager can order 24 cans for $60 when there is room and no other shipment is pending. The order is available during any shift stage so a depleted shelf cannot trap shift progression.
- A shipment becomes collectable at the warehouse dock after 15 seconds. Pending quantity and ready timestamp persist; rejoining does not charge again or duplicate the shipment.
- Receiving a shipment adds its contents once to backstock. Stocking consumes three cans from backstock. Backstock is capped at 500; all quantities, costs and roles are checked on the server.
- G7 delivery verification covers insufficient funds, already-pending orders, duplicate/racing receive requests, capacity, prompt distance, Manager/owner authorization, save/rejoin during transit, and non-development session-only behavior.

### Phase 7 multi-product increment
- Keep each catalog product's shelf stock and warehouse backstock independent.
- Use the server catalog for prices and checkout selection; the client must not submit SKU, price, quantity, or reward.
- Persist the product identifier for the single pending shipment and migrate older untagged shipments to Citrus Pop.
- Display separate inventory counts and distinguish visible stocked products on their department shelves.
- Keep Berry Bites stocking and both supplier orders behind warehouse ownership and current server role permissions.
- Manual acceptance and failure cases are listed in `operations/PHASE11_PRODUCTS.md`.

### Phase 7 produce product increment
- Add Golden Apples to the produce department with independent shelf/backroom counters, server-defined sale/order prices, bounded restock and a product-tagged shipment.
- Existing warehouse owners safely receive a bounded six-apple migration grant; non-warehouse profiles receive none. Keep the single-pending-shipment, owner/Manager purchasing and Owner/Manager/Stocker restock boundaries.
- Display produce stock and include the product in deterministic server-side customer baskets with safe stock fallback. Manual cases are in `operations/PHASE17_GOLDEN_APPLES.md`.
- The existing Coastal Market storefront palette has a separate Owner/Manager preview action. Preview does not charge or persist; cancel and shift restart restore the saved/default palette. Purchase remains server-priced and persists through the existing v10 upgrade flag. See `operations/PHASE19_STOREFRONT_PREVIEW.md`.
- Add Sunrise Cereal as a fourth server-catalog product in the pantry department with separate shelf/backstock counts, bounded restocking, fixed wholesale/retail values, a tagged single shipment, customer baskets and HUD display. Schema v14 migrates existing warehouse owners with six cereal boxes when the field is absent; see `operations/PHASE21_SUNRISE_CEREAL.md`.
- Owners and authorized Managers may cycle each product between bounded server-defined 80%, 100%, and 125% catalog price options from its shelf. Shelf tags, basket totals and atomic checkout must use the same active price; profiles persist only supported values and legacy profiles use catalog prices. See `operations/PHASE22_PRODUCT_PRICING.md`.
- Deterministic customer baskets respond to price: a discounted single-product request may add one unit if stock permits, while a premium multi-unit request reduces by one. Mixed baskets and catalog-price requests preserve their quantities; checkout recomputes the complete result on the server. See `operations/PHASE23_PRICE_SENSITIVE_BASKETS.md`.
- Stocker automation handles initial Citrus Pop setup and may replenish one empty server-preferred SKU during Checkout or Customer Rush when a complete backroom batch is available. All six products use their bounded server-side restock transition; see `operations/PHASE24_STOCKER_REPLENISHMENT.md` and `operations/PHASE40_FREEZER_DEPARTMENT.md`.
- Owner/Manager may hire a persistent Customer Assistant for `$160` after a completed shift. The assistant shortens customer browse travel only; server-owned basket selection, checkout, rewards and currency remain unchanged. Schema v16 migrates older profiles to not hired. See `operations/PHASE25_CUSTOMER_ASSISTANT.md`.
- A development-only repeat-shift funnel measures first shift completion, another shift start and repeat completion using server-confirmed milestones. Keep funnel IDs ephemeral, avoid game-owned player identifiers/custom economic data, and isolate AnalyticsService failures. See `operations/PHASE26_REPEAT_SHIFT_ANALYTICS.md`.
- After the first shelf bay is owned, an Owner/Manager can buy one `$220` household department fixture in a fixed, server-approved slot. Persist its allow-listed ownership flag, reject it without the prerequisite, and rebuild it after profile load. Do not accept client-supplied placement coordinates or rotation in this increment; see `operations/PHASE27_HOUSEHOLD_AISLE_EXPANSION.md`.
- Each currently hired employee has a fixed, server-defined wage per completed shift. Closeout applies the shift bonus and total wages once, reports gross/net amounts, and exposes only the computed per-shift estimate to authorized store viewers; see `operations/PHASE28_SHIFT_PAYROLL.md`.
- Warehouse owners and Managers can place, move, rotate and remove storage shelves in a bounded grid. The server validates ownership, role, distance, rate, coordinates, orientation, collisions, limits and costs; profile schema v18 persists compact layout records. See `operations/PHASE29_WAREHOUSE_LAYOUT_EDITOR.md`.
- Customers use reproducible weighted shopping preferences derived from saved completed shifts and the next sale number. The server fulfills preferences against available catalog stock and prices; billboards show the preference and basket. See `operations/PHASE30_CUSTOMER_PREFERENCES.md`.
- Owners and Managers can move and rotate the four SKU department shelves on a bounded retail grid. Profile schema v19 validates and persists positions; stock/price prompts and customer browse destinations remain attached to their product department. See `operations/PHASE32_RETAIL_LAYOUT.md`.
- The server records a persistent 0–100 customer satisfaction score from basket fulfillment and premium pricing. Owner/Manager/store participants see the score; it does not change checkout accounting. Profile schema v20 migrates older profiles to 75. See `operations/PHASE33_CUSTOMER_SATISFACTION.md`.
- After rear wing, warehouse and bakery ownership, Owner/Manager may purchase a fixed freezer department for `$400`. It adds the Freezer Meals SKU with independent shelf/backroom counts, a single tagged supplier shipment, bounded restock, server-defined price tiers, deterministic customer add-ons, substitution and customer routing. Profile schema v25 migrates earlier profiles with the freezer unowned; the fixed case footprint is reserved by server retail-layout validation. See `operations/PHASE40_FREEZER_DEPARTMENT.md`.
- After rear-wing and warehouse ownership, Owner/Manager may install a persistent `$300` self-checkout terminal. Shoppers alternate deterministically between the self-service terminal and staffed register; only the active lane prompt is enabled. Both call the same server-priced atomic sale path. Profile schema v26 safely migrates older profiles to no self-checkout. See `operations/PHASE43_SELF_CHECKOUT.md`.
- Warehouse owners may prepare one server-generated online grocery order between shifts. The fixed rotation requires three core products from backroom inventory, uses current catalog prices, and advances through profile schema v27 only after the complete server-side stock deduction and payout. Owner/Manager/Stocker roles may pack it. See `operations/PHASE44_ONLINE_GROCERY_ORDERS.md`.
- The hired delivery worker may automatically pack at most one online order per completed shift when automation is on. The existing pause control disables both inbound shipment pickup and online order packing; profile schema v28 safely persists the shift marker. Manual and employee packing share the same transaction and race lock. See `operations/PHASE45_DELIVERY_WORKER_ONLINE_ORDERS.md`.
- A stocked Customer Rush may add three shoppers after the regular shift queue, for a six-customer maximum. The server persists a 90-second deadline, pays `$30` only when all rush customers are served before expiry, and otherwise closes the rush without its bonus. Both physical checkout lanes must route the bounded queue. See `operations/PHASE46_LARGER_CUSTOMER_EVENTS.md`.
- With a warehouse, Owner/Manager may buy the persistent `$650` Corner Café during a completed shift. Restocking costs `$45` for six coffees up to 24; serving a coffee earns `$18`. Cashiers may serve and Stockers may restock; all balance and stock changes remain server-owned. Profile schema v29 migrates old profiles with the café unowned and empty. See `operations/PHASE47_CORNER_CAFE.md`.
- After opening the café, Owner/Manager may build the persistent `$1,200` Market Table restaurant during a completed shift. Restocking costs `$80` for four Garden Bowls up to 16; serving one earns `$38`. Cashiers may serve and Stockers may prep; restaurant sales do not alter supermarket customer counts. Profile schema v30 migrates prior profiles with the restaurant unowned and empty. See `operations/PHASE48_MARKET_TABLE_RESTAURANT.md`.
- After opening the restaurant, Owner/Manager may build persistent Pixel & Plug for `$2,400` during a completed shift. Restocking costs `$300` for two headphones up to eight; selling one earns `$220`. Cashiers may sell and Stockers may restock. Electronics activity uses the owner's shared cash balance but does not advance supermarket shift customers. Profile schema v31 migrates old profiles with this store unowned and empty. See `operations/PHASE49_ELECTRONICS_STORE.md`.
- After Pixel & Plug, Owner/Manager may build Little Sprout Garden for `$1,800` during a completed shift. Restocking costs `$120` for three potted herbs up to 12; selling one earns `$75`. Cashiers may sell and Stockers may restock. Activity shares owner cash without advancing supermarket shift customers. Profile schema v32 migrates old profiles with this store unowned and empty. See `operations/PHASE50_SPECIALTY_RETAIL.md`.

### Phase 4 Power Outage increment
- The server-derived shift plan may trigger a bounded checkout outage after sale 1 or 2, with a visible breaker objective and a 30-second server recovery deadline. See `operations/PHASE31_CHAOS_DIRECTOR.md`.
- Persist the outage stage/deadline so rejoining cannot skip the event or leave the shift stuck.
- Permit Owner, Manager and Maintenance to restore power early; Cashier automation pauses until the outage resolves.
- Manual breaker use and timer fallback must restore service without an extra reward, sale, or inventory change. See `operations/PHASE12_POWER_OUTAGE.md`.

### Phase 4 Customer Rush increment
- After the three baseline customers, offer two additional shoppers for a 60-second bounded rush.
- Require two remaining shelf units after the third sale; when stock is insufficient, proceed to ordinary closeout without trapping the player in an unserviceable bonus queue.
- Serve both through the ordinary server-priced product transaction to earn one `$20` bonus; if time expires, allow normal shift closeout without the bonus.
- Persist the active deadline, reconstruct queue state after rejoin, cap active NPCs at five, and keep the client countdown display-only.
- See `operations/PHASE13_CUSTOMER_RUSH.md` for reward, timeout, race, cashier and recovery checks.

### Phase 4 Customer basket increment
- Derive each next customer's small basket from server-owned shift progress and resolve it against current shelf stock.
- Price each item from the server catalog and atomically apply all basket deductions and credits as one customer sale; customer-count events remain based on customers served.
- Show basket contents to the player and route mixed baskets past both departments. Presentation cannot change basket composition or transaction outcome.
- Reconstruct the next customer intent from saved sale count and current inventory without adding redundant profile data. See `operations/PHASE14_CUSTOMER_BASKETS.md`.

### Phase 2 customization increment
- After completing a shift, the owner or authorized Manager may purchase a fixed `$180` storefront style using server-owned fictional currency.
- The server validates stage, role, proximity, rate, balance and prior ownership. It persists the owned-style flag and applies a visible palette to the fascia, store sign, canopy and interior header.
- Legacy profile schemas default to the original palette. The style persists across shifts and rejoins without affecting economy or inventory. See `operations/PHASE15_STOREFRONT_STYLE.md`.

### Phase 4 customer reaction increment
- Active customers display a short reaction for checkout spill, power outage and rush stages, returning to queue labels after recovery.
- Reactions follow server-provided stage state and never affect checkout, rewards, inventory or persistence. See `operations/PHASE16_CUSTOMER_EVENT_REACTIONS.md`.
