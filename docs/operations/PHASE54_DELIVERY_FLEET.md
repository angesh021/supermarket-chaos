# Phase 54 — Delivery fleet

## Acceptance criteria
- Owner/Manager can purchase the one-time `$3,000` delivery fleet only with a warehouse, hired delivery worker and completed shift.
- Purchase creates two fixed non-colliding truck visuals at the loading area and persists ownership.
- With the fleet and worker automation enabled, at most three online grocery orders are packed per completed shift. Without the fleet the existing limit remains one.
- Manual and automatic orders use the same order rotation, current server prices, backroom stock deductions, payout and transaction lock; manual orders count toward the three-order fleet limit.
- Insufficient stock, disabled automation, unavailable profile/lease or a concurrent transaction produces no extra order, payout or stock deduction.
- Profile schema v34 persists a bounded 0–3 order count. A v33 profile whose order marker equals its completed-shift ID migrates with count 1; other profiles default to 0. The fleet requires warehouse and delivery-worker ownership.

## Server/client boundaries
- `Economy.buyDeliveryFleet` owns the fixed cost and prerequisites. Clients send no cost, count or capacity.
- `ShiftService` checks role, range, cooldown, profile readiness and the shared transaction lock. Worker callbacks recheck shift ID, automation state, fleet cap, order readiness and lease/save state before fulfilling.
- `Economy.fulfillOnlineOrder` remains the single authoritative stock/payout transition.
- `ProfileService` validates and persists fleet ownership and per-shift order count; profile versions above v34 remain rejected.

## Failure handling and limits
- Full or unavailable backroom stock prevents order packing. The worker stops when the deterministic next order is not ready or the per-shift cap is reached.
- Pausing delivery-worker automation cancels future fleet orders. Existing inbound shipment pickup behavior continues through the same worker toggle.
- This increment uses two stationary fleet visuals and does not simulate driving routes, fuel, vehicle damage, multiple store locations or distribution centers.

## Manual Roblox Studio verification checklist
1. Confirm the fleet pad is hidden or disabled without a warehouse and hired delivery worker.
2. With warehouse and worker owned, try buying with less than `$3,000`; confirm no charge or trucks appear. Buy with sufficient cash and confirm exactly `$3,000` charged and two trucks appear at the loading area.
3. Without the fleet, confirm worker automation packs no more than one online order per completed shift.
4. With fleet and automation enabled, prepare sufficient backroom stock for all three orders; confirm the worker packs at most three, charges/credits the listed server total, consumes exact stock and advances the order number each time.
5. Pack one order manually, then let the worker run; confirm manual and automatic orders together do not exceed three for that shift.
6. Disable delivery-worker automation before the callback; confirm no automatic packing occurs. Re-enable it and verify future eligible orders can be handled.
7. Run low-stock and concurrent player/worker packing cases; confirm no negative backstock, duplicate payout or lost balance update.
8. Save and rejoin after a worker order; confirm fleet ownership, order count, inventory and balance persist and the worker does not repeat a completed order.
9. Load a v33 profile with and without a current-shift order marker; confirm migration assigns count 1 only to the matching marker and preserves all existing progress.
10. Inspect Output and check truck collision, loading dock access and visibility at desktop/mobile camera sizes.

## Verification status
- Pinned StyLua 2.5.0 `--check src`, Selene 0.32.0 (`0 errors, 0 warnings, 0 parse errors`), Rojo 7.7.0 build to `%TEMP%\supermarket-chaos-phase54.rbxlx`, and `git diff --check` passed on 2026-10-13.
- Roblox Studio purchase, truck visuals, one/three-order caps, manual/automatic races, migration and save/rejoin: pending; no runtime success is claimed.
