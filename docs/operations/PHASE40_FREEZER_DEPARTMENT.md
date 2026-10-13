# Phase 40 — Frozen foods department

After the rear wing, warehouse and bakery are owned, the Owner or Manager can build a fixed freezer section for `$400`. The department adds Freezer Meals as a sixth SKU, with its own visible shelf count, backroom stock, `$55` shipment of 18, restock batches of three, a 24-unit shelf cap and `$18/$22/$28` server-priced checkout tiers. The freezer fixture occupies a reserved rear-wing footprint; the purchase is rejected if a movable retail shelf already overlaps that area. A deterministic freezer add-on is requested by one in every four customers while the department is owned. It uses existing basket substitution and satisfaction handling.

Profile schema v25 adds the freezer ownership flag, shift shelf quantity, backroom quantity and price. Older profiles safely migrate to freezer not owned, no freezer stock, and the catalog price. Existing pending shipments remain unchanged. The freezer and bakery stock/price prompts are created before their departments are purchased, then reparented onto the built fixtures; this keeps their server bindings alive when the models are built later.

## Acceptance criteria

- Only a completed shift, valid prerequisites (rear wing, warehouse and bakery), available `$400`, Owner/Manager role, in-range prompt, cooldown and active profile save lease permit purchase.
- The server checks the current retail layout against the fixed freezer footprint before charging or building. Failed checks do not change cash, ownership or world state.
- The freezer section, package display, sign, stocking prompt and price tag are built server-side exactly once and reconstruct on rejoin.
- Stocking moves exactly three units from the freezer backroom to shelf, cannot exceed 24, and updates the visible packages and HUD.
- Only an owned freezer can order, receive, stock, price or sell Freezer Meals. A single pending shipment is charged `$55`, arrives after the existing 15-second wait, and adds 18 units to backstock exactly once.
- Customer add-on demand, stock resolution, substitution, displayed order, route, price and cash/stock transaction remain server-derived. Clients cannot select a SKU, quantity, cost, route or purchase state.
- Schema v24 profiles migrate without losing existing shelf layouts, inventory, pending shipment, prices, staff or satisfaction. Unowned profiles remain freezer-free.

## Server/client boundary and failure handling

`Economy` owns the SKU catalog, stock and delivery transitions, price options, demand selection, substitution, checkout deduction/credit and department purchase. `ProfileService` validates the new bounded fields, prerequisite consistency, shipment identifiers and schema migration, then saves through the existing serialized lease path. `RetailLayoutService` reserves the freezer case footprint when validating shelves. `ShiftService` gates purchase, stocking, price and delivery prompts through existing role, range, rate and save-lock checks. `WorldBuilder` renders authoritative fixture/stock state, routes customers to the fixed freezer position, and binds stock/price prompts before purchase so rebuilding a department does not create an unbound prompt. The HUD only displays the server snapshot.

## Manual Roblox Studio verification

1. In the private development universe `10770581249`, use a disposable owner profile. Complete the prerequisites in order: rear wing, warehouse and bakery. Confirm the freezer pad appears only after all three are owned and a shift is complete.
2. Attempt purchase with insufficient funds and as a visitor/Cashier/Stocker. Confirm no charge or build. As Owner and authorized Manager with `$400`, purchase; verify the exact deduction, freezer case/glass, visible frozen packages, sign, prompt and shelf clearance.
3. Move a rear shelf into the reserved freezer footprint before purchase on a disposable profile. Confirm the purchase is rejected; move the shelf clear and retry.
4. Stock once. Confirm the HUD changes from `0` to `3`, the backroom decreases by three, and three freezer packs appear. Repeat to 24; confirm further stocking is blocked and no count exceeds the cap.
5. Cycle the Freezer Meals price through `$18`, `$22`, and `$28`. Confirm the shelf tag follows it and a freezer basket checkout uses the current server price. Try changing the price or stocking before purchase; confirm both are rejected.
6. Order a shipment. Confirm `$55` is charged once, other order prompts are blocked while it is pending, the package displays arrival only after 15 seconds, and receiving adds 18 units once. Rejoin during a pending shipment and confirm it resumes.
7. Verify freezer add-on demand using deterministic customer progression: it is selected when `(sale number + completed shifts × 3) % 4 == 0`. Confirm the displayed basket and NPC browse route visit the freezer, then checkout charges and removes the actual SKU. Deplete freezer stock and verify substitutions/unfilled items use actual product labels, prices, stock and satisfaction scoring.
8. Hire a stocker and delivery worker on a completed shift. Confirm automatic stock/receipt use the same transitions, respect pause settings and cannot exceed stock caps. Race a player action against each employee.
9. Leave/rejoin. Confirm freezer ownership, stock, backstock, price, completed-shift progress and pending shipment persist with no second purchase/charge. Confirm legacy schema v24 profiles load with the freezer unowned and retain their existing bakery/retail state.
10. Confirm non-owner visitors see no private inventory/cash data, Studio Output contains no errors, and other universes remain session-only.

## Local checks and runtime status

Run pinned StyLua, Selene, Rojo build and `git diff --check`; record results in `docs/PROJECT_STATUS.md`. Roblox Studio prompt binding, visual fit, shopper routing, multiplayer authorization, race handling, migration and DataStore behavior are not locally observable and must not be reported as passed before Studio verification.

## Limitations

- This adds one fixed freezer bay and one product. User-placed department construction, additional checkout stations, and broader Mega Supermarket/Plaza/Retail Empire stages remain future work and require separate design/security/performance phases.
- No external assets, production publishing or Robux commerce are introduced.
