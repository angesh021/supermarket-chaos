# Phase 36 — Buildable bakery department

## Acceptance criteria

- At a completed shift, the Owner/Manager can build a bakery for `$350` after owning both the rear wing and warehouse. The server charges once; invalid prerequisites, duplicate requests and insufficient cash do not change ownership.
- The rear wing gains an oven, pastry counter, visible Cinnamon Twists display, department sign, stock prompt, and shelf price tag. The fixed fixture is server-built and cannot be overlapped by movable retail shelves.
- Cinnamon Twists use a server catalog price of `$18`, allowed price steps of `$14/$18/$23`, three-unit restocking, a 24-unit shelf cap, and a `$50` warehouse delivery for 18 pastries. The shipment uses the existing one-at-a-time delivery flow.
- Bakery ownership, shelf stock, backstock, pending bakery shipment and price persist in schema v23. Earlier profiles migrate with no bakery, no pastries, and the catalog price; other progress remains intact.
- Bakery-owned stores may receive Cinnamon Twists in weighted customer preferences. Server checkout determines stock, quantity, price, cash and satisfaction. Customer paths enter the rear wing through the existing passage.
- Owner/Manager can order and reprice. Owner/Manager/Stocker can restock under existing server prompt checks; visitors see no private economy counters. Employee stock automation can replenish an empty, preferred bakery shelf.

## Server/client boundary and failure handling

- `Economy.buyBakeryDepartment`, stock, delivery, basket and checkout functions own all money and inventory changes. Prompt callbacks pass through the existing role, range, cadence, owner-ready and save-lock gates.
- Profile schema v23 validates bakery prerequisites, SKU counts, shipment IDs, shelf capacity and price allow-lists. `RetailLayoutService` rejects shelf positions that overlap the fixed bakery footprint.
- The client HUD displays only the server-filtered bakery counts. Client layout previews cannot authorize construction or bypass fixture collision checks.
- If the rear wing or warehouse is absent, bakery construction remains unavailable. If a delivery is pending, the shared shipment slot prevents another order. Full shelf/backroom and insufficient-funds cases return without partial mutation.
- Bakery visuals use original anchored Roblox parts and built-in materials; no external assets or scripts are added.

## Manual Roblox Studio verification

1. In dev universe `10770581249`, complete a shift, buy the shelf bay, household aisle, rear wing, and warehouse. Confirm bakery prompt appears only after both prerequisites.
2. Try building without `$350`, with missing prerequisites, as a Visitor/Cashier/Stocker, outside prompt range, and twice. Confirm the server does not charge or duplicate the bakery.
3. Build the bakery. Inspect that the counter, oven, sign, price tag and pastries are visible and walkable. Confirm the bakery fits the rear wing and the wall opening remains clear.
4. On an active shift, restock three pastries. Confirm the visual display and stock counter change. Try with fewer than three backstock units and with a full shelf; confirm rejection.
5. Order Cinnamon Twists at the warehouse for `$50`; wait 15 seconds, receive the crate, and restock from the resulting 18-unit backstock. Try a second order while one is pending.
6. Cycle the bakery price through `$14/$18/$23`. Serve a bakery basket and confirm the displayed basket price, cash, stock and satisfaction use the server-set price.
7. Move a retail shelf into the bakery footprint with the layout editor; confirm rejection. Move/rotate a shelf elsewhere in the rear wing and confirm it still saves.
8. Observe customers with pastry baskets entering through the rear opening, browsing, returning to checkout and completing one sale. Check the Stocker role and hired stock automation.
9. Leave and rejoin; confirm bakery ownership, shelf/backstock, pending shipment and price persist. Verify an older v22 profile opens with the bakery locked and earlier store data preserved.
10. Confirm Visitors receive no bakery counts and cannot build, reprice, order, stock, or edit layout. Repeat the prompt checks on touch controls.

## Local checks and runtime status

- Pinned StyLua, Selene and Rojo checks are recorded in `docs/PROJECT_STATUS.md` after implementation.
- Roblox Studio construction, customer routes, delivery timing, persistence, multiplayer checks and mobile controls require manual testing; no runtime success is claimed.
