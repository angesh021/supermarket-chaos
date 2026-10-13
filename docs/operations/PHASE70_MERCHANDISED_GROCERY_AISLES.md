# Phase 70 — Merchandised grocery aisles

## Goal and acceptance criteria

Make constructed gondola aisles part of the store's department layout. A built aisle can now be assigned to one of the existing six server-owned products and carries that department's sign and visible product stock.

- Before building, Owner/Manager selects an available department in the retail layout editor. The existing `$250` build price, four-aisle cap, grid, floor, collision and location checks remain in force.
- Citrus Pop, Berry Bites, Golden Apples and Sunrise Cereal are available with the first shelf bay. Cinnamon Twists and Freezer Meals are available only after their departments are owned.
- The server validates the product ID and prerequisite. The client cannot submit a price, stock amount or product outside the allow-list. Moving a saved aisle preserves its assigned department.
- Aisle product and placement persist in retail layout version 6. Existing version 1–5 layouts migrate; untyped version 5 aisles become Citrus Pop aisles. No profile schema bump is required.
- Visible product units are distributed between the primary shelf and any constructed aisle assigned to that product. The number of inventory-backed display units across those facings equals server shelf stock; a second facing does not create inventory or sales authority.
- Constructed aisles use category-specific signs and package colors. Existing customer baskets, stock prompts, sale prices and customer routes remain unchanged.

## Server/client boundary and failure handling

The retail layout UI sends only the existing placement fields plus an allow-listed product ID when building. `ShiftService` bounds the request shape and product ID length, checks Owner/Manager membership, completed-shift state, edit prompt distance and profile save readiness. `Economy.buildRetailAisle` derives the price, prerequisites, cap and server-generated GUID. `RetailLayoutService` normalizes and validates the versioned aisle record and all prior footprint checks. Invalid categories, missing bakery/freezer prerequisites, malformed payloads, overlaps, insufficient funds and stale layout requests leave cash and layout unchanged.

`WorldBuilder` renders each aisle's assigned sign and divides the server inventory count across the original display and matching constructed aisles. No client visual value is treated as inventory, and no constructed aisle adds a product, stock, checkout payout or customer demand. Layout v5 records without a category normalize to Citrus Pop and are rewritten in v6 form on the next profile save.

## Manual Roblox Studio checklist — pending

Use the development experience (`10770581249`) with one owner profile and a second client for role checks.

1. Build the first shelf bay, complete a shift, open Edit Retail Layout and confirm the four existing core categories can be selected before choosing `Build selected aisle ($250)`.
2. Build an aisle assigned to each core department. Confirm the exact `$250` charge, matching aisle sign, category-colored product units, and that selecting/moving the aisle does not change its department.
3. Stock each core product. Count inventory-backed display parts on the original shelf plus all matching constructed aisles; confirm the sum equals the shelf stock shown in the HUD. Sell one unit and confirm exactly one display unit disappears and the existing sale amount is credited once.
4. Build bakery and freezer departments, then verify their categories become available for new aisles. On a profile without those upgrades, forge a `BuildAisle` request for Cinnamon Twists and Freezer Meals; confirm rejection without a charge or fixture.
5. Verify Cashier, Stocker, Maintenance, Visitor and non-members cannot build or move aisles; Owner/Manager can only edit the active location between shifts and near the layout station.
6. Attempt an unknown product ID, oversized product ID, extra request fields, insufficient balance, fifth aisle, off-grid point and collisions with every existing fixture. Each rejected action must leave cash and layout unchanged.
7. Move and rotate each assigned aisle and confirm package facings, signs and product category remain attached after the fixture transform. Confirm checkout/customer paths stay clear.
8. Leave and rejoin. Verify category, placement, stock display, stock counters and cash persist independently in Neighborhood and Uptown.
9. Load a v5 layout containing untyped constructed aisles and verify each migrates as Citrus Pop; verify existing shelves, prices, branch snapshot, profile balance and aisle placements are preserved.
10. Repeat core category selection, preview and movement using touch emulation and a narrow viewport.

## Verification status

Source formatting, lint, Rojo mapping and whitespace checks are recorded in `docs/PROJECT_STATUS.md` after implementation. Roblox Studio inventory visuals, editor flow, role checks, migration and save/rejoin have not been run locally.
