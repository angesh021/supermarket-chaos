# ADR-0050 — Bounded shared plaza visitors

- **Status:** Accepted — 2026-10-13.
- **Context:** Stage 4 calls for shared customer traffic among plaza businesses. Ambient visits should make the plaza active without introducing a second authoritative economy loop before customer transactions are designed.
- **Decision:** Add a server-created pool of at most four procedural visitors. They browse only owned storefronts, use the shared walkway and exit.
- **Consequences:** Visitors are visual-only: they do not alter cash, stock, sales or saved data. The fixed pool bounds instance and movement cost.
- **Verification:** See `docs/operations/PHASE52_SHARED_PLAZA_TRAFFIC.md`; Studio routing, visibility, collision and world-reset checks remain pending.
