# Phase 21 Sunrise Cereal department

The existing cereal fixture is now a functional fourth SKU, Sunrise Cereal. It sells for `$16` per box, ships 18 units for `$45`, stocks in groups of three, and has a 24-box shelf limit. A new warehouse includes six cereal boxes in backstock; existing warehouse profiles migrating from schemas v1–v13 receive the same bounded six-box starting allocation when the field is absent. Cereal joins deterministic customer baskets, with server-priced atomic checkout and visible shelf stock.

Profile schema v14 persists cereal shelf/backroom quantities and accepts `sunriseCereal` in the existing single-shipment slot. No external assets are used.

## Acceptance criteria

- A labeled Sunrise Cereal department appears on the pantry aisle shelf. Stocking is available only with warehouse ownership, at least three boxes in backstock, an eligible shift state, and Owner/Manager/Stocker authorization.
- Stocking transfers exactly three boxes to the shelf, shows the matching package count, respects the 24-box cap, and rejects shortages/full shelves without mutation.
- Owner/Manager can order 18 boxes for `$45` through the single-shipment warehouse board. The delivery worker or manual dock action receives it once into cereal backstock.
- Checkout may request Sunrise Cereal alone or in a mixed basket. It consumes the exact available cereal quantity and credits `$16` per box within the same server transaction; a customer basket still counts as one sale.
- Customer routing visits the cereal department when the displayed basket includes cereal. Out-of-stock cereal is omitted and other stocked basket items can still be served.
- The HUD distinguishes shelf and backroom stock for Citrus, Berry, Apples, and Cereal. Read-only visitors do not receive private counts.
- Save/rejoin restores cereal counts and a pending cereal shipment. Schemas v1–v13 migrate safely; warehouse profiles without a cereal field receive six backstock boxes, while non-warehouse profiles receive zero.
- Invalid SKU IDs, negative/out-of-range counters, cereal inventory without a warehouse, unauthorized actions, duplicate/early receipt, request races and profile-lock failure cannot change cash or inventory.

## Server/client boundary and failure handling

`Economy.PRODUCTS.sunriseCereal` defines price and shipment size. Stocking, ordering, receipt and sale transitions use server-owned IDs, prices, quantities, limits and current stage. `ShiftService` enforces action role, prompt range, cooldown, owner readiness and profile lease. `ProfileService` validates schema v14 counters, warehouse ownership and the shipment SKU; older warehouse profiles normalize the new backstock safely. HUD, shelf products, department signage, customer labels and routes are projections only. The delivery worker calls the same `Economy.receiveDelivery` transaction as the manual dock prompt.

## Manual Studio checklist

1. In the private development universe `10770581249`, start Rojo and connect Studio at `localhost:34872`. Keep Output visible.
2. Confirm the pantry aisle has a Sunrise Cereal sign and the shelf has visible generic package facings. Without a warehouse, verify its stock and order prompts are unavailable.
3. Buy a warehouse. Confirm the HUD shows six cereal boxes in backstock. Stock three and confirm the shelf shows three boxes and backstock drops by three. Restock to 24; confirm another restock is rejected.
4. Order Sunrise Cereal for `$45`. Confirm cash changes once, the single-shipment rule blocks other orders, and the dock identifies 18 boxes. Test early receipt, then receive manually or with an active delivery worker and verify exactly 18 boxes arrive once.
5. Continue a shift with cereal stocked. When the basket requests cereal, confirm the customer route visits the cereal aisle, the customer label matches the basket, the exact requested boxes are consumed, and cash rises by `$16` per box. Confirm a mixed basket counts as one customer sale.
6. Deplete cereal and test a mixed basket. Confirm available items still sell safely; empty all shelves and confirm checkout fails without mutation.
7. Save/rejoin with cereal on the shelf/backroom and separately with a cereal shipment in transit. Confirm counts, shipment product ID and delivery-worker behavior restore correctly.
8. Check Owner, Manager, Stocker, Cashier, Maintenance, visitor, insufficient funds, shelf cap, backroom cap, order/receipt races, duplicate prompts and save-lock failure.
9. Verify legacy warehouse migration grants six cereal boxes only when the cereal field is absent, and non-warehouse profiles receive none. Confirm no Output errors and record cash, four SKU counts, shipment, basket, sale count, role and save status.

## Known limits

- Prices, customer preferences and the 18-unit shipment are fixed; supplier choice, discounts, expiry, spoilage, adjustable pack sizes and richer cereal variants are not included.
- Studio visual, migration, basket, delivery-worker race and DataStore behavior have not been run locally.
