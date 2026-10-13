# Phase 29 warehouse layout editor

Warehouse owners and authorized Managers can edit storage fixtures from the physical layout board during a completed shift. The editor previews a shelf locally and proposes placement, movement, rotation or removal. The server accepts only a fixed shelf type, a bounded two-stud grid, the allow-listed 0/90 degree rotations, and a maximum of six fixtures. Placement costs `$50`; removal refunds `$25`. Layouts are compact version-1 profile records (schema v18) and reconstruct on rejoin.

This is the first editable-layout slice for the warehouse. The customer-facing store floor, plot ownership, checkout placement, arbitrary object models and free-angle transforms are not covered by this editor.

## Acceptance criteria

- `WarehouseLayoutRequest` opens only through the warehouse board prompt, which is Owner/Manager-only and range-checked.
- The client can preview and propose placing, selecting, moving, rotating between 0/90 degrees, and removing a storage shelf.
- The server validates player role, active store membership, completed-shift state, warehouse ownership, profile save lock, proximity, request rate, action ID, shelf ID, numeric type, grid, floor footprint, rotation, collision against existing fixtures, item cap and available cash.
- Client-provided instances, IDs for new objects, costs, model names, layout arrays, arbitrary angles and out-of-zone coordinates are never trusted or persisted.
- Placement costs exactly `$50`; removal refunds exactly `$25`; movement and rotation do not change cash. Invalid edits leave both cash and the current layout unchanged.
- At most six shelves can be persisted. Overlapping footprints, wall/board intersections, non-finite coordinates, malformed saved records, duplicate IDs and fixtures without warehouse ownership are rejected.
- Profile schema v18 migrates all v1–v17 profiles to an empty version-1 layout. Existing balances, upgrades, products, shifts, employees and shipments remain intact.
- The resulting layout is saved with the existing serialized profile path and is rebuilt from server records after profile load.

## Server/client boundary and failure handling

The client preview is visual-only. `ShiftService` treats every request as untrusted, applies permission, profile-lock, distance and rate checks, then delegates grid and collision validation to pure `LayoutService` rules. Server-generated GUIDs identify placed shelves. The server owns the layout array, cash transaction, world instances and save call. `ProfileService` validates a compact allow-listed record shape and clones it on DataStore writes. `WorldBuilder` rebuilds only server-approved shelves under the purchased warehouse.

Requests are rejected without changing state when the owner is offline, profile saving is pending/locked, the shift is active, the warehouse is not owned, the player is out of range, or the request fails layout validation. The layout request response contains a bounded message; it cannot change authoritative state.

## Manual Studio checklist

1. Load a v17/older profile. Confirm it migrates with an empty storage layout and existing profile values remain available.
2. Without a warehouse, confirm there is no usable layout prompt/editor. Buy the warehouse and approach its physical layout board after a shift is complete.
3. Confirm an Owner can open the editor and sees a local shelf preview. Place one shelf at a valid floor grid point; confirm `$50` is deducted and the shelf appears after server confirmation.
4. Place shelves close to one another. Confirm an overlapping proposal is rejected, the existing fixture stays put, and no second charge is made.
5. Select a placed shelf, move it, rotate it by 90 degrees, and verify server acceptance only at valid floor positions.
6. Remove a shelf and confirm `$25` is refunded once. Attempt removal again and confirm no extra refund.
7. Reach six shelves and confirm a seventh placement is rejected. Try points outside every edge, a wall/board overlap, and a fractional or spoofed coordinate using a disposable test client; confirm no world or cash mutation.
8. Rejoin and confirm positions/rotations return and no duplicate fixtures appear. Verify the serialized layout contains only version, generated IDs, shelf kind, grid x/z and 0/90 rotation.
9. As a visitor and a Cashier, confirm the layout prompt and remote requests cannot modify the store. As a Manager, confirm editing works only while nearby, Complete, warehouse-owned and save-ready.
10. Set the profile to a pending or lost lease in a disposable test and confirm edits stop. Verify the existing delivery crate, board, loading door and route remain reachable.
11. Check the preview and controls with Studio touch emulation; confirm it does not intercept clicks outside layout-edit mode.

## Limitations

- Only warehouse storage shelves are editable. The main retail floor remains mostly fixed; purchasable plots, department construction, checkout placement, arbitrary object rotation, in-game layout undo and client-side exact collision previews remain future work.
- This code has passed local formatting, lint and Rojo build checks only; Studio UI, DataStore migration, multiplayer authorization, collision and rejoin behavior have not been run.
