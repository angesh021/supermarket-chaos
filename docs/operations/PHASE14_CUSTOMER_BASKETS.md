# Phase 14 customer baskets verification

Each checkout serves one customer with a small basket. The original two-SKU increment added deterministic preferences and atomic multi-item transactions; later phases extended the patterns to Golden Apples and Sunrise Cereal. Current intents rotate through Citrus Pop, Berry Bites, a Citrus Pop/Sunrise Cereal mix, double Berry Bites, and a Golden Apples/Sunrise Cereal mix. The server resolves intent against current shelf stock, uses catalog prices, and consumes included quantities in one customer sale. If a preferred item is unavailable, it is omitted; if no preferred item can be supplied but another SKU is stocked, the basket falls back to one available item. Empty shelves reject checkout without changing state.

The next basket is derived from saved shift sales and shelf counts. No basket field or customer identity is persisted, and the client cannot choose basket contents, quantity, or price. The customer route visits each represented product department and displays the basket as a presentation cue.

Roblox Studio behavior and persistence reconstruction have not been run locally.

## Acceptance criteria

- The first customer requests one Citrus Pop. The second prefers one Berry Bites; the third requests Citrus Pop and Sunrise Cereal; the fourth requests two Berry Bites; and the fifth requests Golden Apples plus Sunrise Cereal.
- When a requested SKU is out of stock, the server safely reduces the basket or falls back to one stocked SKU. Empty inventory rejects the sale.
- A single successful customer checkout deducts the basket's exact item quantities and credits the sum of server catalog prices exactly once.
- Spill, outage, rush eligibility, sale count, and shift close still count customers rather than individual items. A two-item basket remains one sale/customer.
- The objective HUD and customer model display the next basket; its route visits both product departments for a mixed basket.
- Save/rejoin during a shift reconstructs the same next customer intent from saved sales and uses current saved stock to resolve it.
- Owner, Cashier and authorized Manager checkout paths all use the same transaction. A duplicate, unauthorized, late, or empty-stock attempt does not charge, consume stock, advance the queue, or pay a second reward.
- No new profile field is introduced; existing schema v9 remains compatible.

## Server/client boundary and failure handling

`Economy.getNextCheckoutBasket` deterministically derives customer intent from server shift sales and resolves it from server shelf quantities. `Economy.sellProduct` recomputes that basket immediately before mutation and performs all item deductions and catalog-price credit in the same server transition. No RemoteEvent accepts a product ID, item quantity, basket, price, or customer identity. UI text and NPC routes are presentation only. A no-stock transaction fails before mutation. Existing save-lock, role, proximity, and rate checks remain in force.

## Manual Studio checklist

1. In the private development universe `10770581249`, start Rojo and connect Studio at `localhost:34872`. Keep Output open.
2. Start a shift with Citrus Pop available. Reach checkout and confirm the first customer displays a Citrus Pop basket. Serve once and record cash, shelf stock, sales, and stage.
3. With warehouse inventory available, stock Berry Bites before or during the shift. Confirm the second customer requests Berry Bites when available. Serve it and confirm one pack and `$18` are applied.
4. Continue to the mixed basket. Confirm the shopper visits both departments, the label shows both items, checkout consumes one of each available SKU, and cash increases by the sum of their catalog prices. Confirm it advances one customer only.
5. Restock enough stock for a two-unit Berry basket and the later two-unit Citrus basket. Verify a double basket deducts exactly two units and credits twice the catalog price.
6. Repeat with the preferred product depleted. Confirm an incomplete preference safely becomes a smaller fulfillable basket and the line continues. Empty both shelves and confirm checkout refuses without changing any counter.
7. Save/rejoin before a mixed or double basket. Confirm the same customer intent is reconstructed from sales and the basket resolves against saved shelf stock.
8. Verify Spill, Power Outage and Customer Rush still trigger by customer sale count, not item count. Complete a rush basket and confirm its `$20` reward is paid once.
9. With owner, Cashier and Manager roles, confirm each allowed checkout uses identical basket math. Test unauthorized role, rapid duplicate prompt, and cashier/player race; no basket may be paid twice.
10. Record start/end cash, Citrus/Berry shelf counts, sales, stage, role, displayed basket, and save status. Confirm Output has no errors.

## Known limits

- Basket preferences are deterministic and use five fixed patterns; they are not randomized or influenced by reputation, price, or event mood.
- Products are purchased at their normal catalog prices; there are no discounts, substitutions, taxes, or per-customer patience effects.
- Basket intent is not stored separately. It is reconstructed from the saved customer sale count and current inventory.
