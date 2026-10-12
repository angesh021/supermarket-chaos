# Phase 5 persistence hardening checks

These checks complement the Phase 2 save/rejoin steps. They validate the Phase 5 save serialization increment and the existing per-player lease. Run only in the private development universe `10770581249` with a test account.

## Manual checklist

- [ ] Start a server with the test account and complete a recognizable state change. Join the same experience from a second server using the same account while the first session is active. The second server must not load a writable copy or permit shift actions.
- [ ] Leave the first server normally, then join a new server. Confirm the latest saved balance, shift stage and owned upgrades load.
- [ ] Wait near the 60-second autosave interval, then perform a permitted purchase or sale while autosave is due. Let the server run through both save paths, leave normally, and rejoin. Confirm the newest balance, stage and upgrade/employee flags remain consistent; an older save must not replace the newer state.
- [ ] Leave while the game is idle and join a new server promptly. Confirm the released profile can be acquired and the state survives.
- [ ] Stop a Studio server with an active profile, then rejoin and confirm the last successfully saved state. Repeat after allowing time for autosave.
- [ ] Disable Studio API access in the private test place and confirm a fresh session reports `SESSION ONLY`, remains playable, and cannot overwrite the persistent profile.
- [ ] If a DataStore error is observed, capture the exact Output message and HUD save status. Confirm interactions stop while status is `save pending` or `lock lost`, then report whether a later autosave recovers.

## Boundaries and limitations

- The game has no developer-facing test hook for injecting arbitrary DataStore failures or malformed profile records. Do not edit live DataStore records to manufacture those cases.
- A successful local check of the save guard does not prove Roblox DataStore ordering or outage recovery. Studio/API-service checks and a review of Creator Dashboard diagnostics are still required.
- Phase 5 commerce and purchase verification are not enabled. No developer products, Robux receipts, production identifiers, or production settings were added.
