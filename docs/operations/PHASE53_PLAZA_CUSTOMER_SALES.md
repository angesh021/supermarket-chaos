# Phase 53 — Plaza visitor purchases

## Acceptance criteria
- A server-created visitor may purchase one item only after reaching the browse point at an owned plaza business.
- Café coffee, Garden Bowls, headphones and potted herbs use their existing server-defined prices and sale transitions.
- A successful purchase consumes exactly one stock unit, adds exactly the catalog price to shared owner cash, and increments only that business's sales counter.
- Empty stock, unowned business, owner loading/offline, lost profile lease, pending save or a locked transaction creates no sale/payout.
- At most one automatic sale per business succeeds in any 15-second window. Player, employee and visitor transactions share the existing transaction lock.
- The existing profile fields persist cash, stock and per-business sales; no new schema fields are added.

## Server/client boundaries
- `WorldBuilder` emits a server-only `BindableEvent` after a visitor reaches its selected owned shop.
- `ShiftService` validates the event payload against four fixed IDs, owner/profile readiness, lease/save status, cooldown and shared lock.
- `Economy` performs the same fixed-price stock-consuming transition used by manual service. No client supplies product, price, quantity or sale result.

## Failure handling and limits
- A failed transition has no state change. Visitors retry on a later route; no unpaid sales or negative stock are created.
- Concurrent event arrivals may be dropped while a transaction saves. The per-business throttle applies only after a successful sale.
- The visitor purchases one item per shop visit; baskets, preferences, satisfaction, queues and visitor-initiated delivery are not included.

## Manual Roblox Studio verification checklist
1. Open each plaza business and stock it. Note cash, each stock count and business sales count.
2. Observe visitors reach each owned storefront. Confirm a successful browse can consume exactly one matching item and credit its exact configured price.
3. Confirm only that business's sales count changes; supermarket customer/shift progress remains unchanged.
4. Leave a shop empty and observe multiple visits; confirm cash and sales do not change and stock never goes below zero.
5. Trigger player service and a visitor browse at nearly the same time; confirm no duplicate sale or lost balance update.
6. Confirm repeated same-business visits cannot produce more than one automatic sale in 15 seconds.
7. Observe while profile is loading, offline or save-pending; confirm no sale occurs until the owner profile is available.
8. Save and rejoin; confirm visitor sales, cash and remaining stock persist for all plaza businesses.
9. Inspect Output and confirm visitor movement remains bounded with four visitors and no more than one group after world reset.

## Verification status
- Pinned StyLua 2.5.0 `--check src`, Selene 0.32.0 (`0 errors, 0 warnings, 0 parse errors`), Rojo 7.7.0 build to `%TEMP%\supermarket-chaos-phase53.rbxlx`, and `git diff --check` passed on 2026-10-13.
- Roblox Studio purchases, exact payouts, empty-stock handling, concurrency and save/rejoin: pending; no runtime success is claimed.
