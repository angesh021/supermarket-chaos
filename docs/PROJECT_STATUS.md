# Project status — 2026-10-12

## Summary
Phase 1 desktop first play and Phase 2 progression/persistence were reported passed by the user. Phase 7 now has its first increment implemented: a server-authoritative, persistent warehouse purchase. The Phase 3–7 increments are awaiting Studio verification. DataStore persistence is hard-limited to development universe `10770581249`; all other universes, including the future production universe, run session-only until explicitly configured.

## Completed and user-verified
- Phase 1 desktop flow: cart, stocking visuals, visible checkout customer, sale, shift close, visible upgrade and compact HUD.
- Phase 2: user reported all requested progression and DataStore test steps passed, including save/rejoin behavior.
- Phase 2 architecture: per-player profile and lease; first player owns the server's single physical store.

## Implemented; Studio verification pending
- Phase 3 membership: a visitor requests to help; owner approves with Manager, Cashier, Stocker or Maintenance, declines, or removes a member. Maximum four players, including the owner.
- Server validates the owner for member management, request frequency, player membership, role IDs, current objective, prompt range, and role permission before allowing an interaction. Helpers contribute to the owner's shift; only the owner's profile is saved.
- Phase 4 employees: $100 cashier and $80 stock clerk, unlocked after shift completion. Both appear in the store; the stock clerk automatically stocks after the cart objective and the cashier automatically serves checkout after four seconds. Both use existing server-side economy transitions.
- Phase 4 customer operations: each shift now serves up to three customers from a visibly bounded queue. The server charges once per checkout using the existing sale transition, and only enables shift close after the third sale. Queue visibility is reconstructed from the saved sales count. Customers are varied procedural blockouts; browsing, navigation, exit behavior and Studio verification remain pending.
- Phase 4 chaos operations: after the first customer sale, a checkout spill pauses the line. The owner/Manager or Maintenance helper can clean it for $5; the existing shift stage persists the event across rejoin. Customer Rush, Power Outage, event timers, and Studio verification are still pending.
- Profile schema v2 adds employee ownership flags and migrates v1 profiles through safe defaults.
- Phase 5 security increment validates saved schema versions as finite bounded integers and avoids exposing store cash/stock/sales to read-only visitors.
- Phase 5 persistence increment serializes writes per profile across gameplay commits, 60-second autosave, player release and shutdown. The new private-Studio contention/recovery checklist is pending; this code has not been runtime-tested.
- Phase 5 analytics increment sends first-shift milestones to Roblox AnalyticsService only in development universe `10770581249`. The API associates events with its required Player argument; the game sends no custom fields or game-owned player IDs. Funnel session IDs stay ephemeral; dashboard ingestion is unverified.
- Phase 6 UI increment uses a collapsed top-center objective card on touch devices, a centered team panel sized to the viewport, and larger role controls. Device emulation is not yet verified.
- Phase 6 visual increment adds recognizable storefront glazing and entry, market fascia/canopy, cart return, two stocked aisle rows, a produce island, chilled-drinks case, retail checkout details and stylized human blockouts. It uses only original procedural Roblox parts. Visual/runtime/mobile review remains pending.
- Phase 7 warehouse increment adds a $200 purchase available at Complete, an exterior annex buildout, and per-player owned-upgrade persistence in profile schema v3. Owner/Manager authorization uses the existing server-side role, prompt-distance and rate-limit checks. Purchase/rejoin behavior is not yet verified in Studio.
- Phase 7 delivery increment adds schema v4 persistent Citrus Pop backstock and an optional $60 order for 24 cans. The shipment is ready after 15 seconds, survives rejoin, and must be collected at the loading dock; stocking consumes three backroom cans. Ordering/receiving is owner/Manager-only, server-priced and range-checked. Studio verification is pending.
- Phase 9 schema v5 accepts the new `Spill` shift stage while keeping the saved event decision server-authored. Existing schema v1–v4 data migrates through defaults and normalization; Studio save/rejoin verification is pending.
- DataStore calls are enabled only when `game.GameId` matches development universe `10770581249`. Other universes display session-only status and never write to that store.

## Studio verification needed (G3–G7)
Use a private development test experience in universe `10770581249`; use two or more test accounts for multiplayer cases:
1. With owner A in a store and player B joined, B opens **TEAM** and requests help. A sees the request.
2. A approves B as Stocker. B can perform Stock while the shift is at Stock; B cannot use Checkout, close the shift, upgrade, or restart. Confirm the owner HUD/profile changes once.
3. Try Cashier, Maintenance and Manager roles against their intended actions; remove one helper and verify prompts no longer work for that player. Try a third helper and confirm a fourth total player is accepted while a fifth is rejected.
4. As owner A, earn at least $180 and hire from both staff boards: **HIRE A STOCKER $80** and **HIRE A CASHIER $100**. Confirm each hire charges once, appears in the store, and remains after leave/rejoin.
5. Start another shift. The owner stops the cart; confirm the stock clerk stocks once and advances the objective. Confirm the cashier then serves once after four seconds and the shift advances. Also test a helper racing each automatic action.
6. In a non-development copy/universe, confirm the HUD reports **SESSION ONLY** and no writes occur against the development profile store.
7. With $200 or more and a completed shift, purchase the warehouse annex. Confirm exact charge, visible construction, and disabled purchase prompt. Try with insufficient funds, helper roles without permission, an unapproved visitor and duplicate/racing interactions; no invalid attempt may charge or build it.
8. Leave and rejoin the development experience; confirm the warehouse remains and is not charged again. In a non-development universe, confirm the session-only fallback.
9. Follow [Phase 5 persistence checks](operations/PHASE5_PERSISTENCE.md) for same-user lease contention, autosave overlap, normal release, shutdown and session-only fallback.
10. Follow [Visual review](operations/VISUAL_REVIEW.md) to inspect the exterior, aisle route, products, produce, refrigerator, checkout and character scale in Studio.
11. Follow [Phase 7 delivery checks](operations/PHASE7_DELIVERY.md) for backstock, order charge, arrival, receipt, low-stock recovery and save/rejoin.

## Toolchain and checks
- Rojo 7.7.0, Selene 0.32.0 and StyLua 2.5.0 are pinned in `rokit.toml`.
- The `rojo`, `selene` and `stylua` launch shims returned `ERROR home directory not found`; invoking the pinned binaries directly from `.rokit/tool-storage` worked. `stylua --check src` passed, `selene src` reported 0 errors/0 warnings/0 parse errors, and `rojo build default.project.json -o %TEMP%\supermarket-chaos.rbxlx` succeeded. `git diff --check` passed with Windows line-ending normalization warnings.
- For the checkout queue and spill increments, `stylua --check src`, `selene src` (0 errors, 0 warnings, 0 parse errors), `rojo build default.project.json -o %TEMP%\\supermarket-chaos.rbxlx`, and `git diff --check` passed on 2026-10-12. Git reported only LF-to-CRLF normalization warnings.
- Roblox Studio runtime and DataStore behavior cannot be exercised from the local shell. Do not mark the new multiplayer, employee, or customer-queue behavior passed until the user confirms Studio results.

## Known limitations
1. One physical store per server; ownership does not transfer when the owner leaves.
2. Membership is server-session only. Helpers must request access again in a new server.
3. Employees are a first automation increment and only auto-serve the introductory stock/checkout stage; they do not simulate a full queue or wages.
4. Mobile layout, multi-server lease failure paths, malicious-client stress, development funnel ingestion and Studio behavior for Phases 3/4 remain unverified.
5. Production universe ID, publishing and commerce are not configured. Development funnel ingestion and Creator Dashboard reporting remain unverified.

## Current gate
**G0:** approved. **G1:** desktop first-shift accepted. **G2:** user reported tests passed. **G3–G7 increments:** implemented; multiplayer, employee, customer queue, spill event, analytics, touch, visual, warehouse and delivery verification pending. **Production:** disabled pending user-provided production universe ID and deployment approval.
