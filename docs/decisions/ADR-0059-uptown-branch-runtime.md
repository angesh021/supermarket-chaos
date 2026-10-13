# ADR-0059 — Add a player-owned Uptown branch runtime

- **Status:** Accepted — 2026-10-13.
- **Context:** The profile can preserve two bounded location snapshots and a shared company wallet, but the live server previously had one store world and one shift runtime.
- **Decision:** After supplier-partnership ownership, allow the profile owner to buy one Uptown Market for `$15,000` between shifts. Create one server-side runtime and world for the `uptown` ID. Keep cash at the company root and keep branch progression/layouts and helper grants in their location runtime.
- **Consequences:** The neighborhood runtime remains the only profile loader, autosave coordinator, telemetry owner, and profile releaser. Branch saves pass through the existing serialized profile writer. Shared remotes include a location selector, which is checked as an untrusted value against each runtime ID; normal authorization remains server-side.
- **Verification:** See `docs/operations/PHASE62_UPTOWN_BRANCH_RUNTIME.md`. Static checks passed; multiplayer Studio travel, save/rejoin, cross-location roles, and concurrent profile-lease checks remain pending.
