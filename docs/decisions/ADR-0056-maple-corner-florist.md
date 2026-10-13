# ADR-0056: Add Maple Corner Florist

- **Status:** Accepted; implementation complete, Studio verification pending.
- **Context:** The commercial district contains two adjacent storefronts that read as neighborhood shops but had no player-owned business behavior.
- **Decision:** Unlock the florist after Little Sprout Garden. Charge $1,500 to open it; restock four bouquets for $320 (12-item cap) and sell each for $240. Reuse server prompt authorization and visitor-sale handling.
- **Consequences:** Profile schema v38 persists florist ownership, stock and sales. A v37 migration defaults those fields and validates the legacy `locations.neighborhood` snapshot with the new fields omitted. This remains a single neighborhood store and does not complete multi-store runtime.
- **Verification:** See `docs/operations/PHASE59_MAPLE_CORNER_FLORIST.md`.
