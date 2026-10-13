# ADR-0042 — Server-owned online grocery order packing

- **Status:** Accepted — 2026-10-13.
- **Context:** Stage 3 needs an online grocery and delivery preparation loop that reuses the existing server-owned warehouse stock and product prices.
- **Decision:** Generate one deterministic order at a time from a fixed four-order rotation. The server displays the current order on a physical warehouse packing board and fulfills it only between shifts after rechecking every required backroom quantity. Successful packing deducts all items together, credits their current catalog prices and advances one persisted counter.
- **Consequences:** Profile schema v27 adds a bounded fulfilled-order count; older profiles migrate to zero. There is no client-selected SKU, quantity or payout. This first increment has no delivery vehicle, order timer or customer-supplied substitutions.
- **Verification:** See `docs/operations/PHASE44_ONLINE_GROCERY_ORDERS.md`; Studio rotation, transaction, role, migration and save/rejoin checks are pending.
