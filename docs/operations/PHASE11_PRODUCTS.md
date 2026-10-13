# Phase 11 multi-product retail verification

This increment adds Berry Bites as a second independently stocked SKU alongside Citrus Pop. Run the checklist in the private development universe `10770581249`. No Studio/runtime test has been run locally; leave the gate open until these observations are made.

## Acceptance criteria

- The store displays a distinct Berry Bites gondola and visible packs appear/disappear with server inventory changes.
- Citrus Pop and Berry Bites have separate shelf and backroom quantities. The HUD labels Citrus / Berry counts separately.
- A checkout sale selects its SKU on the server and credits the catalog price: Citrus Pop `$25`, Berry Bites `$18`. The client cannot submit a product ID or price.
- Berry Bites stocking moves four packs from backroom to shelf, requires the warehouse, and cannot exceed the 24-pack shelf limit.
- The warehouse permits at most one pending shipment; Citrus Pop costs `$60` for 24 cans and Berry Bites costs `$45` for 24 packs. Receipt is due after 15 seconds and can be applied once.
- Schema v7 migrates prior profiles: missing Berry Bites shelf stock becomes zero; a previously owned warehouse receives 12 initial Berry Bites backstock; pending older shipments default to Citrus Pop.
- Visitors do not receive private counts. Owner/Manager can order products; Stocker can stock Berry Bites; other roles cannot use those actions.

## Studio checklist

1. Pull the latest `main`, run `rojo serve default.project.json`, connect the Studio Rojo plugin to `localhost:34872`, and start a private server in universe `10770581249`.
2. On a profile without a warehouse, confirm Berry Bites has a visible department shelf but its stocking prompt is disabled. Confirm Citrus Pop's existing first-shift loop still works.
3. Complete the shift and buy the warehouse. Confirm the HUD shows separate Citrus and Berry backroom counts, including 12 Berry Bites on an old/migrated warehouse profile.
4. Stock Berry Bites. Confirm four packs visibly appear, Berry backstock decreases by four, and Citrus quantities do not change. Fill to 24 and confirm another restock is rejected without changing either count.
5. Serve the next customer after the first sale. Confirm the customer browses the Berry Bites shelf and the server credits `$18` for that sale. Confirm Citrus sales credit `$25`. Check output and HUD for matching SKU/price feedback.
6. With less than `$45`, try a Berry Bites order; confirm no charge or shipment. With enough cash, order it and confirm the `$45` charge, single pending shipment, and no early receive prompt.
7. Try to order Citrus Pop while the Berry Bites shipment is pending. Confirm the second order is rejected and the original shipment remains intact. Wait 15 seconds, receive the shipment once, and confirm exactly 24 Berry Bites are added to backstock.
8. Repeat for Citrus Pop and confirm it costs `$60` and adds 24 cans. Rejoin before arrival and after arrival-before-receipt to confirm the product ID and shipment state persist correctly.
9. With two accounts, approve one as Stocker and confirm they can stock Berry Bites; confirm they cannot order a delivery. Approve a Manager and confirm they can order either SKU. Cashier, Maintenance, unapproved Visitor, and out-of-range players must not perform unauthorized warehouse actions.
10. Race an order/receive/restock action with two players or rapid prompt input. Confirm each accepted action updates once and rejected repeats do not change cash or counts.
11. Confirm read-only visitors see no store balance or inventory counts. In a non-development universe, confirm session-only mode and no writes to the development DataStore.
12. Check Studio Output for errors, then report the exact step, role, starting balance/counts, observed result, and any output text for failures.

## Trust and failure handling

The server owns product selection, catalog prices, role authorization, proximity, request cooldown, stock quantities, capacity limits, shipment timing and save data. Prompts communicate intent only. Each SKU uses separate saved counters; one pending shipment prevents supplier duplication, and receipt clears that shipment in the same state transition that adds inventory. Insufficient funds, missing warehouse, full shelf/backroom, early receipt, unauthorized role, out-of-range prompt, duplicate order/receipt, or invalid saved counters must leave currency and inventory unchanged. Roblox Studio animation, DataStore behavior, and multiplayer races remain runtime verification items.
