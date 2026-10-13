# Phase 64 — Movable purchased store fixtures

## Acceptance criteria

- Owners and Managers can move and rotate the purchased extra shelf bay and household aisle after a completed shift, using the existing retail layout station.
- Each fixture button is shown only when that upgrade is owned. The server independently checks fixture ID, ownership, permission, active location, prompt distance, save state, bounds, grid alignment, rotation and overlaps.
- Moving either model also moves its department sign. Core shelf placement, checkout and queue placement, bakery/freezer footprints, and the other purchased fixture remain clear.
- Retail layout version 4 persists placements separately for each store location. Versions 1–3 gain the two default placement records; if an old movable shelf conflicts with an owned fixed fixture, that fixture migrates to the nearest valid snapped main-floor spot. Profile schema and economy state do not change.
- A rejected or stale request leaves world and saved state unchanged. A save failure is reported to the player after the session world has moved.

## Server/client boundaries and failure handling

- The client sends a fixed `fixtureId`, snapped coordinates and 0/90 rotation. Client ghosts and ownership flags are presentation only.
- `ShiftService` requires Owner/Manager, completed shift, the active store location, nearby editor prompt and a ready profile save state. It throttles requests and rejects extra payload fields.
- `RetailLayoutService` bounds fixture IDs, positions and footprint collisions against core shelves, checkout queue, owned expansion departments and the other owned fixture. Server upgrade state is authoritative.
- `WorldBuilder` pivots the server-created Model, including its sign. No client Instances, costs, stock or prompts are accepted.
- Profile copy and normalization preserve nested placements per location. A failed save is not described as persisted; the server keeps the session edit and reports that save confirmation failed.

## Manual Studio checklist

1. In the development experience, buy the shelf bay and household aisle on a completed shift. Reopen the layout editor and confirm only owned fixture buttons appear.
2. Select each fixture, rotate it, move it to an empty snapped location, and confirm the full model and sign move together. Verify the fixture remains visible after closing and reopening the editor.
3. Try a core shelf, checkout queue, bakery/freezer department, the other purchased fixture, store boundary, fractional coordinate and unsupported rotation. Confirm overlapping/invalid placements are rejected and do not move the model.
4. Send an unowned fixture ID, extra request keys, a stale store location and a move as Visitor/Cashier/Stocker. Confirm rejection and no state change. Confirm Owner/Manager can edit only at the station during a completed shift.
5. Move fixtures in Neighborhood and Uptown independently. Rejoin and confirm each location restores its own fixture transforms and signs.
6. Load a profile with retail layout v1, v2 or v3 and existing shelf/checkout positions. Confirm the profile loads, retains its prior cash, stock and shelf coordinates, and normalizes the new fixture records.
7. Repeat editor controls with mouse and touch, narrow viewport, and Roblox chat open. Confirm the controls and status remain reachable.

## Verification status

- On 2026-10-13, StyLua 2.5.0 format and `--check src`, Selene 0.32.0 (0 errors/warnings/parse errors), Rojo 7.7.0 build to `%TEMP%\\supermarket-chaos-phase64.rbxlx`, and `git diff --check` passed.
- Roblox Studio transforms, collision behavior, multiplayer authorization, migration, touch UI and save/rejoin have not been observed locally and require the manual checklist above.

