# Phase 8 — Checkout queue verification

## Scope

Each shift stages at most three customers in a visible, varied checkout queue. A successful sale consumes one stocked item and grants the existing server-defined $25 exactly once. The queue count derives from the saved shift `sales` value; no customer-controlled price, quantity, or identity is accepted. Shift close becomes available after the third sale. The cashier employee uses the same sale transition and can serve the queue automatically.

This is a queue and checkout loop, not full customer AI. Customers do not yet browse shelves, choose products, navigate, react to chaos, or walk out. The current visual queue is procedural and collision-free.

## Acceptance criteria

- A fresh shift shows no customers until stocking succeeds, then shows three visibly distinct customers at checkout.
- Each successful checkout reduces shelf stock and the visible queue by one, increases cash by $25 once, and updates the objective counter.
- Closing a shift is not available until all three customers are served; invalid extra checkout interactions do not add cash.
- A hired cashier can complete all three sales through the same economy path.
- Rejoining during checkout restores the correct remaining count from saved sales and stock.
- Customer models do not block player movement or alter currency independently.

## Server/client boundary and failure handling

- `Economy.sellProduct` owns stage, stock, sale count, and reward changes. `ShiftService` still checks role, prompt distance, profile write state, and request throttling before applying it.
- `WorldBuilder` displays a maximum of three customer models; the models are presentation only.
- No new client remote or persistent fields are introduced. An old saved shift already at `CloseShift` remains closable under its saved stage.
- Empty shelf, wrong stage, unauthorized helper, or a duplicate request yields no transaction. A server restart during checkout reconstructs queue visuals from the owner profile.
- Runtime, movement, rendering, and save/rejoin behavior require Studio verification; local static checks are not evidence of runtime success.

## Manual Studio verification

1. Start a private server in the development universe and begin a new shift. Confirm no checkout customers are shown during the cart objective.
2. Recover the cart and stock the product. Confirm three customers appear in a readable line and the objective reports three remaining.
3. Serve the first customer. Confirm one sale is recorded for $25, then the spill event interrupts checkout. Follow [Phase 9 chaos checks](PHASE9_CHAOS.md) to clear it before resuming.
4. Serve the remaining two customers. Confirm the line clears, three total sales are recorded, and the shift board becomes available only after the third sale.
5. Re-trigger checkout after the queue is empty and try an unauthorized role. Confirm cash and sales do not change.
6. Hire a cashier, start another shift, and confirm the cashier completes three sales with $25 per transaction, consumes all three units, and closes the queue once.
7. Leave and rejoin while two customers remain. Confirm the saved objective, remaining line, cash, sales, and stock agree; serve the last two and confirm closeout.
8. Test one narrow/mobile viewport. Confirm queue models do not obstruct prompts, aisle access, or the checkout approach.

Record Studio version, server type, account roles, observed cash/stock/sales, persistence result, and any Output errors in the quality log. Do not mark the milestone verified until these checks are reported.
