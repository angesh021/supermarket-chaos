# Phase 49 — Pixel & Plug electronics store

## Acceptance criteria
- After the Market Table restaurant is owned, Owner/Manager can open a fixed Pixel & Plug storefront for `$2,400` between shifts.
- The plaza shop has a readable sign, product display, counter, clerk and connected path. It uses built-in Roblox parts only.
- Owner/Manager or Stocker can restock exactly two wireless headphones for `$300`, up to eight. Owner/Manager or Cashier can sell one for `$220`.
- Every sale consumes exactly one item and pays exactly `$220`, without changing supermarket shift customers or sale objective progress.
- Profile schema v31 persists store ownership, stock and sales. Older profiles migrate with electronics unowned and empty.
- Normalization rejects electronics ownership without restaurant ownership, stock over eight, and stock/sales without electronics ownership.

## Server/client boundaries
- `Economy` owns build/restock costs, quantities, capacity, price and all state transitions.
- `ShiftService` applies Owner/Manager, Stocker and Cashier permissions, prompt range/rate checks and the shared transaction lock. Clients send no price, count, stock or ownership values.
- `WorldBuilder` constructs the fixed plaza building and reflects saved stock and sales.
- `ProfileService` persists ownership and bounded stock/sales counters; the store remains attached to the owner's profile and shared cash balance.

## Failure handling and limits
- Build and restock require a completed shift. Selling requires a ready owner profile and positive stock.
- Insufficient cash, full display, empty display, missing prerequisite or denied role fail without charging or crediting cash.
- This increment has one fixed headphone item and no individual electronics customers, employee, repair gameplay, delivery or separate currency.

## Manual Roblox Studio verification checklist
1. With the restaurant unowned, confirm Pixel & Plug cannot be built. Build the restaurant and finish a shift.
2. With less than `$2,400`, try building and confirm the balance and scene do not change. Then buy it and inspect storefront, sign, display, counter, clerk and connected walkway.
3. Confirm the sign shows headphones at `$220`, stock zero and no sale prompt.
4. As Owner, restock once: exactly `$300` deducted and stock rises by two.
5. Sell once: exactly one headphone consumed, `$220` added and electronics sales increases once; grocery shift sales/objective remain unchanged.
6. Confirm Cashier can sell but cannot build/restock. Confirm Stocker can restock but cannot build/sell. Confirm Manager can perform all actions; Visitor and Maintenance cannot.
7. Fill the display to eight and confirm another restock is disabled without charge. Sell down to six, restock and confirm stock returns to eight.
8. Save and rejoin; confirm ownership, stock, sales, balance, restaurant, café, warehouse and supermarket progress persist.
9. Load a v30 profile and confirm Pixel & Plug is unowned/empty with earlier progress intact.
10. Race two authorized sales with a grocery sale; confirm no duplicate payouts, negative stock or lost balance updates.
11. Confirm sale is unavailable during profile loading/offline states and resumes when the owner profile is ready.
12. Walk from the electronics lot to the restaurant, café and supermarket; check collisions and camera readability on desktop and mobile.

## Verification status
- Pinned StyLua 2.5.0 `--check src`, Selene 0.32.0 (`0 errors, 0 warnings, 0 parse errors`), and Rojo 7.7.0 build to `%TEMP%\supermarket-chaos-phase49.rbxlx` passed on 2026-10-13.
- Roblox Studio construction, transactions, permissions, migration and save/rejoin: pending; no runtime success is claimed.
