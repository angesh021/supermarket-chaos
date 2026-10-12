# ADR-0002 — Player-owned store profiles

- **Status:** Accepted — 2026-10-12, selected by the user.
- **Context:** Phase 2 adds persistent balances, shift recovery, upgrades and customization. Those records need one unambiguous owner before multiplayer permissions are added.
- **Decision:** Each Roblox user owns a separate profile keyed by UserId. The first player to join a server owns that server's one physical store. Other players can view it but cannot change its state in Phase 2. Cooperative roles and invited helpers are deferred to Phase 3.
- **Profile contents:** Schema version, integer balance, in-progress shift state, owned upgrade identifiers, completed shift count and lifetime sales. Roblox DataStore is the persistence adapter; a server lease is stored with the profile and refreshed during saves.
- **Alternatives considered:** One shared friend-group profile (requires group ownership, invitations, and permissions first); a shared server balance (cannot persist safely across unrelated servers).
- **Consequences:** Solo play and per-player saves have clear ownership. A server can host one active store owner; visitors are read-only, and ownership is not transferred mid-server. If DataStore access is unavailable, Studio play remains session-only and the HUD reports that status. A lost session lock stops authoritative interactions.
- **Verification:** Studio DataStore API access, save/rejoin, active-session conflict, save failure, shutdown, and migration checks are required before G2. Do not enable this against production player data during development; use a private test experience.
