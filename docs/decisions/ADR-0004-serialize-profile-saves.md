# ADR-0004 — Serialize profile saves per player

- **Status:** Accepted — 2026-10-12.
- **Context:** Profile saves can begin from gameplay commits, the periodic autosave, player removal, or server shutdown. Concurrent `UpdateAsync` calls for one in-memory profile make ordering harder to reason about and can contend over the same lease.
- **Decision:** Use a per-profile in-memory save guard. Each save waits for an active save to finish, then rechecks persistence and lock status before issuing its own DataStore update. A player release therefore waits behind an active save and releases the lease only after its own final save attempt.
- **Consequences:** Saves for different players remain independent. A failed save still reports `save pending`; the next autosave can retry. This does not make DataStore outages recoverable by itself or certify the lease protocol.
- **Verification:** In a private development experience, test save/rejoin, two-server contention, an action near the autosave interval, owner leave during normal operation, and Studio shutdown. Do not inject malformed records into real player data. Roblox runtime behavior remains unverified until these steps are run.
