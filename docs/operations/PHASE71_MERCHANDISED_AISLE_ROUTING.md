# Phase 71 — Customer routing to merchandised aisles

## Goal and acceptance criteria

Make the new department-specific merchandise facings operationally visible to shoppers. When a basket calls for a product whose stock is displayed in a constructed aisle, scripted customers browse that stocked aisle instead of always walking to the original product shelf.

- Customer browse positions are derived from the current server-owned stock split and retail layout. Customers prefer the first saved, matching aisle with a positive allocated stock count; otherwise they use the original product shelf.
- Aisle routing respects saved rotation and is recomputed after stock transactions, aisle construction/movement, profile load and basket selection.
- No product selection, stock allocation, price, basket, payout or customer count is sent by the client or changed by routing.
- No profile schema change is introduced; the saved retail layout v6 and inventory remain authoritative.
- If an aisle has no allocated stock, customers do not route to it. Navigation continues to use the existing bounded route fallback.

## Server/client boundary and failure handling

`ShiftService` provides the current normalized layout and stock state to `WorldBuilder`. The server deterministically divides inventory-backed display units between the product's primary shelf and its assigned constructed aisles. `WorldBuilder` derives customer browse targets from those counts and saved transforms. Client layout previews never affect route targets. An empty or unassigned aisle is skipped, and the existing customer movement fallback handles stalled navigation. A route failure cannot grant currency or change inventory.

## Manual Roblox Studio checklist — pending

Use the development experience and a profile with the first shelf bay and at least one constructed product aisle.

1. Build a Citrus Pop merchandising aisle, stock three cans, and observe the first customer basket that requests Citrus Pop. Confirm the customer browses the aisle when it has allocated stock.
2. Move and rotate the assigned aisle. Trigger another matching basket and confirm the customer reaches the updated aisle frontage without crossing the shelf or queue.
3. Deplete inventory until the aisle receives zero allocated units. Confirm shoppers route to the original shelf instead.
4. Build two matching aisles and stock enough units to populate both. Confirm routing selects a valid stocked facing and never selects an empty aisle.
5. Repeat for Berry Bites, Golden Apples, Sunrise Cereal, Bakery and Freezer Meals; verify each uses its own department and existing stock authority.
6. Observe a mixed basket with products split across original shelves and constructed aisles. Confirm the customer visits each requested department once, then proceeds through the same checkout lane and sale transaction.
7. Confirm buying, moving or restocking an aisle never changes basket contents, price, stock total or sale payout. Compare the HUD stock before and after the sale.
8. Leave/rejoin and repeat. Confirm saved transforms produce the same browse target and a legacy v5 aisle migration routes as Citrus Pop.
9. Test a narrow viewport and touch layout while editing the aisle; route behavior must remain server-controlled and unchanged by preview selection.

## Verification status

Static formatting, lint, Rojo mapping and whitespace checks are recorded in `docs/PROJECT_STATUS.md` after implementation. Roblox Studio customer routing, transform, mixed basket, empty-stock, migration and save/rejoin behavior have not been run locally.
