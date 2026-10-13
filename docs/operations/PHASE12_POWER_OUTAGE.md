# Phase 12 power outage verification

This increment adds a bounded checkout power outage. Since Phase 31, the server schedules it after sale 1 or 2 according to the reproducible per-shift Chaos Director plan. The queue pauses at a visible breaker objective; an authorized player can restore power immediately, and a server timer restores it automatically after 30 seconds. The outage stage and deadline are saved. Studio/runtime and DataStore behavior have not been verified locally.

## Acceptance criteria

- The scheduled successful sale credits its catalog price and consumes the basket once, then sets the server-owned `PowerOutage` stage.
- The checkout area visibly darkens, overhead PointLights turn off, the breaker sign appears, the objective updates, and checkout remains disabled while the queue stays visible.
- Owner, Manager and Maintenance can restore power at the in-world breaker. Cashier, Stocker, Visitor and out-of-range players cannot.
- Manual restoration changes the stage to `Checkout`, clears the saved deadline, and resumes the existing queue without an additional reward or sale.
- If nobody restores power, the server automatically restores it after 30 seconds without changing money, inventory or sale count.
- Rejoining during the event reconstructs the outage and remaining deadline. If the deadline elapsed offline, recovery happens promptly after load.
- Profile schema v8 accepts the `PowerOutage` stage only with a valid bounded timestamp; prior schema profiles default to no outage.
- Cashier automation pauses during the outage and resumes only after restoration. Berry Bites stocking remains disabled while the outage is active.

## Server/client boundaries and failure handling

`Economy.sellProduct` activates the event at the schedule's first or second sale and uses server time to set its deadline. The schedule is reconstructed from owner ID and completed-shift count by the Phase 31 Chaos Director. `Economy.restorePower` and `Economy.recoverPower` are the only state transitions out of the event. `ShiftService` checks the ordinary owner/role, prompt ancestry, distance, profile status and cooldown before a breaker interaction; its server timer rechecks the current stage/deadline and save-lock status. The profile persists the active stage and deadline. `WorldBuilder` only presents the breaker and lighting change. No client timer, event ID, reward, sale, or recovery state is accepted. If profile saving is pending, automatic recovery waits and retries; if the profile lock is lost, it does not mutate saved gameplay state. The timer has no penalty or destructive timeout.

## Manual Studio checklist

1. In private development universe `10770581249`, run `rojo serve default.project.json` and connect Studio to `localhost:34872`. Keep Studio Output visible.
2. Recover the cart and stock. Use [Phase 31 Chaos Director checks](PHASE31_CHAOS_DIRECTOR.md) to learn the current shift schedule. Confirm the sale that triggers the outage still pays its selected basket correctly.
3. After that scheduled sale, confirm the store dims, the checkout prompt disables, the next customer remains visible, and the objective directs you to the breaker next to checkout.
4. Restore power as Owner. Confirm lighting returns, checkout resumes, cash/stock/sales do not change during restoration, and using the breaker again has no effect.
5. Repeat with Manager and Maintenance; both should be able to restore. As Cashier, Stocker, unapproved Visitor, and out of range, confirm the breaker cannot be used.
6. Trigger the outage again and wait 30 seconds. Confirm backup recovery restores lighting and checkout automatically without extra cash, stock use, or sale count changes.
7. Trigger the outage and leave/rejoin before the deadline. Confirm the outage and remaining wait restore. Repeat after the deadline has elapsed offline and confirm the queue resumes on load.
8. With a cashier employee, confirm it cannot sell through the outage and resumes after manual or timed recovery. Confirm Berry Bites restocking is unavailable during the outage.
9. Inspect Output. Record stage, timer behavior, role, cash, shelf counts, sales, save status, and any errors for each result.

## Known limit

The outage schedule is now reproducible but varies across shifts. It dims global Lighting for this one-store-per-server experience and does not simulate damaged equipment, outage costs, weather, or sound effects.
