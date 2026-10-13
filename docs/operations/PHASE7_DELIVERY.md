# Phase 7 warehouse delivery verification

Run in the private development experience for universe `10770581249`. This feature has not been exercised in Studio; keep the gate open until each applicable check is observed. Use a second account to test Manager permissions and prohibited roles.

## Setup

- Pull the latest `main`, run `rojo serve default.project.json`, and connect Studio's Rojo plugin to `localhost:34872`.
- Use a profile that owns the warehouse annex. For a clean profile, complete the first upgrade and earn enough fictional currency to purchase the $200 warehouse and a $60 delivery.
- Keep Studio Output visible. Record the player's starting balance, backstock, and shift stage.

## Order and receive

- [ ] Confirm the HUD shows 12 backroom cans on a migrated profile to store members; a visitor does not receive the count.
- [ ] With less than $60, try to order. Confirm the request is rejected and balance, backstock, and shipment remain unchanged.
- [ ] With at least $60, order once. Confirm exactly $60 is deducted, the board says delivery is en route, and no crate can be received early.
- [ ] Try to order again while the shipment is pending. Confirm there is no second charge or duplicate shipment.
- [ ] Wait at least 15 seconds. Confirm one labeled 24-can crate appears at the dock and the receive prompt becomes available.
- [ ] Receive it once. Confirm backstock increases by exactly 24, the crate and prompt clear, and the order board becomes available again.
- [ ] Race the receive prompt with two clients or rapid inputs. Confirm only one receipt is applied.
- [ ] Start/continue a shift and stock. Confirm exactly three backroom cans are consumed; a rejected stock action does not change inventory.
- [ ] Place the owner farther than the prompt range and attempt each action. Confirm neither order nor receive succeeds.

## Permissions and persistence

- [ ] As a Manager, order and receive successfully. As Cashier, Stocker, Maintenance and Visitor, confirm neither action is authorized.
- [ ] Order, leave before arrival, rejoin and wait the remaining time. Confirm there is no refund/recharge and one shipment becomes collectable.
- [ ] Order, allow arrival, leave without receiving, then rejoin. Confirm one crate is still available and can be received once.
- [ ] Order and receive, then leave/rejoin. Confirm the new backstock balance persists without another charge.
- [ ] In a non-development universe, confirm session-only status and that interactions do not write to the development DataStore.
- [ ] Inspect Output for errors and note any mismatch, exact starting state, action order and final balance/inventory.

## Expected limits

- Backstock capacity is 500 cans, one 24-can shipment can be pending at a time, and an order costs $60.
- Delivery timing is server-time based. On rejoin, an elapsed shipment timestamp is immediately collectable.
- This increment supports only Citrus Pop. It does not yet include multiple SKUs, a delivery vehicle/NPC, supplier pricing or warehouse layout management.
