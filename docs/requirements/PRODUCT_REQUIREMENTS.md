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
