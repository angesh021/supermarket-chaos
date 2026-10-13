# Phase 73 — Shopper hand baskets

Make shopping behavior visible before checkout by giving scripted supermarket customers and plaza visitors a small procedural hand basket with a few generic grocery items. Basket parts are children of the shopper Model, so they follow the same server-controlled character movement and queue routes. These props do not represent a customer's authoritative basket; checkout still derives the actual requested products, stock, prices and totals from `Economy`.

## Acceptance criteria

- Supermarket customers and plaza visitors carry a readable basket while entering, browsing and queuing.
- Basket and contents follow the character as its model moves and turns; they do not collide with players or floor fixtures.
- Cashiers, stockers and other staff do not receive shopper baskets.
- Product requests, stock counts, satisfaction, checkout totals and payouts are unchanged.
- The props use built-in Roblox parts/materials and add no external asset dependency.

## Authority and failure handling

The basket is presentation only. It contains no product IDs, quantity, price, remotes, or state used by the sale transaction. Server-owned `Economy.getNextCheckoutBasket` and `Economy.sellProduct` remain authoritative. If a prop fails to render, the customer's existing route and checkout flow continue.

## Manual Studio verification

1. Start a shift and observe each customer enter, browse, wait in the queue, reach checkout and exit. Confirm the basket stays in front of the customer through turns and movement.
2. Inspect a mixed-product order at checkout. Confirm the basket prop does not replace or alter the displayed server basket, price, stock deduction, cash reward or satisfaction result.
3. Trigger queue reflow and self-checkout. Confirm every moving customer carries their basket and no basket blocks the lane or prompt.
4. Visit the plaza and confirm scripted visitors carry baskets while walking the existing routes.
5. Inspect employees and confirm staff visuals remain unchanged.

No profile migration, client input or external asset is added. Static formatting, lint, Rojo build and diff checks are recorded in `docs/PROJECT_STATUS.md`; Roblox Studio movement, collision, camera and visual checks remain pending.
