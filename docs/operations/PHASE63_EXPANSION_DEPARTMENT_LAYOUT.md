# Phase 63 — Movable expansion departments

## Acceptance criteria

- The Owner or Manager can use the existing retail layout station after a completed shift to move and rotate a built bakery or freezer on the rear-floor grid.
- A department stays absent from the editor until purchased. The server rejects attempts to move an unowned department, place outside the expanded floor, use fractional/off-grid coordinates, overlap another fixture, or use an unsupported rotation.
- A department keeps its sign, prompt, stock display, price tag and stocked items together. Customer basket browsing destinations use the new department location.
- The four core product shelves cannot overlap installed bakery/freezer footprints. Their stock, prices, product IDs and checkout routes remain unchanged.
- Retail layout version 3 stores two bounded expansion department placements. Existing v1/v2 layouts normalize to the default placements without changing profile schema, inventory, cash or ownership. Location snapshots retain independent layout state.
- Layout edits require Owner/Manager role, completed shift, nearby station, valid save status and the existing request throttle. Layout contents and coordinates remain server validated.

## Server/client boundaries and failure handling

- The client editor sends only a fixed product ID, grid coordinates and 0/90 rotation. It cannot provide an Instance, cost, ownership flag, prompt, stock count or route.
- `RetailLayoutService` validates layout version, exact core shelf IDs, bounded expansion department IDs, compact coordinate records, floor bounds, fixture footprints and overlaps. ShiftService verifies ownership and role before changing the layout.
- `WorldBuilder` applies approved placements to the server-created department Model and keeps product identity, prompts, tags and stocked visuals inside that model. Customer targets are recalculated from the stored position.
- Invalid or stale requests return a rejection without updating the world or saved layout. The existing profile lease and serialized writer persist the normalized layout for the active location.

## Manual Studio checklist

1. In the development experience, buy the rear floor, warehouse and bakery. Finish a shift and open the retail layout editor. Confirm Bakery appears; Freezer remains hidden until purchased.
2. Move the bakery to a free rear-floor grid location and rotate it 90 degrees. Confirm the oven/counter/sign, price tag, stocking prompt, stock visuals and bakery sign move together.
3. Stock pastries and reprice the SKU before and after moving it. Confirm the prompt still stocks Cinnamon Twists and the tag shows the same server price.
4. Build the freezer, move and rotate it independently, then stock Freezer Meals. Confirm both expansion departments can coexist in valid placements.
5. Try moving one fixture into the other fixture, a core shelf, checkout queue, boundary, a fractional coordinate, and an unsupported rotation using a disposable client. Confirm every invalid request leaves the world and profile unchanged.
6. Move a core shelf into an installed department footprint and confirm rejection. Move it to a clear spot and verify its product route and checkout stock remain correct.
7. Serve customers preferring bakery/freezer products. Confirm they browse the moved department, then reach checkout and complete the expected sale.
8. Rejoin and confirm both locations restore their own placements, signs, prompts, stock, prices and routes. Verify an existing v2 layout receives default expansion coordinates and retains prior progression.
9. Confirm Manager can edit; Visitor, Cashier, Stocker and Maintenance cannot. Repeat with neighborhood and Uptown.

## Verification status

- StyLua 2.5.0 formatting, Selene 0.32.0 (0 errors/warnings/parse errors), Rojo 7.7.0 build and `git diff --check` passed on 2026-10-13.
- Roblox Studio customer routing, fixture pivots, multiplayer permissions, save/rejoin and mobile layout checks have not been observed yet.
- This increment makes already-purchased bakery/freezer fixtures movable; it does not introduce arbitrary client-created furniture or department types.
