# Phase 8 — Checkout queue verification

## Scope

Each shift supports at most three varied, procedural customers. They enter, browse the first aisle, join the queue, wait for checkout, and exit after a sale. A successful sale consumes one stocked item and grants the existing server-defined $25 exactly once. Queue progress derives from the saved shift `sales` value; no customer-controlled price, quantity, or identity is accepted. Shift close becomes available after the third sale. The cashier employee uses the same sale transition and can serve the queue automatically.

Navigation uses a small scripted waypoint route rather than PathfindingService, so work is bounded and deterministic. Customers do not yet choose among products, react to chaos, or carry shopping baskets. If a customer route does not reach checkout within 12 seconds, the server moves the bounded queue to its checkout positions and enables safe progression.

## Acceptance criteria

- A fresh shift shows no customers until stocking succeeds. Up to three customers enter through the front, visibly browse the aisle, queue at the register, and leave after service.
- Checkout stays disabled until the next customer reaches the register. The bounded route recovery makes the customer available if scripted movement stalls.
- Each successful checkout reduces shelf stock and the visible queue by one, increases cash by $25 once, and updates the objective counter.
- Closing a shift is not available until all three customers are served; invalid extra checkout interactions do not add cash.
- A hired cashier serves each eligible customer through the same economy path; a human still resolves the intervening spill event.
- Rejoining during checkout restores the correct remaining count from saved sales and stock.
- Customer models do not block player movement or alter currency independently.

## Server/client boundary and failure handling

- `Economy.sellProduct` owns stage, stock, sale count, and reward changes. `ShiftService` still checks role, prompt distance, profile write state, and request throttling before applying it.
- `WorldBuilder` moves a maximum of three non-colliding customer models along a fixed waypoint route; these models are presentation only. A 12-second route fallback restores queue positions without changing shift or economy state.
- No new client remote or persistent fields are introduced. An old saved shift already at `CloseShift` remains closable under its saved stage.
- Empty shelf, wrong stage, unauthorized helper, or a duplicate request yields no transaction. A server restart during checkout reconstructs queue visuals from the owner profile.
- Runtime, movement, rendering, and save/rejoin behavior require Studio verification; local static checks are not evidence of runtime success.

## Manual Studio verification

1. Start a private server in the development universe and begin a new shift. Confirm no checkout customers are shown during the cart objective.
2. Recover the cart and stock the product. Confirm customers enter one at a time, display **ENTERING** and **BROWSING**, then form a readable line. Confirm checkout does not open before the first customer reaches the register.
3. Serve the first customer. Confirm the customer exits, one sale is recorded for $25, then the spill event interrupts checkout. Follow [Phase 9 chaos checks](PHASE9_CHAOS.md) to clear it before resuming.
4. Serve the remaining two customers. Confirm each customer advances and exits, the line clears, three total sales are recorded, and the shift board becomes available only after the third sale.
5. Re-trigger checkout after the queue is empty and try an unauthorized role. Confirm cash and sales do not change.
6. Hire a cashier, start another shift, and confirm it serves the first customer for $25, pauses at the spill, resumes after authorized cleanup, and serves the remaining customers for $25 each. Confirm all three units are consumed and closeout appears once.
7. Leave and rejoin while two customers remain. Confirm the saved objective, remaining customer flow, cash, sales, and stock agree; serve the last two and confirm closeout.
8. Test one narrow/mobile viewport. Confirm queue models do not obstruct prompts, aisle access, or the checkout approach.

Record Studio version, server type, account roles, observed cash/stock/sales, persistence result, and any Output errors in the quality log. Do not mark the milestone verified until these checks are reported.
