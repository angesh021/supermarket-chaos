# ADR-0043 — Delivery worker online order automation

- **Status:** Accepted — 2026-10-13.
- **Context:** The Stage 3 grocery packing loop should support the existing delivery worker without adding a second employee or weakening manual fulfillment controls.
- **Decision:** Extend the delivery worker's optional automation to pack at most one ready online order per completed shift. The worker calls the same server economy transaction as the packing station. Manual packing by the owner/helper suppresses that shift's automatic order when the worker is active.
- **Consequences:** Profile schema v28 persists the last completed-shift number handled by the worker. The existing automation toggle pauses both inbound shipment pickup and online order packing. The employee consumes stock and receives no separate bonus beyond the normal order payout.
- **Verification:** See `docs/operations/PHASE45_DELIVERY_WORKER_ONLINE_ORDERS.md`; Studio timers, pause/resume, player races, migration and save/rejoin remain pending.
