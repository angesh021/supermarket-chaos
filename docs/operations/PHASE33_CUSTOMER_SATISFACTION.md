# Phase 33 customer satisfaction

## Scope

Each successful checkout adjusts a persistent 0–100 customer satisfaction score. The score starts at 75 for new and migrated profiles. It rises by 3 when the basket fulfills the customer's complete preferred product quantities, falls by 6 when stock forces a fallback or partial basket, and loses another 2 for each premium-priced SKU in the basket. The result is clamped to 0–100 and shown in the owner/helper HUD.

This is a server-owned management signal. Satisfaction does not change the cash total, stock deduction, sale count, queue size, or rush reward. These rules keep the score measurable without changing the existing sale transaction's economy; future reputation, loyalty and demand effects remain separate work.

## Server/client boundary and persistence

- `Economy.getNextCheckoutBasket` computes preference fulfillment and a bounded satisfaction delta from server-selected intent, available stock, quantities and product prices.
- `Economy.sellProduct` changes satisfaction only after a valid sale and applies the delta once in the same server transaction.
- `ProfileService` validates an integer score from 0 through 100, persists it through the existing serialized profile path, and defaults legacy v1–v19 profiles to 75.
- Shift snapshots share the score only with authorized store participants. Clients display it but cannot submit score changes or sale outcomes.
- Rejected sales and empty baskets do not change satisfaction. A profile save-lock loss continues to block the normal gameplay transaction path.

## Acceptance criteria

1. A newly created or migrated profile begins at 75 and restores its saved value after rejoin.
2. A fully fulfilled basket adds 3; a partial/fallback basket subtracts 6; each premium-priced SKU subtracts another 2; the result stays within 0–100.
3. A sale race changes satisfaction once because only one server sale transaction succeeds.
4. Rejected/empty-stock checkout attempts do not change satisfaction, balance, inventory or sales.
5. The HUD shows the score and changes its color at the documented 65 and 35 thresholds. Visitors do not see the owner's score.
6. Satisfaction does not alter checkout totals, payroll, event eligibility, queue size or rewards.
7. Malformed profile values (fractional, negative, over 100, NaN or non-number) are rejected; old profiles migrate safely.

## Manual Studio verification

1. Load a new account and a v19 development profile. Confirm both display 75% and retain all previous profile progress.
2. With all preferred departments stocked at catalog prices, serve customers whose full basket is available. Confirm each accepted sale adds 3 until the score reaches 100, then stays capped.
3. Empty a preferred department but leave another product stocked. Confirm fallback checkout changes the score by -6 and charges/deducts only the actual basket.
4. Set a product to its premium tier and serve a basket containing it. Confirm the extra -2 is applied once per premium SKU in the transaction.
5. Set the score near 0 and near 100 using a disposable test profile; confirm lower and upper clamping and the green/neutral/coral HUD colors.
6. Have Owner and Cashier attempt the same customer checkout. Confirm one sale and one satisfaction update. Attempt a rejected checkout with no stock; confirm no score change.
7. Rejoin after several sales. Confirm the score persists and continues from the previous value.
8. As a Visitor, confirm the HUD does not reveal the owner's satisfaction. Verify owner and Manager screens remain readable on touch and do not cover the objective.
9. For profile validation, use disposable profile fixtures with fractional, negative, >100, NaN and string scores. Confirm they fail safe without overwriting the stored profile.

## Verification status and limits

Static formatting, lint, Rojo build and diff checks are recorded in project status. Studio transaction, DataStore migration/rejoin, multiplayer visibility and touch layout remain unverified. Satisfaction currently gives feedback only; it does not yet affect loyalty, demand, customer patience, reputation unlocks or future revenue.
