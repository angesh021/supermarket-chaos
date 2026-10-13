# ADR-0046 — Market Table restaurant plaza business

- **Status:** Accepted — 2026-10-13.
- **Context:** Stage 4 adds a restaurant as the next plaza business after the Corner Café. It should share the owner's economy while retaining separate restaurant progression and stock.
- **Decision:** Add the fixed Market Table restaurant after café ownership. Build costs `$1,200`; prep costs `$80` for four Garden Bowls up to 16; each served bowl earns `$38`. Existing Owner/Manager, Stocker and Cashier roles control build/prep/serve.
- **Consequences:** Profile schema v30 stores restaurant ownership, remaining meals and lifetime meals served. Restaurant service shares the main cash balance but does not advance grocery-shift customer counts. Existing profiles migrate to restaurant unowned and empty.
- **Verification:** See `docs/operations/PHASE48_MARKET_TABLE_RESTAURANT.md`; Studio build, service, role, migration and save/rejoin checks remain pending.
