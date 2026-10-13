# Phase 32 retail department layout

## Scope

Owners and authorized Managers can reposition and rotate the four existing product department shelves from the physical Retail Layout Station after a completed shift. Shelves snap to a bounded two-stud grid and rotate in 90-degree steps. Product identity, stock prompt, price controls, shelf label and product display move together. Customer browsing destinations follow the shelf positions.

Profile schema v19 adds a compact version-1 retail layout. Existing profiles migrate to the current starter layout. Moving a shelf has no purchase cost and does not alter inventory or product pricing. This increment does not yet reposition checkout, create departments, expand the floor, unlock commercial plots, or place arbitrary furniture.

## Server/client boundary and failure handling

- The client opens through the physical station prompt and sends only product ID, snapped coordinates and 0/90-degree rotation.
- `ShiftService` validates Owner/Manager role, completed-shift stage, prompt range/enabled state, player presence, save status, request rate, product allow-list and `RetailLayoutService` bounds/collisions.
- `RetailLayoutService` validates stored profiles during load and rejects malformed, missing, unknown, non-finite, off-grid, out-of-bounds or overlapping shelf records.
- The four shelf models and their price/stock prompts remain server-built. The server moves the complete model and saves its compact position; clients cannot send instances, costs, stock or prices.
- Customer browse paths are recalculated from the server-approved layout. Invalid requests leave the current world and profile layout unchanged.
- Schema v19 migrates v1-v18 profiles to the default layout without changing their existing upgrades, shifts, balances or inventory.

## Acceptance criteria

1. The physical station is available only to the Owner/Manager during a completed shift.
2. Each of the four product department shelves can be repositioned on the marked grid and rotated by 90 degrees.
3. Retail shelf product identity, stock prompt, price tag and price-change prompt remain attached after movement/rotation.
4. The server rejects off-grid/fractional coordinates, unsupported rotations, floor-edge placement, overlap with another product shelf, and overlap with fixed expansion bays.
5. A valid move changes no cash, stock, sale count or product price; it updates the physical shelf and customer browsing destination.
6. A v18 profile opens with the default retail layout. A saved custom layout returns after rejoin without duplicate shelves.
7. Visitors, Cashier, Stocker and Maintenance cannot open or modify the layout. A Manager can edit only nearby during a completed shift.

## Manual Studio verification

1. In the development universe, load an existing v18 profile. Confirm all previous progression and inventory remain available and product shelves use the starter layout.
2. Finish a shift and approach **MOVE DEPARTMENT SHELVES**. Confirm the prompt is visible and opens the editor.
3. Select Citrus Pop. Move it to a free snapped tile, then rotate it 90 degrees and move it again. Confirm its cans/shelf prompt, department sign and price prompt move together.
4. Repeat with Berry Bites, Golden Apples and Sunrise Cereal. Try a crowded and a clear position. Confirm overlap rejection does not move any shelf.
5. Try positions beyond each floor edge, a fractional coordinate, unsupported rotation and a spoofed product ID with a disposable client. Confirm no world or saved-state mutation.
6. Change a moved SKU's price and stock it. Confirm the prompts still reach the same SKU and customer checkout remains correct.
7. Serve a basket containing a moved SKU. Confirm the customer route browses the moved department before reaching checkout.
8. Move a shelf, leave and rejoin. Confirm every department reconstructs at its saved position and rotation exactly once.
9. As Manager, confirm editing works only during Complete and near the station. As Visitor, Cashier, Stocker and Maintenance, verify the prompt/remote cannot modify shelves.
10. Check mobile touch selection, ghost rotation, floor tapping and the HUD/chat safe area. Record any stuck route or Output error.

## Verification status and limits

Static formatting, lint, Rojo build and diff checks are recorded in project status. Roblox Studio layout, customer navigation, profile migration/rejoin, prompt visibility and touch behavior remain unverified. Phase 63 extends layout version 3 to move a purchased bakery or freezer in the rear wing; see `PHASE63_EXPANSION_DEPARTMENT_LAYOUT.md`. Arbitrary client-created furniture and new department types remain future increments.
