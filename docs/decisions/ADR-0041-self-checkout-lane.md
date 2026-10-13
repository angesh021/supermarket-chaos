# ADR-0041 — Add a server-owned self-checkout lane

- **Status:** Accepted — 2026-10-13.
- **Context:** The master specification names self-checkout as a Stage 3 system. The existing store had one movable staffed register and one shared atomic sale transition.
- **Decision:** Add a persistent `$300` second terminal after rear-wing and warehouse ownership. Keep it in the movable checkout fixture, assign customers to the two lanes deterministically by server customer index, enable only the active lane prompt, and route both through the existing `Economy.sellProduct` transaction.
- **Consequences:** Profile schema v26 stores only a boolean ownership flag; older profiles migrate to unowned. Existing catalog, price, stock, satisfaction and sale logic stays authoritative. A shared sale lock spans profile save and queue refresh to prevent simultaneous prompts or employee automation from serving one visible customer twice. The rear wing and warehouse are prerequisites to avoid an early-game operational shortcut.
- **Verification:** See `docs/operations/PHASE43_SELF_CHECKOUT.md`; Studio lane routing, transaction race, checkout move/rotation, multiplayer and migration checks remain pending.
