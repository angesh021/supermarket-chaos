# ADR-0047 — Pixel & Plug electronics store

- **Status:** Accepted — 2026-10-13.
- **Context:** Stage 4 calls for an electronics business in the shopping plaza. It should share player-owned progression and money while keeping its stock and sales separate from supermarket shifts.
- **Decision:** Add a fixed Pixel & Plug storefront after the Market Table restaurant. Build costs `$2,400`; restocking costs `$300` for two headphones up to eight; each sale earns `$220`. Owner/Manager build, Stocker restock and Cashier sell.
- **Consequences:** Profile schema v31 stores ownership, current stock and cumulative sales. Existing profiles migrate with Pixel & Plug unowned and empty. Sales share the owner balance but do not advance supermarket customer counts.
- **Verification:** See `docs/operations/PHASE49_ELECTRONICS_STORE.md`; Roblox Studio construction, service, permissions, migration and save/rejoin remain pending.
