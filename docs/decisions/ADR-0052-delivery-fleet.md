# ADR-0052 — Persistent delivery fleet

- **Status:** Accepted — 2026-10-13.
- **Context:** Stage 5 adds delivery fleets and advanced logistics. Reuse the existing owner warehouse, delivery worker, online order rotation and server-priced stock/payout path.
- **Decision:** Owner/Manager can purchase two trucks for `$3,000` after warehouse ownership and hiring the delivery worker. With worker automation enabled, the fleet permits up to three online orders per completed shift; manual orders use the same capacity.
- **Consequences:** Profile schema v34 stores the bounded per-shift count and safely migrates v33 once-per-shift markers. No new product/pricing authority or separate business balance is added.
- **Verification:** See `docs/operations/PHASE54_DELIVERY_FLEET.md`; Studio purchase, order capacity, toggle, migration and save/rejoin checks remain pending.
