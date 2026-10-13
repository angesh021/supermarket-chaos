# Phase 23 price-sensitive shopping baskets

Customer basket quantities now respond to the current server-owned price while remaining deterministic from saved sales count and shelf inventory. If a single-product basket's price is below catalog, that shopper buys one extra unit when one more is on the shelf. If a basket asks for multiple units of a product priced above catalog, the shopper buys one fewer. Mixed baskets are not quantity-adjusted. There is no random demand or walk-away behavior.

## Acceptance criteria

- The five reachable server-derived patterns cover single Citrus Pop, Berry Bites and Golden Apples requests, a Citrus Pop/Sunrise Cereal mixed basket, and a two-unit Berry Bites request. Sunrise Cereal also fulfills a single-item stock fallback when its preferred Citrus Pop is unavailable.
- A below-catalog price adds exactly one unit to a single-product basket only when shelf stock has a second unit; totals and stock deductions include that unit.
- An above-catalog price reduces a multi-unit product request by exactly one; the sale still counts as one customer and leaves the unpurchased unit on the shelf.
- Catalog-priced baskets preserve their requested quantities. Mixed baskets remain unchanged by price tier.
- Empty stock, one remaining unit, and shelf caps never yield negative or over-limit inventory. Rejoin reconstructs the same basket from saved sales, current prices and inventory.
- Checkout recomputes price and quantity server-side; clients cannot choose an item, quantity, discount or basket total.

## Server/client boundary and failure handling

`Economy.getNextCheckoutBasket` selects a bounded intent from server-owned sales progress, resolves against available shelf stock, applies the fixed price-tier quantity rule and computes the total. `Economy.sellProduct` recomputes that basket and atomically deducts its quantities and credits its total. `ShiftService` sends the basket only as display state; checkout role, stage, range, cooldown, owner readiness and profile lease remain server checks. No new profile fields are required.

## Manual Studio checklist

1. Start Rojo and connect Studio at `localhost:34872` in development universe `10770581249`; keep Output visible.
2. Stock at least two Citrus Pop, set its price below catalog, and serve a customer whose intent is Citrus Pop. Confirm the order shows two units, the total is `$40`, and checkout consumes two cans once.
3. Leave exactly one unit on that shelf, keep Citrus Pop discounted, and reach another single-Citrus intent. Confirm the basket stays at one unit.
4. Set Berry Bites above catalog, stock two units, and serve the two-Berry basket. Confirm it becomes one unit at `$23` and leaves one pack on shelf.
5. Set one product below and another above catalog; confirm mixed baskets keep their intended quantities while totals use each posted price.
6. Set all prices to catalog and verify quantities match the displayed server-derived intent patterns, including cereal and apples.
7. Rejoin at the same saved sales progress with the same prices and stock; confirm the basket reconstructs exactly. Try simultaneous checkout attempts and confirm a customer is sold once.
8. Test owner, Manager, Cashier, visitor and save-lock cases; confirm unauthorized or blocked actions do not mutate inventory, cash or sale count and produce no Output errors.

## Known limits

- Price response is a simple deterministic quantity rule; it does not model customer budgets, satisfaction, product substitution, random demand or walk-away behavior.
- Studio basket, race, role, and save/rejoin checks have not been run locally.
