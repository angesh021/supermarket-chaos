# ADR-0036: Derive customer regulars and patience from satisfaction and queue time

- **Status:** Accepted — 2026-10-13.
- **Context:** Customer satisfaction was persistent feedback only; there was no loyalty or patience effect in customer preferences.
- **Decision:** At satisfaction 80+, add a deterministic 10% two-SKU Neighborhood regular preference. Measure patience only while the next customer is at checkout using the server monotonic clock, show an impatience label after 20 seconds, and subtract one satisfaction point per 20 seconds (maximum four) on a successful sale. Pause the clock during operational events and reset it on rejoin.
- **Consequences:** No new persistence field or monetization is introduced. High satisfaction increases varied basket demand; slow checkout affects satisfaction only, not cash, inventory, customer count or rewards. The automatic cashier shares the same rule.
- **Verification:** See `docs/operations/PHASE38_LOYALTY_AND_PATIENCE.md`; Studio queue timing, repeat intent, event pause and rejoin checks remain pending.
