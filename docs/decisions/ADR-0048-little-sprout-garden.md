# ADR-0048 — Little Sprout Garden specialty retailer

- **Status:** Accepted — 2026-10-13.
- **Context:** Stage 4 calls for specialty retail businesses in the shopping plaza. This increment adds a garden store while keeping its stock and sales separate from supermarket shift progression.
- **Decision:** Add fixed Little Sprout Garden after Pixel & Plug. Build costs `$1,800`; restocking costs `$120` for three potted herbs up to 12; each sale earns `$75`. Owner/Manager build, Stocker restock and Cashier sell.
- **Consequences:** Profile schema v32 persists garden ownership, stock and sales. Existing profiles migrate with the store unowned and empty. Transactions share the owner's balance.
- **Verification:** See `docs/operations/PHASE50_SPECIALTY_RETAIL.md`; Roblox Studio construction, service, permissions, migration and save/rejoin remain pending.
