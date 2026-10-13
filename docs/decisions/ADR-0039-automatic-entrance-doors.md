# ADR-0039 — Animate automatic entrance doors

- **Status:** Accepted — 2026-10-13.
- **Context:** The store already had permanently open glass door panels. They looked like a storefront detail but did not behave like the automatic entrance described in the environment specification.
- **Decision:** Add server-built, non-collidable sliding panels, a local touch sensor for player characters, and explicit open signals on scripted customer entry/exit. Use fixed tweens and a generation counter to prevent stale timers from closing a newly reopened door.
- **Consequences:** No profile migration, gameplay remote, economy transition, asset dependency or new permission is added. The doors are shared visual state and fail open for movement because panels never collide.
- **Verification:** See `docs/operations/PHASE41_AUTOMATIC_ENTRANCE_DOORS.md`; Studio visual and touch behavior remain pending.
