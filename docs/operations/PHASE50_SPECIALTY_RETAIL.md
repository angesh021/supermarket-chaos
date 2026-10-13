# Phase 50 — Little Sprout Garden specialty retail

## Acceptance criteria
- After Pixel & Plug ownership, Owner/Manager can build Little Sprout Garden for `$1,800` during a completed shift.
- The plaza shop has a readable sign, potted-herb display, counter, gardener and connected path, all built from original Roblox parts.
- Owner/Manager or Stocker can restock three herbs for `$120`, up to 12. Owner/Manager or Cashier can sell one for `$75`.
- A sale consumes one herb and adds `$75` exactly once without changing supermarket shift sales/customer progress.
- Profile schema v32 persists ownership, stock and sales. Older profiles migrate with the garden store unowned and empty.
- Normalization rejects garden ownership without electronics-store ownership, stock above 12 and stock/sales without garden-store ownership.

## Server/client boundaries
- `Economy` owns all fixed prices, quantities, capacities and state transitions.
- `ShiftService` applies role, prompt range/rate and shared transaction-lock checks. No client-provided cost, amount, stock or ownership is accepted.
- `WorldBuilder` creates the fixed shop and projects saved stock/sales to the display.
- `ProfileService` persists ownership and bounded counters in the owner's existing profile; all transactions use shared owner cash.

## Failure handling and limits
- Build and restock require a completed shift. Selling requires a ready owner profile and positive stock.
- Insufficient cash, full/empty stock, missing prerequisite or denied role do not change the balance or inventory.
- This increment has one potted-herb product and no simulated plant care, garden customers, employee, deliveries or separate balance.

## Manual Roblox Studio verification checklist
1. With Pixel & Plug unowned, confirm the garden store cannot be built. Purchase Pixel & Plug and finish a shift.
2. With less than `$1,800`, try building and confirm the balance and world do not change. Then purchase and inspect the storefront, sign, path, display, counter and gardener.
3. Confirm the menu shows potted herbs at `$75`, stock zero and no sale prompt.
4. Restock once as Owner: exactly `$120` deducted and stock increases by three.
5. Sell once: stock decreases by one, cash increases by `$75`, garden sales increments once, and supermarket shift sales/objective remain unchanged.
6. As Cashier, confirm sale works and build/restock are denied. As Stocker, confirm restock works and build/sale are denied. Confirm Manager can do all; Visitor/Maintenance cannot.
7. Fill the stand to 12 and confirm further restock is unavailable without a deduction. Sell down to nine, restock and verify it returns to 12.
8. Save and rejoin; confirm garden ownership, stock, sales, cash and earlier supermarket/plaza progression persist.
9. Load a v31 profile and confirm Little Sprout is unowned/empty without losing earlier progress.
10. Race two garden sales with a supermarket sale; confirm no duplicate payout, negative stock or lost balance update.
11. Confirm garden sales are blocked while the owner profile is loading/offline and resume when the profile is ready.
12. Check the path between Little Sprout, Pixel & Plug, Market Table, Corner Café and supermarket is walkable on desktop and mobile.

## Verification status
- Pinned StyLua 2.5.0 `--check src`, Selene 0.32.0 (`0 errors, 0 warnings, 0 parse errors`), Rojo 7.7.0 build to `%TEMP%\supermarket-chaos-phase50.rbxlx`, and `git diff --check` passed on 2026-10-13.
- Roblox Studio construction, transactions, permissions, migration and save/rejoin: pending; no runtime success is claimed.
