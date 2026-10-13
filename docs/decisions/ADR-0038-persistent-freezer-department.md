# ADR-0038 — Add a persistent fixed freezer department

- **Status:** Accepted — 2026-10-13.
- **Context:** Stage 2 calls for a freezer section and more product variety. The bakery establishes the existing department, supplier and SKU paths; adding another free-form object type now would broaden placement risk and make the upgrade difficult to validate.
- **Decision:** Add a fixed, server-built freezer bay after rear wing, warehouse and bakery ownership. Integrate one server-priced SKU through existing inventory, delivery, stocking, pricing, basket, substitution, customer routing and persistence transitions.
- **Consequences:** Schema v25 adds one freezer ownership flag, shift/backroom stock counts and a price. The layout validator reserves the freezer footprint. Legacy profiles migrate with no freezer. Dynamic stock and price prompts must be bound before construction, then reparented on purchase.
- **Verification:** See `docs/operations/PHASE40_FREEZER_DEPARTMENT.md`; Studio purchase, visual, prompt binding, collision, migration, multiplayer and transaction checks remain pending.
