# Phase 75 — Persistent retail expansion plot

## Purpose

Add a second walk-through room behind the rear department wing. The owner can buy it for `$900` after the rear wing, warehouse and freezer are owned. It raises the constructed grocery aisle limit from four to six; all six aisles remain movable and department-assigned through the existing retail layout editor.

## Authority and persistence

- `Economy.buyRetailPlot` derives the fixed price, completed-shift requirement, prerequisites, sufficient balance and one-time ownership on the server.
- The physical pad and prompt are server-created and exposed only when the purchase prerequisites are met. The existing Owner/Manager prompt authorization, range check, cooldown and profile save guard apply.
- The client sends only bounded layout actions and snapped coordinates. The server checks aisle ownership, plot ownership, floor bounds, rotation and collisions before spending the `$250` aisle price or changing the layout.
- Profile schema v41 stores `ownedUpgrades.retailPlot` in each location snapshot. Schemas v37–v40 migrate with the plot unowned; v40 is explicitly accepted for the one-version migration. Old retail layouts remain version 6 and layouts without plot ownership cannot contain more than four constructed aisles.
- A plot adds `$1` recurring shift upkeep using existing facility-cost rules. All purchases and money remain player-owned and server-authoritative.

## Acceptance criteria

1. The `$900` plot pad appears only after a completed shift, rear wing, warehouse and freezer ownership.
2. Insufficient funds, unauthorized players, prompt distance violations, duplicate purchase attempts and malformed client requests do not charge or build the room.
3. Purchase creates a walk-through opening, tiled extension, walls, ceiling, lights and grocery expansion sign. The room restores after rejoin without another charge.
4. Existing four-aisle layouts load without change. A fifth or sixth aisle is rejected without the plot and accepted only when the plot is owned and the placement is valid.
5. Aisle placement in the plot rejects out-of-bounds, overlapping or unsnapped transforms. Existing checkout, shelves, departments and fixtures remain protected from overlap.
6. Purchased aisles show their existing category and inventory allocation, follow saved movement/rotation, and existing customers route through both rear-room openings to stocked aisles before returning to checkout.
7. Completed-shift upkeep includes the plot exactly once and remains capped at `$15`; closing a shift twice does not charge twice.
8. The plot and aisle layouts remain isolated between a player's neighborhood and Uptown locations.

## Manual Studio checklist

Use the private development experience in universe `10770581249`; do not publish to production.

1. Start a completed shift with an owner profile that has the warehouse, household aisle, rear wing, bakery and freezer. Confirm the `$900` **Build Retail Plot** prompt appears at the back-right of the rear wing.
2. With less than `$900`, activate the prompt. Confirm the plot remains unbuilt and the balance does not change. Earn the funds and purchase once; confirm exactly `$900` is charged and the new room is walkable and lit.
3. As a helper without Owner/Manager permissions, try the prompt and layout editor. Confirm neither purchase nor edits are accepted. As Owner/Manager, try from outside prompt range and confirm no purchase occurs.
4. Open the retail layout editor. Build aisles one through four in valid existing zones. Attempt aisle five without the plot on a second eligible profile and confirm the server rejects it without charging. On the plot owner profile, build aisles five and six in non-overlapping marked positions; confirm each costs `$250`.
5. Attempt an aisle outside the plot floor, overlapping another fixture, with an invalid rotation, or with an unsnapped coordinate. Confirm each request is rejected without a charge or layout change.
6. Assign existing owned departments to aisles. Stock those products and confirm visible stock is divided across their facings, with no duplicated inventory. Run a shift and confirm shoppers can browse the stocked plot aisle and still reach checkout.
7. Close a shift and confirm plot upkeep is included once. Retry closeout and confirm no duplicate charge.
8. Leave and rejoin. Confirm the room and all aisle positions/categories return with the same company balance and no repurchase charge.
9. Verify a legacy v40 profile loads with no plot and its existing four aisles intact. If Uptown is owned, confirm neighborhood and Uptown plot ownership/layouts remain independent while company cash remains shared.
10. In a non-development universe, confirm the session-only fallback and no writes to development data.

## Failure handling and limitations

- The purchase is committed through the existing profile save path. If save confirmation is unavailable, follow the existing HUD save-status behavior and do not treat the purchase as durably saved until a subsequent confirmed save/rejoin.
- The new room supports the existing constructed grocery aisle fixture only. It does not add new SKUs, department types, floor editing or client-provided construction assets.
- Studio runtime, DataStore migration, multiplayer authorization and visual-fit checks remain pending until manually run.
