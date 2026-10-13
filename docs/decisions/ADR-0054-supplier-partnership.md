# ADR-0054: Persistent regional supplier partnership

- **Status:** Accepted.
- **Context:** Stage 5 includes business partnerships. Warehouse purchasing already uses fixed server-side product costs and a bounded delivery transaction.
- **Decision:** After buying the distribution center, the Owner or Manager may pay `$2,500` once for a regional supplier agreement. All inbound product deliveries cost 20% less (rounded down to the nearest whole unit).
- **Consequences:** Profile schema v36 persists the partnership flag. The contract changes delivery cost only; shipment quantities, capacity, arrival times, shelf prices and sale proceeds remain unchanged. The server computes charges and the order prompt mirrors the fixed price.
- **Verification:** See `docs/operations/PHASE56_SUPPLIER_PARTNERSHIP.md`; purchase, all-SKU price, permission, migration and save/rejoin checks remain pending.
- **Assets:** Original procedural pad/signage and built-in materials only; no external asset IDs or third-party code.
