# Phase 61 — Shared company wallet foundation

## Acceptance criteria
- Each loaded player profile owns one server-side wallet initialized from the saved root balance.
- `Economy.newState` can bind its `cash` property to that wallet. Cash reads/writes from multiple location states using that wallet resolve to one balance.
- The existing neighborhood ShiftService binds its state to the profile wallet without changing current price, reward or payroll rules.
- Profile saves persist the wallet value at the company root while location snapshots continue to contain no cash field.
- Profile mutation serialization covers both the in-memory profile projection and the DataStore write, so two location saves cannot overwrite each other's snapshots.
- This phase added infrastructure only; Phase 62 adds branch purchase/activation and binds Uptown to the same wallet.

## Server/client boundaries and failure handling
- The wallet reference is returned only by server-only `ProfileService`; no RemoteEvent accepts cash or wallet references.
- Economy methods continue to own all charges and credits. A location runtime must obtain the server wallet and must not create its own balance copy.
- Each sale/economy action updates the shared wallet before persistence. Save failure continues to use the existing `save pending` / `lock lost` status behavior and does not create a second DataStore writer.
- The profile mutation lock serializes updates for all locations. Runtime transaction locks remain necessary for per-location inventory and customer state.

## Manual Studio checklist
1. In the private development experience, run the existing first-shift purchase, sale and closeout flow. Confirm every displayed cash amount tracks the server transaction.
2. Leave and rejoin. Confirm the root balance matches the final HUD and the neighborhood snapshot contains no cash field.
3. Verify autosave/release contention using the existing persistence checklist. Confirm the saved balance is not rolled back by a later location snapshot write.
4. Verify branch transactions using the Phase 62 checklist once the Studio gate is scheduled.

## Verification status
- StyLua 2.5.0 `--check src`, Selene 0.32.0 (0 errors, 0 warnings, 0 parse errors), Rojo 7.7.0 build to `%TEMP%\supermarket-chaos-phase61.rbxlx`, and `git diff --check` passed on 2026-10-13.
- Studio wallet/display/persistence behavior remains pending. No second location behavior is claimed.
