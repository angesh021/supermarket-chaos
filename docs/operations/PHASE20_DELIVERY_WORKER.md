# Phase 20 warehouse delivery worker

After purchasing the warehouse and completing a shift, the owner can hire a delivery worker for `$140`. The worker appears at the loading dock and receives an arrived shipment after a short delay. The existing server-owned receipt transaction adds the shipment's product and exact quantity to backstock. The owner or Manager can pause/resume automatic receiving at the staff board; a paused worker leaves the shipment at the dock for manual receipt.

Profile schema v13 adds a persistent delivery-worker hire flag and automation setting. Schemas v1–v12 default to no delivery worker and enabled automation. Existing shipments are unchanged and can still be received manually. No external assets are used.

## Acceptance criteria

- The delivery-worker hire action is available only on a completed shift when the profile owns a warehouse; it costs exactly `$140` and appears at the loading dock.
- Owner and Manager can pause/resume the worker at its board. Pausing cancels a scheduled pickup; resuming with a ready shipment schedules one new pickup.
- An enabled worker receives a shipment once, three seconds after it is ready. Citrus Pop, Berry Bites, Golden Apples, and Sunrise Cereal use the existing product ID, quantity, and capacity checks.
- Receipt increases only the matching backstock, clears the one-pending-shipment state, updates the dock/HUD, and persists through the existing `Economy.receiveDelivery` transition.
- Manual receipt remains available when automation is paused. A player/worker race cannot duplicate inventory.
- Rejoin preserves the hire/automation state and shipment; a ready shipment is collected once after rejoin if automation is enabled.
- Schema v1–v12 profiles remain valid. Missing delivery-worker hire flags migrate to false; missing automation flags default to enabled.
- Unauthorized, insufficient-funds, no-warehouse, not-ready, duplicate, over-capacity, out-of-range, rate-limited, save-pending, and lock-lost actions do not duplicate or discard inventory.

## Server/client boundary and failure handling

`Economy.hireDeliveryWorker` checks completed-shift eligibility, warehouse ownership, duplicate hire and fixed price. `Economy.toggleEmployeeAutomation` checks a fixed employee ID and hired state. `ShiftService` applies the common Owner/Manager, prompt range, request cooldown and profile lease gates. The delayed callback captures the shipment ready timestamp and a generation token, then rechecks worker state, shipment identity, owner readiness and save status before calling the existing `Economy.receiveDelivery`. `ProfileService` validates schema v13 and persists only the hire and automation flags; stock transfer uses the existing shipment save fields. `WorldBuilder` owns the worker model and dock presentation only.

## Manual Studio checklist

1. In the private development universe `10770581249`, start Rojo and connect Studio at `localhost:34872`. Keep Output visible.
2. Without a warehouse, complete a shift. Confirm the delivery-worker board cannot hire. Buy the warehouse, complete a shift, and confirm the board offers **Hire Delivery Worker ($140)**.
3. Try with less than `$140`; confirm no cash or hire change. With sufficient cash, hire once and confirm exactly `$140` is deducted and the worker appears by the loading dock.
4. Order each shipment type in separate runs. With automation enabled, wait for arrival plus three seconds; confirm the worker receives it once and only that product's backstock increases by the exact shipment amount.
5. Pause the worker before arrival and confirm the crate remains available at the dock. Resume after arrival and confirm receipt occurs once. Pause and use the manual receive prompt; confirm the same inventory result.
6. Race manual receipt against the worker timer. Confirm exactly one receipt, one backstock increase, and no duplicate dock reward.
7. Rejoin with an in-transit shipment and enabled worker. Confirm the shipment arrives and is collected once. Repeat with automation paused and confirm it waits for manual receipt.
8. Check Owner, Manager, Cashier, Stocker, Maintenance, visitor, prompt distance, rapid repeat, full backstock, save-pending and lock-lost cases.
9. Verify a legacy profile without the new flags loads with no delivery worker and enabled default automation. Confirm no Output errors and record cash, worker state, shipment ID/quantity, all backstock counts, role and save status.

## Known limits

- The worker only receives shipments. It does not place orders, stock shelves, drive a delivery vehicle, or handle multiple simultaneous shipments.
- Studio profile migration, timers, multiplayer authorization, and player/worker races have not been run locally.
