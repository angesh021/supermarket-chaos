# Product requirements — Phase 1 first playable

## Product
**Supermarket Chaos: Retail Empire** is a colorful, cooperative Roblox retail management game. Players personally operate a small neighborhood supermarket, respond to funny disruptions, and visibly improve the store. Tagline: **Start Small. Build Big. Survive the Chaos.**

## Audience and experience
- New Roblox players should understand the next action without a long tutorial.
- Solo play must complete the introductory objectives; cooperative play may assist but cannot bypass ownership or permissions.
- Desktop and touch controls are first-class. Keep UI readable and gameplay unobstructed.
- Long-term progression is earned through enjoyable play. Do not require purchases or coercive daily attendance for core progression.

## Phase 1 scope
Deliver one polished small supermarket and its immediate streetscape; one complete solo-playable shift; stocking, customer interaction, checkout, a manageable chaos event, rewards, one purchasable upgrade, and the “First Shift: Welcome to Chaos” onboarding. Show one visible upgrade in the world. Leave later businesses, logistics, deep employee simulation, and production commerce for later phases.

## Acceptance criteria (design targets; verification pending)
1. A first-time player can identify and complete the runaway-cart objective with concise contextual guidance and an immediate reward.
2. A player can stock a fictional product, serve at least one customer, complete a checkout sale, and receive clear feedback.
3. A complete shift has a start, active play, one chaos event, summary/reward, and a clean end state; solo completion is possible.
4. A first upgrade has server-validated cost and eligibility, visibly changes the store, and gives an understandable confirmation.
5. Invalid, stale, duplicated, unauthorized, or excessive client requests cannot alter authoritative state.
6. Core UI and interactions remain usable at desktop and mobile aspect ratios and with touch input.
7. The small store is visually cohesive and has a readable route from entrance through aisles to checkout and storage.
8. Progression and operations have documented failure handling and a reproducible Studio verification procedure.

## Non-goals for first playable
Multiple business types; regional map; online grocery logistics; employee automation; production monetization; live operations analytics beyond privacy-conscious event definitions; guaranteed revenue outcomes.

## Success measures
Instrument funnel events for first interaction, first stock, first sale, first upgrade, first shift completion and voluntary return. The master specification's completion percentages are hypotheses to validate with actual playtests, not external benchmarks or promises.

## Phase 2 progression requirements
- Each player's currency, current shift, owned store upgrades and progression counters are stored in a versioned profile keyed by Roblox UserId.
- A returning owner resumes the saved shift and sees already-purchased physical upgrades.
- One server session has one store owner. Visitors are read-only until Phase 3 defines explicit guest roles and permissions.
- Profile loading/saving is server-only and uses session ownership; a known lost lock blocks store interactions.
- A DataStore outage may allow session-only play, but the UI must disclose that progress will not persist and the fallback must never overwrite the saved profile.
- Profiles can start another shift after completing the current shift; rewards and upgrades remain server-authoritative.
- G2 is not complete until the save/rejoin, lease conflict, session-only fallback, and shutdown paths are verified in a private Studio test experience.

## Phase 3 cooperative store requirements
- A visitor can request access; only the store owner can approve, decline, or remove a helper.
- A store has at most four active players including its owner. Membership and role grants are server-session scoped.
- The server assigns one of Manager, Cashier, Stocker, or Maintenance and checks role permission, current shift stage, ownership, prompt range and rate limit for every action.
- Helpers act on the owner's shared shift and currency; they do not load or write the owner's profile as their own.
- G3 requires multi-client Studio verification of each role, removal, capacity and rejected remote/event misuse.

## Phase 4 employee requirements (first increment)
- On a completed shift, the owner or authorized manager may purchase a persistent cashier for $100 or stock clerk for $80 in fictional currency.
- The server checks the stage, balance and ownership before taking payment and saving the employee flag.
- A hired cashier is visibly represented in the store and automatically completes a stocked checkout after a short delay using the ordinary sale path exactly once. A hired stock clerk visibly appears and automatically stocks the starting product after the cart stage.
- Profile schema v2 safely defaults legacy profiles to no employees. Saved schema version values must be finite bounded integers; read-only visitors receive no balance, stock or sales values.
- G4 requires Studio verification of both purchases, persistence, automatic actions and races with players/helpers at the same prompts.

## Phase 5 analytics requirements (development increment)
- Track the first-shift funnel through Store Ready, Cart Recovered, Product Stocked, First Sale, First Shift Closed and First Shelf Upgrade.
- Emit funnel steps only in the configured development universe using Roblox AnalyticsService. The API associates events with the required Player argument; do not add custom fields or game-owned player identifiers.
- Analytics failures must not affect gameplay or persistence. Verify event availability in the development Creator Dashboard before using results for decisions.

## Phase 6 touch UI requirements (first increment)
- On touch devices, the objective HUD starts compact and clear of the movement thumbstick; the player can expand it when needed.
- The team panel resizes to the viewport, has an in-panel close control, and lays out role actions into tap-sized rows on narrow screens.
- G6 requires Studio device emulation on phone and tablet sizes, including Roblox core touch controls and safe areas.

## Phase 7 retail expansion requirements (first increment)
- At the completed-shift state, the owner or authorized Manager may buy one warehouse annex for $200 of server-owned fictional currency.
- The server validates stage, ownership/role, proximity, request rate and balance; it deducts once and saves the owned-upgrade flag with the player's profile.
- The purchased annex appears on the reserved exterior plot, and a returning owner sees it without being charged again.
- Legacy profiles default to no warehouse. Other universes remain session-only unless separately configured; production remains disabled.
- G7 requires Studio verification of insufficient funds, unauthorized roles, exact charge, duplicate interaction, visible buildout, save/rejoin and non-development session-only behavior.
