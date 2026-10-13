# Phase 38 — Satisfaction-driven regulars and checkout patience

## Acceptance criteria

- Customer satisfaction of at least 80 adds a deterministic 10% `Neighborhood regular` intent to the weighted basket list, reducing the other weights proportionally so each table still totals 100. Regulars request a two-SKU basket and use the existing price, stock, substitution and checkout rules.
- Below 80 satisfaction, the regular intent disappears and the prior base preference weights return. This uses the existing saved score; no loyalty currency, profile field or paid advantage is added.
- Server checkout wait begins only when the first customer reaches the register queue. An active customer at the front is labeled `GETTING IMPATIENT` after 20 seconds; the label refreshes every five seconds.
- A successful sale applies one satisfaction penalty per completed 20 seconds of front-of-line wait, capped at four. Exact/substitution/unfilled basket scoring and premium price penalties are applied in the same bounded satisfaction update.
- Time spent shopping, during Spill/PowerOutage, or while disconnected does not count. Rejoining reconstructs the queue and starts a fresh wait clock when the next shopper reaches the register.
- The manual checkout and automatic cashier use the same server-owned wait calculation. Wait time cannot be submitted by the client and never changes cash, SKU price, item quantity, stock, sale count, or rush reward.

## Server/client boundary and failure handling

- `Economy.getNextCheckoutBasket` derives the regular intent from the persistent server satisfaction score and the existing deterministic customer draw. It still resolves all SKU availability and price on the server.
- `WorldBuilder` measures queue wait with the server's monotonic clock. `ShiftService` passes that server-derived whole-second value to `Economy.sellProduct`; input is bounded and rejected before state mutation if malformed.
- `Economy.sellProduct` performs SKU deduction, cash credit, sale count, patience/satisfaction adjustment and event progression in the existing server transaction. The HUD and NPC billboard are projections only.
- Patience is intentionally session-local and is not persisted. This prevents offline time or DataStore timestamps from penalizing a rejoining player. Existing schema v23 remains unchanged.
- A player may still complete checkout at any time; impatience causes a bounded satisfaction effect only. Empty baskets and rejected/racing sales do not change score or economy.

## Manual Roblox Studio verification

1. Raise a disposable store to satisfaction 80 or higher. Serve repeated customers across several shifts and confirm the deterministic draw can show `Neighborhood regular` with the two-item request. Drop satisfaction below 80 and confirm the extra intent is removed.
2. At high satisfaction, verify regular baskets use actual stock, price tiers, substitution, route, and one atomic checkout. Test with and without the bakery.
3. Let a shopper reach the front. Confirm the label changes to `GETTING IMPATIENT` at approximately 20 seconds and updates in five-second steps. Confirm no label change while the shopper is browsing.
4. Check out before 20 seconds and confirm no patience penalty. Check out at 20, 40, 80 and above 80 seconds; confirm penalty increments by one each 20 seconds and caps at four.
5. Repeat with an automatic cashier and confirm it uses the same wait penalty. Race a player checkout against the cashier and confirm one sale and one score update.
6. Hold a checkout customer through Spill and PowerOutage; confirm event time does not add to the wait. Clear the event and verify the patience timer starts over for the resumed queue.
7. Leave/rejoin with a customer waiting. Confirm offline time is not charged; the restored shopper starts its patience clock only when it reaches the register.
8. Confirm cash, shelf stock, basket price, sale count and rush reward remain unchanged by waiting; only the bounded satisfaction result changes. Check Owner/Manager HUD readability and visitor privacy.

## Local checks and runtime status

- Pinned StyLua, Selene and Rojo results are recorded in `docs/PROJECT_STATUS.md` after implementation.
- Roblox Studio queue timing, deterministic regulars, cashier parity, event pauses and rejoin behavior remain manual checks; no runtime success is claimed.
