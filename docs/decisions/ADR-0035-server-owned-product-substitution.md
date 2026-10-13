# ADR-0035: Resolve unavailable basket items through server-owned substitutes

- **Status:** Accepted — 2026-10-13.
- **Context:** A shopper's product preference could become a generic fallback or partial basket when a preferred shelf was empty; route selection inferred departments from display text.
- **Decision:** Give each SKU an ordered, allow-listed set of related substitutes. Resolve quantities against live server shelf counts, label substitutions, charge the actual SKU price, and route customers from structured actual item IDs. Adjust the server-owned satisfaction score for substitutions and unfilled units.
- **Consequences:** No schema migration or client authority is added. Basket resolution is deterministic from the next sale, saved shift count, store ownership and live stock. Substitutions do not alter supplier orders or grant inventory.
- **Verification:** See `docs/operations/PHASE37_PRODUCT_SUBSTITUTION.md`; Studio basket, route, race and persistence checks remain pending.
