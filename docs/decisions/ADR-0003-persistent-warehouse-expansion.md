# ADR-0003 — Persistent warehouse expansion

- **Status:** Accepted — 2026-10-12.
- **Context:** The user asked to continue beyond the first progression increments. Phase 7 in the master specification calls for a warehouse, but it also says to validate the core game before starting retail empire expansion. The implementation is therefore an early, unverified first increment; it does not claim the core validation gate has passed.
- **Decision:** Add one warehouse annex purchase for $200 fictional currency, available at `Complete`. Only the owner and Manager can invoke it. The server checks stage, balance, prompt distance, rate limit and role, then persists an owned-upgrade flag. The world rebuilds the annex from procedural Roblox parts on purchase and profile load.
- **Alternatives considered:** Delivery automation and inventory were deferred because the warehouse has no verified stock model yet. Restaurant, café, plaza and multiple locations remain future work.
- **Consequences:** Schema v3 adds `ownedUpgrades.warehouse`; older profiles normalize the flag to `false`. Production remains session-only until its universe ID is supplied and configuration is deliberately changed. No external assets or packages are added.
- **Verification:** Private development-universe Studio checks must cover insufficient funds, authorized and unauthorized roles, duplicate/racing purchase, exact cost, visual construction and save/rejoin. The local shell cannot verify Roblox runtime or DataStore behavior. Core-game G3–G6 manual gates remain pending.
