# Phase 67 — Constructed grocery aisles

## Goal and acceptance criteria

After purchasing the first shelf bay, an Owner or Manager can spend `$250` to add up to four procedural grocery gondola aisles to an individual store location. Each aisle can be selected, moved and rotated between completed shifts. Main-floor aisles stay on the existing floor; rear-wing placements require the rear-floor expansion. Fixtures reuse original Roblox-part grocery shelving. They do not create a new SKU, stock, prompt, or sales route.

- The server sets the price and creates the aisle ID. Insufficient funds, missing prerequisites, a fifth aisle, malformed coordinates, unauthorized roles, wrong stage, excessive range, stale location IDs, or collisions reject without charging or changing the world.
- Placement snaps to the existing two-stud grid and permits only `0` or `90` degree rotation.
- The footprint clears merchandise shelves, checkout and its queue, owned bakery/freezer, purchased fixtures, other constructed aisles, produce, refrigeration, and upgrade boards.
- Successful builds deduct exactly `$250`, update the active location, and save through the current profile lease. The UI reports when save confirmation fails.
- Retail layout version 5 adds at most four GUID-keyed aisle placements. Versions 1–4 normalize with no aisles; no profile schema migration is required.

## Ownership and failure handling

`RetailLayout.client.luau` supplies only an action, snapped coordinates, rotation, and (for movement) an aisle GUID. Its translucent preview is local presentation and is not trusted. `ShiftService` checks the action-specific payload, Owner/Manager role, completed-shift state, edit prompt distance, profile-save state, and active location. `Economy` applies the fixed price, prerequisite and capacity rules. `RetailLayoutService` validates footprints and stored layout. `WorldBuilder` creates the fixture, and `ProfileService` saves the active location under the owner profile lease. A failed save is surfaced; runtime state remains for that session.

## Manual Roblox Studio checklist — pending

Run in the development experience only. Use two Studio clients for multiplayer checks.

1. Complete a shift, purchase the first shelf bay, open Edit Retail Layout, and confirm “Build grocery aisle ($250)” appears. Without the shelf bay, confirm the control is hidden and a forged `BuildAisle` request is rejected.
2. With at least `$250`, place one aisle on open main-floor space. Confirm the exact deduction, visible shelf fixture, saved-layout message, and that reopening the editor selects it for movement.
3. Rotate the aisle by 90 degrees, move it to another valid tile, and verify the shelf follows. Confirm another player sees the same layout.
4. Attempt placements overlapping a core shelf, checkout queue, purchased shelf bay/household aisle, produce island, refrigerator, upgrade board, bakery/freezer, and another constructed aisle. Each must be rejected without charging or moving fixtures.
5. Attempt a fifth aisle and an aisle with insufficient cash; verify no balance or layout change. Try invalid rotation, out-of-grid coordinates, extra payload keys, forged ID, and repeated requests.
6. With the rear wing, build and move an aisle into its floor. Without it, verify rear coordinates are rejected. Check the opening and customer routes remain usable.
7. Move core shelves, checkout, purchased fixtures, bakery and freezer into an existing aisle footprint. Each operation must be rejected. Confirm other valid movements still work.
8. Confirm Cashier, Stocker, Maintenance, non-members, and players outside the edit prompt cannot build or move aisles; Owner and Manager can edit only the correct location between shifts.
9. Build aisles in Neighborhood, travel to Uptown, and verify its layout is independent. Return and confirm Neighborhood aisles remain.
10. Leave and rejoin after building and moving an aisle in each location. Verify positions, rotations, cash, and old profiles without aisles load normally.
11. Repeat placement and selection with touch emulation and a narrow viewport. Confirm the panel, preview and floor bounds remain usable.

## Verification status

Source formatting, lint, Rojo mapping and whitespace checks are recorded in `docs/PROJECT_STATUS.md` after implementation. No Roblox Studio runtime, DataStore, multiplayer, touch, or migration run is claimed here.
