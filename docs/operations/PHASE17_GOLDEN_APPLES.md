# Phase 17 Golden Apples verification

Golden Apples extend the produce department into the existing server catalog and warehouse loop. Each restock moves three apples from backstock to a 24-apple display. A delivery costs `$35` and contains 18 apples; only one product shipment can be pending at a time. Checkout values an apple at `$12` from the server catalog. Customer baskets can request apples, and stock-aware fallback keeps checkout serviceable when the preferred product is absent.

Profile schema v11 saves Golden Apples shelf/backroom counts and uses the existing shipment product ID. A warehouse owner migrating from v1–v10 with no Golden Apples field receives six apples in backstock. Profiles without a warehouse receive none. A newly purchased warehouse includes six apples. No external assets are used.

Studio behavior, schema migration, and shipment recovery have not been run locally.

## Acceptance criteria

- A visible Golden Apples shelf and produce prompt appear in the store. Stocking is available only with warehouse ownership and at least three apples in backstock, and is role-gated to Owner, Manager, or Stocker.
- Stocking moves exactly three apples, displays the matching shelf quantity, respects the 24-unit cap, and rejects shortages/full shelves without mutation.
- Owner/Manager can order an 18-apple `$35` shipment from the warehouse. The existing server timer marks it ready, one pending shipment is enforced, and receive applies exactly once to Golden Apples backstock.
- Checkout uses `$12` per apple and atomically consumes the displayed basket quantity. Customer count advances once per basket. Existing spill, outage, rush and reward rules remain based on customers, not item units.
- The HUD distinguishes Citrus/Berry/Apple shelf stock and warehouse counts for store members; visitors do not receive the private inventory counters.
- Save/rejoin restores shelf/backstock counts and any in-flight Golden Apples shipment. Existing shipments retain their SKU and all existing products continue to work.
- Schema v1–v10 profiles migrate safely. Warehouse owners with no Golden Apples field get six; non-warehouse profiles get zero. Invalid IDs, negative/out-of-range stock, and apple inventory without a warehouse are rejected.
- Client requests cannot choose product ID, amount, price, sale quantity or reward. Unauthorized, out-of-range, duplicate, early, full-capacity, or empty-stock attempts do not mutate the profile.

## Server/client boundary and failure handling

`Economy.PRODUCTS` defines Golden Apples, wholesale order price/size, and sale price. `orderDelivery`, `receiveDelivery`, `stockGoldenApples`, and `sellProduct` validate product, stage, stock, capacity and price on the server. `ShiftService` applies the shared owner/role, prompt-range, save-lock and rate checks. `ProfileService` validates schema v11 counts, warehouse ownership and shipment ID before saving. Client HUD fields and world models are presentation only. A failed/expired/invalid action does not consume money or stock; pending shipments retain the existing saved ready timestamp and single-receipt transition.

## Manual Studio checklist

1. In the private development universe `10770581249`, start Rojo and connect Studio at `localhost:34872`. Keep Output visible.
2. Confirm the produce shelf is visible and an owner without a warehouse cannot stock or order Golden Apples.
3. Buy/own the warehouse, stock exactly three apples, and confirm backstock decreases by three and the shelf shows three apples. Repeat until the display reaches 24; confirm another restock is rejected.
4. Order Golden Apples for `$35`. Confirm cash decreases once, the pending shipment blocks other product orders, and the dock identifies 18 apples. Try to receive early; confirm no inventory change.
5. After arrival, receive once and confirm backstock increases by 18. Replay the prompt and confirm no duplicate receipt.
6. Continue a shift with apple stock. Confirm the customer basket label and route show apples, checkout deducts the exact requested count, and earnings use `$12` per apple. Confirm one customer sale is counted even for a multi-item basket.
7. Deplete apples and test a basket preferring apples. Confirm it safely omits unavailable items or falls back to stocked Citrus/Berry. Empty every shelf and confirm checkout fails without changes.
8. Save/rejoin with apples on shelf/backstock and separately with an Apple shipment in transit. Confirm all values/product IDs resume correctly.
9. Test Owner, Manager, Stocker and Cashier permissions, insufficient funds, order races, receive races, full stock cap and save-lock failure behavior.
10. Verify a legacy profile with a warehouse migrates to six apple backstock and a profile without a warehouse migrates to zero. Confirm no Roblox Output errors.
11. Record cash, each SKU shelf/backstock, shipment ID/quantity/deadline, customer sales, role and save status.

## Known limits

- The catalog now has three products and one pending shipment total; suppliers, adjustable order sizes, expiration, spoilage and automated warehouse layouts are not implemented.
- Basket preferences remain deterministic. Apple visual scale, touchscreen prompt layout, migration and DataStore recovery need Studio verification.
