# ADR-0066: Assign departments to constructed grocery aisles

- **Status:** Accepted — 2026-10-13.
- **Context:** Constructed aisles add supermarket capacity and can be rearranged, but every aisle is labeled generically and does not contribute department-specific product display. The game already has six server-owned SKUs and stock transitions.
- **Decision:** Let the owner/Manager assign a built aisle to one existing product category. Keep stock and sales in the existing SKU state; distribute visible inventory facings across the original shelf and matching constructed aisles. Do not add a new SKU, delivery path, price, customer basket or sale route.
- **Consequences:** Retail layout v6 adds an allow-listed `productId` to constructed aisle placements. Legacy v1–v5 layouts migrate; older untyped aisles default to Citrus Pop. Bakery/freezer aisles require the matching owned department. Existing `$250` cost, four-aisle cap and server placement validation remain.
- **Verification:** See `docs/operations/PHASE70_MERCHANDISED_GROCERY_AISLES.md`; Studio layout, stock distribution, role, migration, touch and save/rejoin checks remain pending.
