# ADR-0037 — Persist a server-defined storefront palette

- **Status:** Accepted — 2026-10-13.
- **Context:** The single fixed refresh preset limited the player's ability to shape the identity of the supermarket, while a free-form client color picker would introduce persistence and validation risks.
- **Decision:** Offer three original, fixed palette IDs. Let Owner/Manager preview them through server-side prompts and save the chosen ID alongside the existing storefront-style ownership flag. Migrate existing purchases without an ID to Coastal Market.
- **Consequences:** Profile schema v24 adds one allow-listed string. Preview state remains session-only; price and ownership continue through the existing server transaction. All players in the server see the same style because the physical store is shared.
- **Verification:** See `docs/operations/PHASE39_STOREFRONT_PALETTE_CHOICES.md`; Studio palette appearance, role, purchase, migration and save/rejoin checks remain pending.
