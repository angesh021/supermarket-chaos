# Phase 22 product pricing

Owners and Managers can cycle each shelf's retail price through three fixed values: 80% of catalog price, the catalog price, and 125% of catalog price (rounded to a whole dollar). Shelf price tags and checkout basket totals use the current server-owned price. Prices persist per player profile; schemas v1–v14 retain catalog prices on migration.

## Acceptance criteria

- Four shelf tags show Citrus Pop `$20/$25/$32`, Berry Bites `$14/$18/$23`, Golden Apples `$9/$12/$15`, and Sunrise Cereal `$12/$16/$20` as the owner cycles the corresponding prompt.
- Only the owner or authorized Manager can change a price. Prompts are range checked and rate limited server-side; client input never selects a price or amount.
- A customer basket displays the current price total and checkout recomputes that same total from server state, consuming the correct inventory and counting one customer sale.
- A changed price is saved with the owner's profile and restored after rejoin. Legacy schemas v1–v14 default to each catalog price.
- Unknown products, malformed stored price values, and unauthorized, out-of-range, duplicate or save-locked interactions cannot alter a price or sale.
- Visitors receive no private owner economy state. Shelf tags remain ordinary shared-store presentation.

## Server/client boundary and failure handling

`Economy.PRODUCTS` defines the catalog base price; `Economy.cycleProductPrice` selects only one of three derived prices and `Economy.getProductPrice` is used by basket calculation and atomic checkout. `ShiftService` binds a separate fixed product action to each physical shelf prompt and applies the Owner/Manager role, range, interaction cooldown, owner readiness and profile lease checks. `ProfileService` validates and persists only allow-listed product IDs and exact supported integer values in schema v15. `WorldBuilder` projects prices to shelf tags and prompt text. The client does not provide a price.

## Manual Studio checklist

1. Start Rojo and connect Studio to `localhost:34872` in the private development universe `10770581249`; keep Output visible.
2. Verify the four shelf tags begin at catalog prices. Trigger each Owner prompt three times and confirm the displayed sequence is catalog, 125%, 80%, catalog.
3. Assign a second player Manager and verify they can change a price. Verify Cashier, Stocker, Maintenance, visitor, and unapproved player prompts cannot change one.
4. Start checkout with at least one item stocked. Confirm the objective, customer order, and basket total use the active price. Complete checkout and confirm cash, stock, and sale count each change by the expected amount once.
5. Try a mixed basket at changed prices and confirm every item is charged at its own active price in one sale.
6. Save/rejoin and confirm all four prices remain. Confirm a legacy profile missing `productPrices` loads at catalog prices.
7. Test concurrent price prompt activations, a prompt from outside range, and profile save/lock failure; confirm no unintended price or cash mutation and no Output errors.

## Known limits

- Phase 23 adds a deterministic quantity response. Customer satisfaction, product substitution and walk-away behavior remain out of scope.
- Studio role, shelf-tag readability, checkout totals, migration and save/rejoin checks have not been run locally.
