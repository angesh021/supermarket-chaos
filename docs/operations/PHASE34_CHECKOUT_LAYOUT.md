# Phase 34 — Movable checkout lane and queue

## Acceptance criteria

- A completed-shift Owner or Manager can select the checkout lane at the Retail Layout Station and move/rotate the full register fixture.
- The register counter, conveyor, bagging surface, scanner, screen, display GUI, overhead sign, impulse rack, and treat packs move together.
- All five customer queue slots and the cashier move with the fixture. Customer checkout approach and exit paths derive from the new lane transform.
- The server validates a snapped position, 0/90-degree rotation, store bounds, department shelf clearance, produce island clearance, and layout-station clearance before changing state.
- The selected layout is saved to the player's profile. Schema v21 migrates earlier shelf layouts to the default checkout position without resetting their shelves.
- Invalid requests, non-owner/manager requests, out-of-range callers, requests outside the completed-shift gate, and save-lock failures do not update the saved layout.

## Server/client boundary and failure handling

- The client provides selection, snapping, rotation, and a local footprint preview only.
- `ShiftService` checks role, player/store state, completed-shift stage, physical station range, save lock, request cadence, and layout validation. The client cannot set cash or customer state.
- `RetailLayoutService` owns the compact schema and overlap/bounds checks. The server applies the accepted transform and persists the layout; an unconfirmed save is reported as session-only.
- Legacy schema-v20 layouts (version 1) retain all four department locations and gain the default checkout location.

## Manual Roblox Studio verification

1. In development universe `10770581249`, complete a shift and open the editor from the Retail Layout Station.
2. Select the checkout in the editor and by tapping its physical model; rotate it once and move it to a clear front-floor tile. Confirm the counter, conveyor, scanner, display, sign, impulse rack, cashier, and queue move together.
3. Move/rotate a department shelf. Confirm its prompt, price tag, and customer browse target remain attached/correct.
4. Try positions that intersect each department shelf, produce island, layout station, and store boundary. Confirm each is rejected without moving the fixture.
5. As a helper without Manager role, attempt to edit. Then try as Manager and Owner from within and outside station range; only authorized in-range calls should apply.
6. Save, leave, and rejoin. Confirm both the checkout transform and shelf positions return. Test an older profile or a copied v20 profile to verify migration keeps shelf positions and defaults checkout.
7. Run a customer shift after repositioning and verify each shopper reaches the register, queue advances, cashier automation serves correctly, and the exit route completes.
8. Test touch input: select, rotate, move, reject an invalid target, and close the editor.

## Local checks and runtime status

- Required local formatter, linter, Rojo build, and diff checks are recorded in `docs/PROJECT_STATUS.md` after implementation.
- Roblox Studio customer navigation, SurfaceGui face orientation after rotation, multi-account authorization, DataStore migration/save, and touch controls require manual verification; no runtime result is claimed here.
