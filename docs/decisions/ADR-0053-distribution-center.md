# ADR-0053: Persistent regional distribution center

- **Status:** Accepted.
- **Context:** The warehouse backstock limit is 500 units per SKU. Later logistics progression needs a durable capacity upgrade that reuses the existing supplier shipment path.
- **Decision:** After delivery-fleet ownership, allow the Owner or Manager to purchase a regional distribution center for `$6,000`. Each SKU's backstock maximum becomes 1,000 units. Existing delivery costs, order sizes, arrival delay and product catalog remain fixed.
- **Consequences:** Profile schema v35 persists facility ownership and permits the larger per-SKU inventory bound only when owned. Both order placement and shipment receipt consult one server-derived capacity function. A pending shipment still cannot exceed capacity when received.
- **Verification:** See `docs/operations/PHASE55_DISTRIBUTION_CENTER.md`; Studio purchase, capacity-boundary, migration and save/rejoin checks are pending.
- **Assets:** Original Roblox Parts and built-in materials only; no external asset IDs or third-party code.
