# Phase 47 — Corner Café plaza business

## Acceptance criteria
- A distinct fixed café storefront and connected walkway appear on the plaza lot after purchase.
- The Owner/Manager can build the café for `$650` only with a warehouse and a completed shift. Insufficient funds or unmet prerequisites leave cash and world unchanged.
- The café begins with zero coffees. Owner/Manager/Stocker can spend `$45` to restock six, up to a maximum of 24.
- Owner/Manager/Cashier can serve one coffee from stock for `$18`. The action consumes exactly one, credits exactly `$18`, increments café sales once, and leaves supermarket shift-customer progress unchanged.
- Café purchase, stock and sales persist through profile schema v29; older profiles migrate to no café and no coffee.
- Invalid café ownership without a warehouse, stock above 24 or café stock/sales without ownership is rejected during profile normalization.

## Server/client boundaries
- `Economy` owns purchase price, restock cost/quantity/capacity, serving price and all state transitions.
- `ShiftService` checks prompt role, proximity, cadence, owner readiness and save lease. Café purchase/restocking/serving share the transaction lock with grocery sales and online orders.
- `WorldBuilder` renders a fixed procedural café, coffee machine, barista, board and stock cups. All menu values and visible stock come from server state.
- `ProfileService` stores café ownership in the owned-upgrade set and stock/sales in the bounded shift profile. Clients cannot submit prices, quantities or ownership values.

## Failure handling and limits
- The café cannot be purchased before the warehouse or outside a completed shift. Restocking is only available between shifts; serving is available whenever the profile is ready and inventory remains.
- If stock is full, cash is insufficient, or inventory is empty, the server rejects the action before mutation.
- This first plaza business is a fixed café with one coffee product. It does not yet have an independent café customer queue, NPC traffic integration, restaurant menu, customization or separate profile ownership.

## Manual Roblox Studio verification checklist
1. On a completed-shift profile without a warehouse, confirm the Corner Café pad is unavailable.
2. Buy the warehouse, finish a shift and approach the café lot. With less than `$650`, try the prompt and confirm no deduction/build. With enough cash, purchase and verify the façade, roof, awning, walkway, counter, machine, barista and readable menu appear.
3. Confirm the menu says coffee is `$18`, stock is zero, and serving is unavailable.
4. Brew a batch as Owner. Confirm exactly `$45` is deducted, stock rises by six, six cup visuals appear, and the board updates.
5. Serve one coffee as Owner. Confirm stock drops by one, cash rises by `$18`, café sales increments once, and the main shift customer/sales objective does not change.
6. As a Cashier, confirm serving works but buying/restocking is denied. As a Stocker, confirm restocking works but serving/building is denied. As Maintenance or Visitor, confirm all café transactions are denied.
7. Fill stock to 24. Confirm another batch is unavailable and cannot deduct cash. Serve down to 18 and verify one more batch is allowed.
8. Save and rejoin. Confirm café construction, coffee count, café sales, balance and other store progression persist.
9. Load an existing v28 profile. Confirm it migrates with café unowned and empty while preserving warehouse, inventory, layout, employee state and balance.
10. Race café service against a grocery sale and race two authorized users at the counter. Confirm each accepted interaction deducts and credits once, with no negative stock or duplicate payout.
11. Confirm serving is unavailable during profile loading/offline and after coffee runs out; verify the prompt returns after restocking.
12. Check approach paths, café counter access and readability on desktop and mobile camera sizes.

## Verification status
- StyLua 2.5.0 `--check src`: passed. Selene 0.32.0: 0 errors, 0 warnings, 0 parse errors. Rojo 7.7.0 build to `%TEMP%\\supermarket-chaos-phase47.rbxlx`: passed. `git diff --check`: passed with line-ending normalization warnings.
- Roblox Studio construction, transactions, permissions, migration and save/rejoin: pending; no runtime success is claimed.
