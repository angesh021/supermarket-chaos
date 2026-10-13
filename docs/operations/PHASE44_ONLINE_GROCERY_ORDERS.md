# Phase 44 online grocery orders and delivery preparation

## Acceptance criteria
- A warehouse owner sees a physical packing station with the next server-generated order, required products, current total and stock readiness.
- The station is usable only with a purchased warehouse, while the shift is complete, by Owner, Manager or Stocker, and when every requested unit is present in backroom inventory.
- One successful interaction consumes the complete order from backstock, credits the sum of current server prices, advances the order rotation exactly once and persists the count.
- The next order is deterministic across save/rejoin. Existing profiles migrate to schema v27 with zero fulfilled orders.
- An unavailable order or rejected prompt changes neither inventory nor balance.

## Server/client boundaries
- `Economy` chooses product IDs, quantities, availability and prices; validates the stage and warehouse; and applies the complete transaction.
- `ShiftService` checks role, prompt range, cadence, profile lease and the shared transaction lock.
- `WorldBuilder` displays sanitized order details and readiness on the warehouse board. No client remote or client-supplied order values are used.
- `ProfileService` validates and persists only the fulfilled-order counter. The order itself is reconstructed from that count.

## Failure handling and limitations
- If one requested product is out of backroom stock, the prompt remains unavailable and the board identifies the order as needing stock. The player must replenish through existing delivery/receipt mechanics.
- If the warehouse is not owned or the shift is active, the server rejects packing. Profile save lock loss blocks the prompt through common interaction checks.
- This increment has no online customer avatar, delivery vehicle, timed orders, substitutions or separate delivery fee. The order rotation uses the core four warehouse products.

## Manual Roblox Studio verification checklist
1. Load a warehouse profile with stock and finish a shift. Confirm the packing board is inside the warehouse and shows order #1 with three products, total and READY state.
2. Pack once as Owner. Confirm all three listed quantities leave backstock, cash rises by the displayed total, and the board advances to order #2.
3. Attempt a pack while a required product has zero stock. Confirm the prompt is unavailable and no cash or inventory changes.
4. Complete the four-order cycle. Confirm it returns to the first basket and order number increments.
5. As a Manager and Stocker, confirm packing is allowed. As Cashier, Maintenance and Visitor, confirm it is denied.
6. Attempt packing during an active shift; confirm it is unavailable and no state changes.
7. Save and rejoin after packing. Confirm cash, stock and the next order number remain correct.
8. Verify an existing v26 profile loads as v27 with order #1 and no loss of upgrades, stock, prices or layout.
9. Race two authorized players at the station. Confirm the basket is fulfilled and credited once.
10. Confirm mobile proximity prompt interaction works and board text is readable at normal gameplay distance.

## Verification status
- StyLua 2.5.0 `--check src`: passed. Selene 0.32.0: 0 errors, 0 warnings, 0 parse errors. Rojo 7.7.0 build to `%TEMP%\\supermarket-chaos-phase44.rbxlx`: passed. `git diff --check`: passed with line-ending normalization warnings.
- Roblox Studio runtime, multiplayer, migration and DataStore checks: pending; no runtime success is claimed.
