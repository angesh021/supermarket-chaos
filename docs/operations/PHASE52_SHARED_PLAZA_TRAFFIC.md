# Phase 52 — Shared plaza traffic

## Acceptance criteria
- At most four server-created visitors appear while at least one plaza business is owned.
- Each visitor routes along the plaza path to an owned business, shows a matching browse label, then exits along the path.
- Unowned businesses are never selected as destinations. With no businesses owned, visitors remain hidden.
- Route movement itself does not change cash, inventory, sales, shift progress or persistence. A later browse point may emit the separately documented Phase 53 purchase event.
- Destroying/rebuilding the world stops the previous visitor loops; the new world has one pool of four, not duplicate groups.

## Server/client boundaries
- `WorldBuilder` creates the fixed procedural visitor pool and derives destinations from server-owned business state.
- Visitors are anchored, non-colliding procedural Parts. Clients receive no spawn, route or economy controls.
- No `Economy` or `ProfileService` transition is invoked by visitor movement.

## Failure handling and limits
- The pool is capped at four models, with fixed destinations, one business stop per visit, and bounded waits between visits.
- Purchase behavior is owned by Phase 53. The route system itself does not select a price, quantity or business transaction.
- If route movement or a model fails, it does not block player prompts, business transactions or supermarket shifts.

## Manual Roblox Studio verification checklist
1. Start with no plaza businesses; confirm no plaza visitors are visible.
2. Purchase the café only; confirm visitors route to the café, show a visit/browse label and exit.
3. Purchase the restaurant and electronics store; confirm the visitor pool remains at four or fewer and uses only owned stores.
4. Purchase Little Sprout; confirm traffic can route to each of the four shops over repeated visits.
5. During visitor routes, check all characters stay on or beside the plaza path, do not pass through walls, and do not block the player at prompts.
6. Confirm economy values change only when a visitor reaches its browse point; verify the resulting purchase separately with the Phase 53 checklist.
7. Stop and restart the server/world; confirm the old visitor group disappears and only one new group runs.
8. Inspect Output and test route visibility at desktop and mobile camera sizes.

## Verification status
- Pinned StyLua 2.5.0 `--check src`, Selene 0.32.0 (`0 errors, 0 warnings, 0 parse errors`), Rojo 7.7.0 build to `%TEMP%\supermarket-chaos-phase52.rbxlx`, and `git diff --check` passed on 2026-10-13. Git emitted only Windows line-ending normalization warnings.
- Roblox Studio visitor routing, ownership gating, collisions, economy isolation and world reset: pending; no runtime success is claimed.
