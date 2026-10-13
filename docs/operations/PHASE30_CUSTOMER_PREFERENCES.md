# Phase 30 customer shopping preferences

## Scope

Customers draw one of four weighted preference profiles: Everyday (40%), Value shopper (25%), Family shop (20%), and Treat stop (15%). The draw is deterministic from the owner profile's completed-shift count and the next server sale number, so a reconnect reconstructs the same next preference. The customer billboard displays the preference and basket while browsing.

This is a reproducible weighted sampler, not runtime randomness. Its purpose is to make the short shift varied while keeping the next basket stable across rejoin. Preferences only choose catalog product IDs; server stock, price tier, and checkout code determine the fulfillable basket and final charge. If preferred stock is unavailable, the existing fallback basket rules apply.

## Server/client boundary and failure handling

- `Economy.getNextCheckoutBasket` selects the preference and resolves it against server-owned shelf stock and prices.
- The completed-shift count comes from the validated player profile. Closing a shift increments the in-memory count in the same guarded transition; `ProfileService` persists the completed-shift event using its existing serialized save path.
- `ShiftService` passes sanitized display strings to `WorldBuilder`; no client input selects a preference, product, quantity, or price.
- Empty preferred shelves use the existing available-stock fallback. Empty total store stock keeps the existing no-stock basket display.
- The customer preference has no independent persistence field or remote.

## Acceptance criteria

1. Across several shifts, customers visibly show more than one preference label and product combination.
2. The same profile shift count and sale number yield the same preference after reconnect.
3. Missing preferred stock never sells an unavailable product; the fallback basket only contains stocked products.
4. Discount and premium price behavior, atomic checkout totals, and one-sale-per-customer behavior remain intact.
5. Preference labels remain readable over the customer and do not change queue recovery or event labels.

## Manual Studio verification

1. Start a shift with stock available in all four product departments. Watch a full customer visit and record the preference label and basket.
2. Serve enough customers and repeat over at least two completed shifts. Confirm the labels and baskets vary; the nominal distribution is long-run weighting, not a guarantee for a short sample.
3. Leave and rejoin before serving the next customer. Confirm the next preference/basket matches the pre-rejoin HUD or customer state for that same shift and sale number.
4. Empty one preferred department while leaving another SKU stocked. Confirm the customer's basket falls back to stocked goods and checkout removes only displayed available goods.
5. Test discounted and premium product prices. Confirm basket quantities follow the existing Phase 23 rule and the server charges the shown total exactly once.
6. Have a helper and owner attempt the same checkout around the same time. Confirm one customer is charged and preference labels do not grant permissions.
7. Verify normal labels return after a spill, outage, rush, and queue recovery. Check billboard readability at normal gameplay camera distance.

## Verification status

Static formatting, lint and Rojo build are recorded in the project status for this phase. Studio visual, persistence, multiplayer and transaction checks remain pending.
