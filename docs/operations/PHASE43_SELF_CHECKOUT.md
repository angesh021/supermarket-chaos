# Phase 43 — Persistent self-checkout lane

After the rear floor wing and warehouse are owned, the Owner or Manager can install a second checkout lane for `$300`. The server-built terminal is added to the existing movable checkout fixture. Eligible customers alternate deterministically between staffed checkout and self-checkout, with a separate queue position on each side of the fixture. Only the active lane prompt is enabled. Both prompts call the same atomic `Economy.sellProduct` transition, so basket selection, price, inventory, satisfaction and sale progression stay server-authoritative.

Profile schema v26 stores the self-checkout ownership flag. Legacy profiles default to not installed; profiles claiming the terminal without both rear-wing and warehouse prerequisites are rejected. The terminal and route rebuild from the owned flag. Moving/rotating the checkout fixture also moves the terminal and both queue routes.

## Acceptance criteria

- Only a completed shift, rear-wing and warehouse ownership, `$300`, Owner/Manager role, prompt range, cooldown and ready save lease allow installation.
- Failed purchases do not charge or build the station. Repeat purchase attempts cannot charge again.
- The installed terminal and lane sign appear at the checkout fixture and reconstruct after rejoin; legacy v25 profiles keep it uninstalled.
- Customers alternate deterministically: odd customer indexes use self-checkout after purchase, even indexes use the staffed register. Without the upgrade, all use the staffed lane.
- NPCs route to the correct lane, queue, advance, exit, and recover to the correct side after the route fallback.
- Only the prompt for the active front customer is enabled. Cashier/Manager and Owner may serve the self-checkout prompt; unauthorized roles cannot.
- Both checkout prompts recompute the basket and apply catalog price, inventory deductions, revenue, satisfaction and shift progression through the existing single-sale transition exactly once.
- The cashier employee continues serving either lane through the existing sale transition. Spill, outage, rush, wait-time and closeout behavior stay consistent.
- Moving/rotating checkout moves the terminal and both queue paths; shelf collision validation continues to reserve the checkout and queue area.
- Schema v25 migrates with no loss of cash, shelves, deliveries, employees, layout or satisfaction; the new flag is false.

## Server/client boundary and failure handling

`Economy.buySelfCheckout` owns the fixed cost, prerequisites and purchase state. `ProfileService` bounds the new boolean and requires the rear-wing/warehouse flags. `ShiftService` binds separate fixed prompt IDs to the same role/range/cooldown/save gate and shared economy sale. A server transaction lock spans sale mutation through profile save and world/queue refresh, preventing simultaneous helpers or the employee from selling the same visible customer twice. `WorldBuilder` owns presentation, deterministic queue assignment and lane prompt visibility; lane choice derives from server customer index and upgrade ownership. Clients submit no lane, product, basket, price, quantity or transaction result.

## Manual Roblox Studio verification

1. In the private development universe `10770581249`, use a disposable owner profile. Complete a shift, buy the first shelf bay and household aisle, build the rear wing, and purchase the warehouse.
2. Confirm the self-checkout build pad appears only at shift completion with its `$300` cost. Try as Visitor, Cashier, Stocker and Maintenance; confirm no role except Owner/Manager can install it. Try as Owner/Manager with insufficient funds and with the save lock unavailable; confirm no charge or fixture.
3. Purchase as Owner, then try again. Confirm exactly `$300` is deducted once, the terminal/sign appears, and the build pad clears.
4. Start a shift. Confirm customer 1 walks to self-checkout and only its prompt opens; customer 2 uses the staffed register; customer 3 returns to self-checkout. Confirm correct queue sides and prompt handoff after each sale.
5. Serve through both lanes. Verify identical basket labels, current SKU price, stock decrement, cash/sales, satisfaction and one-time sale feedback. Race two helpers or prompts on the same customer; confirm only one transaction succeeds.
6. Run spill, outage and rush schedules. Confirm neither lane can sell while the event blocks checkout, both resume for the correct front customer, and rush customers follow the same alternation. Verify cashier automation can serve a self-checkout-assigned customer without double service.
7. Move and rotate the composite checkout from the retail layout editor. Confirm the terminal, prompt, both queue routes and cashier/customer positions follow it, and nearby shelf placements remain rejected.
8. Rejoin and continue a saved shift. Confirm ownership persists without another charge, the active shopper uses the expected lane, and remaining queues reconstruct. Load a v25 profile and confirm the station is unowned while all existing profile state remains intact.
9. Confirm visitors cannot activate checkout prompts, non-owner viewers see no private inventory/cash, other universes remain session-only, and Studio Output has no errors.

## Local checks and runtime status

Run pinned StyLua, Selene, Rojo build and `git diff --check`; record exact results in `docs/PROJECT_STATUS.md`. Roblox Studio terminal visuals, lane routing, race handling, save/rejoin, migration, mobile prompts and multiplayer roles are not locally observable and remain pending.

## Limitations

This increment adds one second terminal to the existing checkout fixture and a shared alternating queue; it does not add independent checkout transactions, cashier staffing assignments or customer-specific lane choice. Lane selection is deterministic and server-derived.
