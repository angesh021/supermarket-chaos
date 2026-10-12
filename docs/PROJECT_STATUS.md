# Project status — 2026-10-12

## Summary
Phase 1 desktop first play and Phase 2 progression/persistence were reported passed by the user. Phases 3 and 4 first increments are implemented locally and are awaiting Studio verification. DataStore persistence is hard-limited to development universe `10770581249`; all other universes, including the future production universe, run session-only until explicitly configured.

## Completed and user-verified
- Phase 1 desktop flow: cart, stocking visuals, visible checkout customer, sale, shift close, visible upgrade and compact HUD.
- Phase 2: user reported all requested progression and DataStore test steps passed, including save/rejoin behavior.
- Phase 2 architecture: per-player profile and lease; first player owns the server's single physical store.

## Implemented; Studio verification pending
- Phase 3 membership: a visitor requests to help; owner approves with Manager, Cashier, Stocker or Maintenance, declines, or removes a member. Maximum four players, including the owner.
- Server validates the owner for member management, request frequency, player membership, role IDs, current objective, prompt range, and role permission before allowing an interaction. Helpers contribute to the owner's shift; only the owner's profile is saved.
- Phase 4 employees: $100 cashier and $80 stock clerk, unlocked after shift completion. Both appear in the store; the stock clerk automatically stocks after the cart objective and the cashier automatically serves checkout after four seconds. Both use existing server-side economy transitions.
- Profile schema v2 adds employee ownership flags and migrates v1 profiles through safe defaults.
- Phase 5 security increment validates saved schema versions as finite bounded integers and avoids exposing store cash/stock/sales to read-only visitors.
- DataStore calls are enabled only when `game.GameId` matches development universe `10770581249`. Other universes display session-only status and never write to that store.

## Studio verification needed (G3/G4)
Use a private development test experience in universe `10770581249` and two or more test accounts:
1. With owner A in a store and player B joined, B opens **TEAM** and requests help. A sees the request.
2. A approves B as Stocker. B can perform Stock while the shift is at Stock; B cannot use Checkout, close the shift, upgrade, or restart. Confirm the owner HUD/profile changes once.
3. Try Cashier, Maintenance and Manager roles against their intended actions; remove one helper and verify prompts no longer work for that player. Try a third helper and confirm a fourth total player is accepted while a fifth is rejected.
4. As owner A, earn at least $180 and hire from both staff boards: **HIRE A STOCKER $80** and **HIRE A CASHIER $100**. Confirm each hire charges once, appears in the store, and remains after leave/rejoin.
5. Start another shift. The owner stops the cart; confirm the stock clerk stocks once and advances the objective. Confirm the cashier then serves once after four seconds and the shift advances. Also test a helper racing each automatic action.
6. In a non-development copy/universe, confirm the HUD reports **SESSION ONLY** and no writes occur against the development profile store.

## Toolchain and checks
- Rojo 7.7.0, Selene 0.32.0 and StyLua 2.5.0 are pinned in `rokit.toml`.
- Current environment attempts to launch these executables returned `ERROR home directory not found` because `HOME` is not set in the shell. `git diff --check` was run; it reported only Windows line-ending normalization warnings.
- Roblox Studio runtime and DataStore behavior cannot be exercised from the local shell. Do not mark the new multiplayer or employee behavior passed until the user confirms Studio results.

## Known limitations
1. One physical store per server; ownership does not transfer when the owner leaves.
2. Membership is server-session only. Helpers must request access again in a new server.
3. Employees are a first automation increment and only auto-serve the introductory stock/checkout stage; they do not simulate a full queue or wages.
4. Mobile layout, multi-server lease failure paths, malicious-client stress, and Studio behavior for Phases 3/4 remain unverified.
5. Production universe ID, publishing, commerce, and live analytics are not configured.

## Current gate
**G0:** approved. **G1:** desktop first-shift accepted. **G2:** user reported tests passed. **G3/G4 and Phase 5 security increment:** implemented; Studio verification pending. **Production:** disabled pending user-provided production universe ID and deployment approval.
