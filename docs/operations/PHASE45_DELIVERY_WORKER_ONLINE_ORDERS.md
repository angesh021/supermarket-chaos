# Phase 45 — Delivery worker online order automation

## Acceptance criteria
- A hired delivery worker with automation enabled may pack one ready online order after a shift is completed.
- The worker uses the same product rotation, stock requirements, current price calculation, inventory deduction and cash credit as the manual packing station.
- The existing delivery worker automation toggle pauses both inbound shipment receipt and online order packing.
- A persisted per-shift marker prevents duplicate automatic packing after a rejoin, scheduler retry, or player/employee race.
- A manual pack while the worker is enabled counts as that shift's order, so the worker will not immediately pack the next generated order.
- Profile schema v28 migrates older profiles with marker zero; worker hire state, automation and all existing inventory remain intact.

## Server/client boundaries
- `ShiftService` schedules the worker only after the owner profile is ready and validates the worker, automation, warehouse, completed shift, stock readiness, profile save status and generation token again before fulfillment.
- The employee and packing prompt call `Economy.fulfillOnlineOrder`. They share `saleTransactionInProgress` through the profile save.
- `ProfileService` persists `deliveryWorkerOrderShift` as a bounded integer in the shift record. The client cannot invoke the employee callback or select a product/order.
- The existing delivery worker automation board remains the control surface and now describes shipment handling and online order packing.

## Failure handling and limits
- If stock is insufficient, the worker does not mutate cash or inventory and will be reconsidered after later commits update the order state.
- If a profile save is pending, a transaction is in progress, the shift changes, automation is paused or the callback is stale, the worker waits or cancels without making an order transaction.
- The worker handles at most one online order per completed shift. It does not create extra orders, bonuses, item substitutions or vehicle routes.

## Manual Roblox Studio verification checklist
1. With a warehouse and ready order, hire the delivery worker and leave automation enabled. Complete a shift and wait five seconds. Confirm the order is packed once, the displayed current-price total is credited, and all three units leave backstock.
2. Confirm the board advances to the next order but the worker does not pack that second order during the same completed shift.
3. Pause automation before completing the next shift. Confirm an arrived supplier shipment remains unreceived and a ready online order remains unchanged.
4. Resume automation and confirm an eligible order is packed once, without retroactive duplicate payout.
5. Manually pack an order after a completed shift while the worker is enabled. Confirm the worker does not pack a second order that shift.
6. Race a Manager/Stocker packing prompt against the delivery worker timer. Confirm only one order counter advance, one stock deduction and one payout.
7. Rejoin after the worker packs an order. Confirm the worker does not pack another order for that same completed shift; after a later shift, confirm it can run once again.
8. Verify a v27 profile migrates to v28 and retains worker hire/automation, backstock, balance and the order rotation.
9. Confirm that a worker with insufficient stock waits and that a later shipment receipt can make the next order eligible.
10. Confirm a profile with save-lock loss does not allow worker packing.

## Verification status
- StyLua 2.5.0 `--check src`: passed. Selene 0.32.0: 0 errors, 0 warnings, 0 parse errors. Rojo 7.7.0 build to `%TEMP%\\supermarket-chaos-phase45.rbxlx`: passed. `git diff --check`: passed with line-ending normalization warnings.
- Roblox Studio runtime, employee timer, races, migration and DataStore behavior: pending; no runtime success is claimed.
