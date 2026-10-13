# Phase 62 — Uptown branch runtime

## Acceptance criteria

- After buying the supplier partnership, completing a shift, and holding `$15,000`, the owner can open Uptown Market from the gold pad.
- The purchase creates one server-approved `uptown` location under the existing profile lease. The purchase charge and location snapshot are saved together through the serialized profile writer.
- Uptown runs an independent world, shift, customer queue, inventory, upgrades, layouts, and per-location helper roles. The company wallet is shared with the neighborhood store.
- The owner can travel between the two stores. The active location is selected by the server and is included in snapshots and layout/membership responses.
- A helper's grant in one location does not authorize actions in the other location. Layout and membership requests are ignored unless their location selector matches the receiving runtime; normal server role, prompt, distance, rate, and state checks still apply.
- Rejoining with an existing Uptown snapshot restores its runtime. Opening or saving Uptown does not reload or release the owner profile a second time.

## Server/client boundaries and failure handling

- `Economy.buyUptownStore` owns the `$15,000` charge and enforces the supplier-partnership, completed-shift, and one-time purchase requirements. The prompt is server-enabled only when these requirements are met.
- `ProfileService.createLocation` creates the in-memory location snapshot; the purchase then commits the new location and wallet deduction together with `saveProgress`. If location creation fails, the server refunds the in-memory charge. DataStore errors continue to use the existing save-status handling.
- `BranchRuntimeService` creates at most one Uptown `ShiftService` runtime per owner per server. The owner profile is loaded and released only by the neighborhood runtime. Uptown reads a defensive location copy and commits through the same profile mutation lock.
- Each runtime owns its world, shift state, action cooldowns, and membership tables. The shared RemoteEvents carry a location selector for membership and layout operations; that selector is untrusted and is checked against the server runtime ID.
- `ActiveStoreLocation` is set by the server on travel. It selects the state stream and client presentation; it does not grant store authority. Every economy interaction still checks server-owned membership and role.
- Analytics funnels remain attached to the neighborhood tutorial only. The Uptown runtime does not create a second profile session or emit duplicate onboarding events.

## Manual Studio checklist

1. In the private development experience, complete the supplier partnership prerequisites. Confirm the gold pad is unavailable before the partnership and during an active shift.
2. With less than `$15,000`, interact with the pad and confirm no charge. With enough cash between shifts, buy Uptown Market and confirm exactly `$15,000` is deducted once.
3. Use the pad to travel to Uptown. Confirm the second supermarket appears at the separate plot, the HUD follows the active location, and the travel pad returns to the neighborhood.
4. Complete a shift and change shelf/backstock or a saved layout in each location. Confirm those values and shift progress remain independent while cash is shared.
5. Open Team in each location. Grant a helper access in only one location. Confirm they can perform an allowed action there but are denied owner-only actions and have no role in the other branch until separately approved.
6. Exercise warehouse and retail layout requests in both locations. Confirm each response updates only the active location and stale/wrong-location requests do not change either layout.
7. Leave and rejoin. Confirm the branch purchase, both locations' progression/inventory/layout, and shared balance restore. Open the second server for the same owner and confirm the existing profile lease still prevents concurrent ownership.
8. Repeat the purchase prompt rapidly and attempt it with another player. Confirm the branch is created once and only the profile owner can pay for it.

## Verification status

- StyLua 2.5.0 formatting, Selene 0.32.0, Rojo 7.7.0 project build, and `git diff --check` passed on 2026-10-13.
- Roblox Studio multiplayer, travel, purchase, persistence, and cross-location permission checks have not been run. Do not treat the branch as runtime-verified until the checklist is completed.
- Production publishing and production DataStore access remain disabled.
