# Phase 48 — Market Table restaurant

## Acceptance criteria
- A fixed Market Table restaurant appears on a connected plaza lot after purchase, with a readable menu, dining tables, service counter, warmer, chef and meal visuals.
- Owner/Manager can build it for `$1,200` only after café ownership and during a completed shift. Failed prerequisite/funds checks leave balance and world unchanged.
- Owner/Manager/Stocker can prep four Garden Bowls for `$80` up to 16 meals. Owner/Manager/Cashier can serve one bowl for `$38`.
- Serving consumes exactly one meal, credits exactly `$38`, increments restaurant sales exactly once, and leaves supermarket shift sales/customer progress unchanged.
- Profile schema v30 persists restaurant ownership, meals and sales. Older profiles migrate to restaurant unowned/empty.
- Invalid restaurant ownership without a café, meal stock above 16, or restaurant inventory/sales without ownership is rejected by profile normalization.

## Server/client boundaries
- `Economy` owns restaurant build cost, prep cost/quantity/capacity, meal price and all state transitions.
- `ShiftService` gates prompts by Owner/Manager, Stocker or Cashier role, server proximity, cadence, owner readiness and profile save state. All restaurant transactions share the existing transaction lock.
- `WorldBuilder` creates a fixed restaurant from original built-in Roblox parts. Menu values and meal visuals follow server-saved state.
- `ProfileService` persists restaurant ownership in `ownedUpgrades` and bounded stock/sales counters in shift profile state. Clients cannot send prices, quantities, stock or ownership.

## Failure handling and limits
- Restaurant purchase requires the café and a completed shift. Meal prep requires the completed-shift stage. Serving is available while the profile is ready and stock remains.
- Insufficient funds, full warmer, empty stock, invalid ownership or denied roles fail before state changes.
- This increment has one fixed Garden Bowl menu item and no restaurant-specific employee, customer queue, recipe customization, delivery or separate balance.

## Manual Roblox Studio verification checklist
1. With a warehouse but no café, confirm Market Table cannot be purchased. Build the café, then finish a shift.
2. Try building with less than `$1,200`; verify no cash or scene changes. With sufficient cash, build and inspect the storefront, awning, walkway, menu, dining tables/chairs, chef, counter, warmer and meal display.
3. Confirm menu price `$38`, stock zero, and serving is unavailable.
4. Prep a batch as Owner. Confirm exactly `$80` is deducted and stock rises by four.
5. Serve a Garden Bowl as Owner. Confirm stock decreases by one, cash increases by `$38`, restaurant sales increments once, and supermarket shift sales/objective are unchanged.
6. As Cashier, confirm serving works while build/prep are denied. As Stocker, confirm prep works while build/serve are denied. Confirm Manager can do all three and Visitor/Maintenance cannot.
7. Fill stock to 16 and confirm another prep is unavailable with no deduction. Serve down to 12, prep again and verify stock returns to 16.
8. Save and rejoin; confirm restaurant, stock, sales, cash, café, warehouse, inventory and layout persist.
9. Load a v29 profile and confirm restaurant defaults to unowned/empty without losing earlier progress.
10. Race two authorized meal-service prompts and a grocery sale. Confirm no duplicate payouts, negative stock or lost balance updates.
11. Confirm meal serving is blocked while the profile is loading/offline and resumes after the owner profile is ready.
12. Check the path between restaurant, café and supermarket remains walkable at desktop and mobile camera sizes.

## Verification status
- Pinned StyLua 2.5.0 `--check src`, Selene 0.32.0 (`0 errors, 0 warnings, 0 parse errors`), Rojo 7.7.0 build to `%TEMP%\supermarket-chaos-phase48.rbxlx`, and `git diff --check`: passed on 2026-10-13. Git emitted only Windows line-ending normalization warnings.
- Roblox Studio construction, transactions, permissions, migration and save/rejoin: pending; no runtime success is claimed.
