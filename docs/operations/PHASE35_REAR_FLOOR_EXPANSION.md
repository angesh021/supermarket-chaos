# Phase 35 — Purchasable rear floor expansion

## Acceptance criteria

- At a completed shift, an Owner or Manager who owns the household aisle can purchase the rear wing for `$500` once.
- The purchase opens the existing rear wall with a wide passage and builds a visibly enclosed, lit retail wing attached to the supermarket.
- Expansion ownership and any department shelf positions in the wing persist in player profile schema v22. Profiles before v22 migrate with the wing disabled and keep their existing layout.
- The retail layout editor allows shelves in the new marked zone only after the expansion is owned. Each placement remains snapped, bounded, collision-checked against other shelves and checkout, and server-authoritative.
- Customers browsing a shelf in the wing route through the rear opening before and after browsing; the existing server still owns inventory and checkout.
- Repeated or unauthorized purchase requests do not charge or construct a second wing. Insufficient funds and prerequisite failures do not change ownership or layout.

## Server/client boundary and persistence

- `Economy.buyFloorExpansion` checks completed-shift state, prerequisite ownership, duplicate ownership and balance before charging.
- The interaction prompt uses the existing server role, range, cadence, save-lock, and player-state checks. Only Owner/Manager may purchase or edit the retail layout.
- `ProfileService` stores `ownedUpgrades.floorExpansion`; `RetailLayoutService` accepts the rear shelf zone only when that flag is true. Client zone previews are advisory and cannot grant the expansion.
- Layout records remain compact coordinates and rotations. Roblox instances, cash, and inventory are never accepted from the client.
- The expansion is a fixed allow-listed build and cannot be placed by client-supplied coordinates.

## Manual Roblox Studio verification

1. In development universe `10770581249`, reach a completed shift and purchase the first shelf bay, household aisle, and rear floor wing in order. Confirm the `$500` charge occurs once.
2. Confirm the rear wall opens into a walkable, enclosed, lit extension. Try walking through the passage and along the new floor; confirm no old wall/wainscot blocks the opening.
3. Open the Retail Layout Station. Move and rotate one product shelf into the new rear zone. Try an overlapping shelf location and a position beyond the wing; each should be rejected.
4. Run customers whose basket includes the moved product. Confirm they enter through the opening, browse, return through the opening, queue, and check out.
5. Try buying before the household aisle, with insufficient funds, as a non-Manager helper, outside prompt range, and twice. Confirm no unauthorized or duplicate charge/build.
6. Leave and rejoin. Confirm the wing and rear shelf placement persist. Test a v21 profile with no floor expansion and confirm the old layout remains and rear placement is unavailable.
7. Test shelf editor controls on touch and inspect scale, lighting, collision, and signage from both the original store and new wing.

## Local checks and runtime status

- Pinned StyLua, Selene and Rojo checks are recorded in `docs/PROJECT_STATUS.md` after implementation.
- Studio construction appearance, customer routes, prompt permissions, touch controls, profile migration and DataStore save/rejoin require manual verification; no runtime result is claimed here.
