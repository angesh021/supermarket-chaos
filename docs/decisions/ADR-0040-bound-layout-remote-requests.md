# ADR-0040 — Bound layout remote request shapes and replies

- **Status:** Accepted — 2026-10-13.
- **Context:** Layout remotes rejected malformed requests before checking their per-player cooldown. A client could therefore trigger repeated rejection replies, and requests accepted unknown top-level fields.
- **Decision:** Apply the existing 0.4-second per-player cooldown before validating either layout payload, silently drop calls during cooldown, and allow only the small action-specific top-level key set.
- **Consequences:** Rejection amplification and needless payload fields are bounded without changing valid layout actions, persistence formats or client authority. The validator checks at most five top-level keys. The existing profile lease and placement rules remain the authority for mutations.
- **Verification:** See `docs/operations/PHASE42_LAYOUT_REMOTE_HARDENING.md`; Studio flood, malformed payload and valid-action checks remain pending.
