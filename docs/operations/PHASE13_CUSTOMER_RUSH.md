# Phase 13 Customer Rush verification

The first three customers remain the normal shift goal. If at least two shelf units remain after the third sale, a 60-second Customer Rush starts with two additional shoppers. Serving both before expiry pays a fixed `$20` bonus; otherwise the rush ends without the bonus and the player can close the normal shift. If stock is insufficient, the normal shift closes without starting a rush. The event and expiration timestamp are saved in profile schema v9. Studio/runtime behavior has not been verified locally.

## Acceptance criteria

- After the existing spill and power outage are resolved, the third successful sale triggers exactly two bonus shoppers and a 60-second server deadline only when at least two shelf units remain; otherwise it proceeds to ordinary closeout.
- The first three sales remain required and earn their normal catalog prices. Rush sales use the same catalog, inventory deduction and server checkout transaction.
- Serving both additional shoppers before the deadline clears the event, pays exactly `$20` once, and enables shift closeout.
- If the deadline expires first, the rush queue leaves, no rush bonus is paid, and the shift board allows normal closeout. No earned cash, stock, sales or completed shift is removed.
- Rejoining during the rush restores its remaining shoppers and deadline. An already-expired rush ends promptly on server load.
- At most five customers can be active. Queue movement fallback, cashier automation and normal checkout authorization work for all five.
- Profile schema v9 accepts `CustomerRush` only with a bounded deadline and caps saved shift sales at five; earlier profiles migrate to no active rush.

## Server/client boundaries and recovery

The server triggers the rush after the third sale, chooses the next SKU, prices all sales, sets the deadline and grants the `$20` clear bonus. No client-provided sale count, SKU, price, duration, reward or success flag is accepted. The rush timer rechecks the current owner, stage, timestamp and save status before expiring; it retries while a save is pending and does not mutate gameplay after lock loss. Expiry clears only the bonus queue and transitions to `CloseShift`. Customer models and route animations are presentation; they cannot grant sales. ProfileService stores the rush deadline with the shift state.

## Manual Studio checklist

1. In the private development universe `10770581249`, run `rojo serve default.project.json`, connect Studio at `localhost:34872`, and keep Output visible.
2. Start with a profile that owns the warehouse, recover the cart, stock at least four Berry Bites and three Citrus Pop, serve the first shopper, clean the spill, serve the second shopper, and restore power at the breaker.
3. Serve the third shopper. Confirm the sale credits the correct product price and two additional customers enter the store; confirm the objective shows two shoppers and the 60-second rush.
4. Serve both extra shoppers before time expires. Confirm each sale consumes one correct shelf unit, the `$20` rush bonus is paid exactly once, and the shift board permits closeout.
5. Repeat the rush and let 60 seconds expire. Confirm both bonus customers leave, the `$20` bonus is not paid, and normal shift closeout remains available.
6. With a cashier employee, confirm it can complete rush sales through the same checkout path. Confirm no sale occurs after the deadline and it does not bypass the spill or outage before the rush.
7. Rejoin while the rush is active; confirm the remaining customer count and deadline restore. Rejoin after expiry; confirm the queue is gone and closeout is available.
8. Race the last rush checkout against timeout with two clients or rapid prompts. Confirm either the sale transaction and one bonus win or timeout recovery occurs, never both.
9. Verify queue recovery after a stalled route and confirm Output has no errors. Record starting/final cash, stock, sales, stage, rush time, role, save status and observed customers.

## Known limits

The event is predictable and tied to the third sale; it is not yet randomly scheduled. The queue adds two scripted customers at fixed positions. There are no preference weights, basket sizes, variable checkout delays, customer patience penalties or event-specific reactions yet.
