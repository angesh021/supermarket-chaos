# Phase 10 — Cleaner employee

## Scope

On a completed shift, the Owner or Manager can hire one Cleaner for $120 of in-game currency. The Cleaner appears near checkout and responds to an active spill after five seconds. It uses the same `Economy.cleanSpill` transition as the Owner, Manager or Maintenance player, so the $5 reward and queue resume happen at most once. The employee flag is stored per player in profile schema v6; older profile versions migrate to `cleaner = false`.

The Cleaner does not clean other hazards, earn passive income, charge wages, or operate when the owner profile is locked. Employee automation remains bounded and event-specific.

## Acceptance criteria

- Only an Owner or Manager may hire during `Complete`. The server charges exactly $120 once and rejects insufficient funds, duplicate purchase, stale stage, visitor or unauthorized helper attempts.
- A hired Cleaner is visible in the world with its procedural uniform/broom and the hiring prompt disables.
- When an active `Spill` occurs, the Cleaner waits five seconds, then runs the same server economy transition as a player. It adds $5 once and returns the shift to Checkout.
- A player cleaning during the delay wins the race; the delayed Cleaner response does not add another reward or change stage.
- The Cleaner does not act while the owner is unavailable, the profile lock is lost/save pending, the employee is not hired, or the spill is not active.
- The Cleaner flag survives save/rejoin. Existing schema v1–v5 profiles load with no Cleaner and are not rejected.

## Server/client boundary and failure handling

- `Economy.hireCleaner` owns stage, price, balance and employee flag. `ShiftService` checks Owner/Manager role, enabled prompt, prompt distance, world ancestry, player state and interaction throttle.
- `ProfileService` validates the optional saved cleaner field as a boolean and writes schema v6. Legacy absence maps to `false`.
- The Cleaner timer lives only in server memory. A server restart during a spill reconstructs the saved spill stage; after load, an already-hired Cleaner is scheduled again. It cannot run without a current owner/save session.
- Manual and automatic cleanup share `Economy.cleanSpill`. Its `Spill` stage check makes duplicate and racing calls non-mutating after the first success.
- Studio runtime, DataStore migration and race behavior remain unverified by local static checks.

## Manual Studio verification

1. With a completed shift and at least $120, hire the Cleaner. Confirm exactly $120 is deducted, its visual/broom appears, and the board prompt disables.
2. Re-trigger the purchase as Owner and try as Manager, Cashier, Stocker, Maintenance and Visitor. Confirm no duplicate charge; only Owner/Manager can purchase.
3. Leave and rejoin the private development universe. Confirm the Cleaner remains hired and no extra charge occurs.
4. Start a shift with the Cleaner hired. After the first sale, confirm the spill appears and checkout pauses for about five seconds; then confirm the Cleaner clears it and awards exactly $5.
5. Race a player cleanup against the five-second timer. Confirm exactly one cleanup succeeds, the balance rises by $5 once, and checkout resumes once.
6. Confirm it does not act during other stages, after owner departure, or when the profile save status blocks interactions.
7. Load a profile created before schema v6. Confirm it loads with no Cleaner; then hire one and verify save/rejoin.
8. In a non-development universe, confirm session-only behavior and no writes to development data.

Record Studio version, account roles, before/after balance, employee visual, event timing, persistence result and Output errors. Do not mark these behaviors passed until observed in Studio.
