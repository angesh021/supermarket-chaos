# ADR-0065: Make Riverside Bookshop a persistent plaza business

- **Status:** Accepted — 2026-10-13.
- **Context:** The neighborhood commercial district has an existing bookshop shell, but only Maple Corner Florist is functional. A second business should add visible retail variety while reusing the established server-owned plaza and player-profile architecture.
- **Decision:** Unlock Riverside Bookshop after florist ownership for `$2,500`; restock three paperbacks for `$300` (12-item cap) and sell each for `$130`. Owner/Manager build, Manager/Stocker restock, and Manager/Cashier sell. Plaza visitors use the existing business sale event and lock.
- **Consequences:** Profile schema v40 stores ownership and bounded stock/sales in the neighborhood snapshot; v39 location snapshots migrate with false/zero defaults. Bookshop is part of the existing neighborhood location, not an independent branch. All prices and quantities remain server-owned.
- **Verification:** See `docs/operations/PHASE69_RIVERSIDE_BOOKSHOP.md`; Studio visuals, role, visitor-sale, migration and save/rejoin checks remain pending.
