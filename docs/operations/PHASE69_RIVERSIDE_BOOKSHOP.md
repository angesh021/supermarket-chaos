# Phase 69 — Riverside Bookshop

## Goal and acceptance criteria

Turn the existing plaza bookshop shell into an operating neighborhood business and add a second book retailer to the player-owned store chain.

- Riverside Bookshop unlocks after Maple Corner Florist and costs `$2,500` to open between shifts.
- A `$300` restock adds three visible paperbacks, up to 12; each server-priced sale credits `$130` and removes one book.
- Owner/Manager can build; Manager/Stocker can restock; Manager/Cashier can sell. Plaza visitors can buy one item only through the existing server transaction lock and 15-second per-business throttle.
- Ownership, stock and sales persist in the neighborhood location under profile schema v40. v39 neighborhood/Uptown snapshots migrate with safe unowned/empty bookshop defaults, including retail-layout version migration.
- The visual uses original Roblox parts only. No Toolbox scripts or external assets are introduced.

## Server/client boundary and failure handling

`Economy` owns fixed prices, the prerequisite, stage gates, stock cap, inventory decrement and payout. Prompt callbacks use the existing server role, distance and request-rate checks and serialize with other plaza sales. Visitor events accept only the fixed `bookshop` ID, require the owner profile to be ready, and use that same sale function. Client HUD data is sanitized to current store participants; no client supplies stock, price, quantity or proceeds.

`ProfileService` schema v40 stores the business in `ownedUpgrades.bookshop` and the active location shift's `bookshopStock` / `bookshopSales`. Validation rejects ownership without the florist prerequisite, stock over 12, nonzero book data without ownership, malformed counters, divergent location snapshots and invalid retail-layout versions. Existing v39 data defaults to unowned with zero stock/sales. The existing profile lease and serialized save protect the shared company balance and location snapshot.

## Manual Roblox Studio checklist — pending

Use the development experience (`10770581249`) and a neighborhood profile with Maple Corner Florist already owned. Record the shared company balance and bookshop state before each test.

1. Join the neighborhood and walk to the Riverside Bookshop storefront beside Maple Corner Florist. Confirm the storefront reads as a bookshop, with three bookcases and no visible inventory before opening.
2. During a running shift, confirm the purchase pad is disabled. Complete/close the shift, then confirm `Open Bookshop ($2,500)` is available only after Maple Corner Florist ownership.
3. Open the bookshop. Confirm exactly `$2,500` is deducted once, the pad disappears, the counter/menu appears, and the business remains owned after leaving and rejoining.
4. Restock once between shifts. Confirm exactly `$300` is deducted, three paperbacks appear on the shelves and the sign shows stock 3. Try again to reach 6, then 9, then 12; confirm a fifth restock is unavailable and stock never exceeds 12.
5. With three books in stock, manually sell one. Confirm stock becomes 2, sales increases by 1 and balance increases exactly `$130`. Try to sell at zero stock and confirm no balance or sales change.
6. With a second player, verify Owner/Manager can build/restock/sell, Stocker can restock only, Cashier can sell only, and Visitor cannot use any bookshop action. Confirm prompt distance checks still apply.
7. Restock, then let a plaza visitor browse Riverside Bookshop. Confirm one book is removed and `$130` is credited at most once during the 15-second business throttle. With empty stock, confirm visitors create no sale.
8. Trigger a bookshop transaction close to another plaza business sale. Confirm the shared transaction lock prevents duplicate/interleaved payouts and both businesses retain their own stock/sales counts.
9. Load an existing v39 profile with no bookshop fields and confirm it migrates to unowned, zero stock/sales without losing florist, store layout, company cash or Uptown state. If possible, test one v39 profile with an Uptown branch and retail-layout v5.
10. Rejoin after purchase, restock and sales. Confirm ownership, remaining visible books and sales count persist, and repeat on a fresh profile to verify the bookshop is initially locked.

## Verification status

Static format, lint, Rojo mapping and whitespace checks are recorded in `docs/PROJECT_STATUS.md` after implementation. Roblox Studio visuals, transactions, multiplayer roles, legacy DataStore migration and save/rejoin behavior have not been run locally.
