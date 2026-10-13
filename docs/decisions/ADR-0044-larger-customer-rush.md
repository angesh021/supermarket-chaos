# ADR-0044 — Expand Customer Rush capacity

- **Status:** Accepted — 2026-10-13.
- **Context:** Stage 3 calls for larger customer events. The existing deterministic Customer Rush provided only two bonus customers and a five-customer maximum.
- **Decision:** Expand the rush by one additional shopper, for three bonus customers and six total. Give players 90 seconds to clear the rush and raise the clear reward proportionally to `$30`. Keep the same server trigger, stock gate, event timer, lane assignment and timeout recovery.
- **Consequences:** Six customer models and queue positions are supported. Profile validation widens the saved sales cap and in-progress rush range; no new profile field or schema bump is needed.
- **Verification:** See `docs/operations/PHASE46_LARGER_CUSTOMER_EVENTS.md`; Studio queue, stock, lane, reward, timeout and save/rejoin checks remain pending.
