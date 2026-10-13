# Phase 24 stocker replenishment

The Citrus Pop shelf can now be restocked in later Checkout and Customer Rush stages, and its visible cans are arranged across three shelf levels. A hired, enabled stock clerk still handles the first Citrus Pop stocking step, then checks the next server-derived customer preference after checkout changes. If that preferred shelf is empty and its backroom has a full restock batch, the clerk restocks one SKU. All four products use their existing server-side restock rules; no employee can invent inventory or exceed shelf/backstock limits.

## Acceptance criteria

- Citrus Pop stocks in groups of three up to a 24-can shelf cap. The first stock action advances `Stock` to `Checkout`; later restocks preserve `Checkout` or `CustomerRush`.
- Citrus Pop's prompt is available during initial stocking, Checkout and Customer Rush only when a full batch fits and exists in backstock.
- Profile schema remains v15. Saved Citrus Pop shelf counts above 24 are rejected; valid legacy stock counts and backstock continue to load.
- After the first objective, a hired enabled stocker checks the next server-owned basket intent. It waits four seconds and restocks at most one preferred empty SKU per successful action, using the same `Economy` transaction as player restocking.
- Citrus Pop, Berry Bites, Golden Apples and Sunrise Cereal keep their existing batch sizes, warehouse ownership rules, capacities and stock projections. Unavailable products are skipped; the stocker does nothing if no preferred empty shelf has a complete backstock batch.
- The stocker rechecks hire, automation setting, owner/session readiness, profile lease and unchanged shift stage before acting. A sale, stage change or pause invalidates its scheduled callback.
- All restock prompts are unavailable during Cart, Upgrade, Loading, OwnerOffline, PowerOutage, Spill, CloseShift and Complete stages. Invalid actions leave stock unchanged.

## Server/client boundary and failure handling

`Economy.stockProduct` owns Citrus Pop stage, batch, capacity and backstock transitions. The other three SKU methods enforce their own stage, warehouse, batch and shelf rules. `Economy.stockNextRequestedProduct` resolves only the current server-derived customer intent and delegates to those same transitions. `ShiftService` schedules the employee server-side with generation-token cancellation and lease checks. `ProfileService` validates the new Citrus Pop 24-unit shelf ceiling without adding a schema field. `WorldBuilder` shows the actual counts and exposes only stage-appropriate prompts.

## Manual Studio checklist

1. Start Rojo and connect Studio at `localhost:34872` in development universe `10770581249`; keep Output visible.
2. Complete the cart objective. Confirm the stock prompt moves exactly three cans to the shelf and advances to checkout.
3. After selling enough to empty Citrus Pop, use its prompt during Checkout. Confirm three cans move from backstock to the shelf and the stage does not change.
4. Restock until the shelf reaches 24. Confirm the prompt disables when the next batch would exceed capacity. Sell enough units to make room and confirm it becomes available again if backstock has a full batch.
5. Hire a stocker, enable automation, and pause cashier automation (or leave the cashier unhired). Reach a customer intent whose preferred shelf is empty but has a full backroom batch. Confirm one matching product batch appears after about four seconds and checkout can then serve it. Repeat with each SKU, including preferred Citrus Pop/Cereal mixed demand.
6. Pause the stocker before the delay finishes, or sell/advance the customer first. Confirm the stale callback does not restock. Resume and verify only a later eligible request triggers an action.
7. Verify no auto-restock or manual prompt action occurs during a spill, outage, shift close or complete stage. Check no duplicate inventory on rapid player/employee attempts.
8. Save/rejoin with Citrus Pop on shelf and in backstock. Confirm counts restore and valid schema v15 data loads. Confirm out-of-range saved shelf counts are rejected safely in a disposable test profile.
9. Check Owner, Manager, Stocker, Cashier, Maintenance, visitor and profile-lock cases; confirm unauthorized actions do not mutate stock or cash and Output has no errors.

## Known limits

- The stocker reacts only to an empty preferred shelf with a complete batch available. It does not forecast demand, keep all shelves full, move between shelves, or incur wages.
- Studio prompt, NPC timing, multi-role races, migration and save/rejoin behavior have not been run locally.
