# ADR-0051 — Plaza visitor purchases

- **Status:** Accepted — 2026-10-13.
- **Context:** Shared plaza traffic needs to create measurable business activity while using the same authoritative accounting as manual service.
- **Decision:** On a server-created visitor's browse stop, attempt one business sale using the existing server-owned economy transition for that shop. Apply a 15-second per-business throttle and the common transaction lock.
- **Consequences:** Stock, cash and existing sales counters update through existing profile persistence. No purchase is made for empty stock or an unavailable owner profile. Concurrent triggers may be dropped and retried on a later visit.
- **Verification:** See `docs/operations/PHASE53_PLAZA_CUSTOMER_SALES.md`; Roblox Studio payout, stock, concurrency and persistence checks remain pending.
