# ADR-0045 — Persistent Corner Café plaza business

- **Status:** Accepted — 2026-10-13.
- **Context:** Stage 4 introduces business-specific plaza gameplay beginning with a café. The initial increment needs a distinct visual lot and operating loop that preserves the existing owner profile and server economy.
- **Decision:** Add one persistent fixed Corner Café after warehouse ownership. The business has a `$650` build cost, `$45` restock batches of six coffees, a 24-cup limit and `$18` server-priced coffee sales. Café sales affect the shared fictional cash balance but not supermarket customer/sales progression.
- **Consequences:** Profile schema v29 persists café ownership, remaining coffee stock and lifetime café sales. Existing profiles migrate to no café and zero coffee. Owner/Manager purchase, Stocker restock and Cashier serve actions are server-gated.
- **Verification:** See `docs/operations/PHASE47_CORNER_CAFE.md`; Studio build, transaction, role, migration and save/rejoin checks remain pending.
