# ADR-0067: Route customers to stocked aisle facings

- **Status:** Accepted — 2026-10-13.
- **Context:** Phase 70 distributes a SKU's visible stock between its primary shelf and matching constructed aisles. Existing customer routes still target only primary shelves, so a customer may walk past the actual product facing.
- **Decision:** Derive the customer browse position from normalized aisle assignments and current server stock allocation. Prefer a constructed aisle with positive inventory; fall back to the original shelf when none is stocked.
- **Consequences:** Route state is runtime-derived and adds no profile fields, remotes or client authority. Basket composition, inventory, price and checkout remain unchanged; movement uses the established bounded fallback.
- **Verification:** See `docs/operations/PHASE71_MERCHANDISED_AISLE_ROUTING.md`; Studio routes, empty stock, mixed baskets and save/rejoin remain pending.
