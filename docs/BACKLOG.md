# Development backlog

G0 was approved on 2026-10-12. The user authorized continued phase implementation and will provide Studio verification at phase gates.

## Phase 0 — Foundation
- [x] Requirements, design, architecture, security model, traceability, setup and backlog.
- [x] Rojo project mapping, pinned tools, repository and CI structure.

## Phase 1 — First playable
- [x] Procedural supermarket blockout, first-shift objective HUD and server-owned shift flow.
- [x] Cart event, stocking, customer interaction, checkout, shift close and visible upgrade.
- [x] User-verified desktop Play Solo flow and corrected runtime/visibility issues.
- [ ] Verify mobile/device emulation and touch targets.
- [ ] Verify multiplayer interactions after Phase 3 roles exist.

## Phase 2 — Progression and persistence (implemented; G2 user-verified)
- [x] Decide player-owned persistence and server store ownership in ADR-0002.
- [x] Add schema-versioned per-player profiles and UpdateAsync session leases.
- [x] Persist balance, in-progress shift, sales, completed shifts and the shelf upgrade.
- [x] Resume saved shift state and start repeat shifts from the shift board.
- [x] User confirmed the requested Studio progression and persistence tests passed.
- [ ] Extend the upgrade catalog, product inventory and store customization.

## Phase 3 — Cooperative multiplayer
- [x] Join request and owner approval/decline/removal workflow.
- [x] Four-player server cap and server-owned Manager, Cashier, Stocker and Maintenance roles.
- [x] Role-specific prompt authorization; shared shift state and the owner's profile remain authoritative.
- [ ] Multi-client Studio verification.

## Phase 4 — Employees and operations (first employee increment implemented)
- [x] Hire a persistent cashier for $100 after a shift; show the cashier in the store.
- [x] Cashier automatically serves a stocked customer after a short delay; sale uses the existing server economy.
- [x] Hire a persistent stock clerk for $80; the clerk automatically stocks the introductory product after the cart objective.
- [ ] Studio verification of hire, save/rejoin, automatic service and helper permissions.
- [ ] Add further staff roles, automation settings, departments and customization.

## Later phases
- [x] Phase 5 security increment: finite/schema-bounded profile versions, server role checks, bounded remotes, and visitor-state data minimization.
- [x] Phase 5 analytics increment: a first-shift funnel is sent through Roblox AnalyticsService only in the configured development universe, without custom fields or game-owned player IDs (the platform associates events with the required Player argument).
- [ ] Phase 5: broader adversarial security checks, persistence recovery, fair commerce and deeper analytics.
- [x] Phase 5 persistence increment: serialize each player's gameplay/autosave/release DataStore writes; add a manual contention and recovery checklist.
- [ ] Phase 5 manual verification of the save guard, active-session lease, outage fallback and recovery.
- [x] Phase 6 UI increment: touch devices get a collapsed top-center objective card, a centered resizable team panel, and larger role controls.
- [x] Phase 6 visual increment: make the procedural storefront, department layout, produce/refrigeration, checkout, cart return, signage and character silhouettes read clearly as a neighborhood supermarket.
- [ ] Phase 6: device emulation/touch QA, performance review, external beta, staging and release approval.
- [ ] Review the new visual pass in Studio from exterior approach, entrance, aisle and checkout camera positions; refine any collision, sightline or mobile issues.
- [x] Phase 7 first increment: server-authoritative $200 warehouse annex purchase, physical buildout and per-player persistence.
- [ ] Phase 7 follow-up: warehouse inventory, delivery loop, more departments and Studio verification of purchase/save/rejoin.
- [ ] Later phases: broader economy, seasonal/live operations, production commerce and release work remain gated by the specification, Studio validation and explicit release approval.
