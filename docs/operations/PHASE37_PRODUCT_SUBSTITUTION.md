# Phase 37 — Stock-aware customer substitutions

## Acceptance criteria

- When an intent's requested SKU is out of stock, the server may substitute only from the fixed related-product order: Citrus Pop ↔ Berry Bites, Golden Apples ↔ Sunrise Cereal, and Cinnamon Twists → Berry Bites → Sunrise Cereal.
- Substitution consumes the actual substitute SKU and uses its server-owned price. Each shelf unit is reserved once while the server constructs a mixed basket.
- The basket label identifies substitutes and requested products. Customer browsing uses actual basket SKU IDs, so shoppers visit the shelf being purchased rather than an empty requested shelf.
- If no related product can fulfill any requested item but another shelf has stock, one available product may be used as an explicitly labeled fallback. Empty-store checkout remains rejected without mutation.
- Satisfaction is server-calculated: a fully exact basket adds 3; each substituted unit reduces that result by 2; each unfilled unit reduces it by 4; the pre-premium result is floored at -10. Existing premium SKU deductions remain 2 per SKU and the score stays in [0, 100].
- No new profile field is required. Current schema v23 persists the resulting satisfaction through the existing sale transaction; legacy profiles retain their current migration path.

## Server/client boundary and failure handling

- `Economy.getNextCheckoutBasket` owns substitution ordering, availability, prices, item IDs and satisfaction delta. The client receives display information only; it cannot select an SKU or report a sale.
- `Economy.sellProduct` deducts only actual item IDs and applies cash, sale count and satisfaction once in the same server transaction.
- Structured actual basket items are sent to `WorldBuilder` for navigation; display text is not parsed to choose a destination.
- Missing substitutes leave the requested quantity unfilled and affect satisfaction. No usable stock results in the existing empty-basket rejection. Layout and prompt permissions are unchanged.

## Manual Roblox Studio verification

1. On a completed shift, stock only Citrus Pop and serve a basket requesting Berry Bites. Confirm the label identifies the substitute, the customer browses Citrus Pop, and checkout charges the Citrus Pop price.
2. Stock Sunrise Cereal and leave Golden Apples empty. Test a Family shop; confirm actual stock and price are used and the customer visits only cereal.
3. Test a mixed basket with one direct product and one substitute. Confirm both actual quantities are deducted once and the customer browses both actual departments.
4. Empty a substitute pair while stocking an unrelated product. Confirm a one-item fallback is explicitly labeled. Empty every shelf and confirm checkout changes no cash, stock, sales or satisfaction.
5. After building the bakery, test Cinnamon Twists substitutes in the documented order, including actual pricing, depletion and navigation.
6. Compare satisfaction changes for exact, substituted, partly unfilled, premium-priced and empty baskets. Confirm 0/100 bounds and single application when Owner and Cashier race to check out.
7. Save/rejoin before and after a substitution sale. Confirm satisfaction, cash and inventory restore; no migration is needed.
8. Confirm visitors receive no private stock or satisfaction data and HUD text remains readable on touch.

## Local checks and runtime status

- Pinned StyLua, Selene and Rojo results are recorded in `docs/PROJECT_STATUS.md` after implementation.
- Roblox Studio basket variation, customer navigation, sale races, satisfaction and DataStore behavior remain manual checks; no runtime success is claimed.
