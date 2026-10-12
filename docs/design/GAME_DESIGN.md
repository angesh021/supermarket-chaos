# Game Design Document

## Pillars
1. **Hands-on retail:** players stock, serve, scan and recover from operational problems.
2. **Visible ownership:** upgrades change the physical store and communicate progress.
3. **Friendly chaos:** short, readable, recoverable disruptions create stories rather than punishment.
4. **Cooperation with clear authority:** friends help, while the server enforces ownership and action permissions.

## Core loop
Prepare stock → open a shift → attract and serve customers → respond to a chaos event → close and collect a summary → spend earned currency on a visible improvement → start another shift.

## First milestone loop
The opening cart challenge introduces movement and interaction. Stock one product, help a customer, and scan items at one checkout. A small rush escalates into one chaos event. Close the shift, receive a clear earnings breakdown, and buy one upgrade such as an additional shelf bay. Continue play is available without waiting for a timer.

## First progression
Start: compact shop, limited product set, one staffed checkout. Earned currency funds a first capacity/quality improvement. Store expansion should be an understandable addition to existing architecture. Stage 2 departments and employees remain future progression, not Phase 1 scope.

## Chaos event rules
Each event has a readable warning, a simple objective, bounded duration, safe recovery, and a positive end-state summary. First event: a runaway cart reaches the entrance area; players stop/return it. No damage, currency loss, forced purchase, or irreversible state. Event selection and outcome are server-authoritative; animation and reactions may be client presentation.

## Customer behavior (initial design)
Small server-bounded population; state progression from arrival to browse, queue, purchase, exit. Navigation targets are authored and simple for first playable. Avoid unbounded pathfinding and event churn. Customers must not block the main accessible route.

## Multiplayer and roles
First-shift tasks are completable solo. Cooperative help is allowed through the same validated action rules. The ownership/permission model must be defined before shared construction or economy actions; no trusting client-supplied player/store IDs.

## UX and accessibility
One highlighted next action; concise text with an icon/shape cue; never communicate critical state by color alone; scalable touch targets; brief, optional-to-reduce effects; clear audio and visual confirmation. Tutorial can be skipped or resumed without corrupting shift state.

## Future stages
Neighborhood supermarket → mega supermarket → shopping plaza → retail empire. Add only after the core loop is validated; reuse catalog, inventory, transactions, upgrade, permission, and persistence concepts where they fit.
