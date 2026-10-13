# Phase 55 — Regional distribution center

## Acceptance criteria
- The one-time `$6,000` purchase is visible only to the store owner or Manager after a completed shift and delivery fleet ownership.
- A successful purchase deducts the fixed server price once, persists ownership, and builds the regional loading bay and rack blockout. Rejoining rebuilds the visual from saved ownership.
- Every warehouse SKU keeps a 500-unit cap before purchase and has a 1,000-unit cap after purchase. Delivery orders and shipment receipt both enforce the active cap.
- Existing shipment quantity, costs, product IDs, arrival delay, shift progression and online-order capacity do not change.
- Profile schema v34 migrates to v35 with distribution center unowned and keeps valid inventory at or below 500. Saved center state without a fleet is invalid.

## Authority and failure handling
- Client: may activate the fixed ProximityPrompt; submits no price, capacity, inventory or ownership data.
- Server: `ShiftService` applies role, prompt range, rate/profile checks and the common transaction lock. `Economy` validates stage, fleet prerequisite, balance and one-time ownership. `ProfileService` validates upgrade dependencies and the conditional per-SKU inventory limit.
- World visuals are server-built procedural parts. The center is adjacent to the existing warehouse and uses no external assets.
- Invalid prerequisite, insufficient funds, duplicate activation, or inventory that would exceed capacity is rejected without granting the upgrade or stock. A save failure follows the existing profile save/lock behavior; verify the reported save status in Studio.

## Manual Roblox Studio verification checklist
Use the private development experience (`10770581249`), connect Rojo as described in `docs/operations/QUALITY.md`, and keep Output open. Record cash, stock by SKU, profile status, and any Output errors.

1. With no delivery fleet, confirm the distribution-center pad is hidden or disabled. Attempt the prompt as a visitor and as a Cashier; neither can purchase it.
2. Complete a shift, own the warehouse, hire the delivery worker and buy the delivery fleet. Confirm the center purchase pad appears. Confirm a Manager can use it and a Stocker cannot.
3. With cash below `$6,000`, try the purchase; confirm the prompt reports the shortfall and cash/ownership remain unchanged. Add enough cash, buy once, and confirm exactly `$6,000` is deducted and the facility appears.
4. Re-trigger the prompt; confirm no second deduction. Start another shift and check that the facility remains built.
5. At each available SKU's existing 500-unit backstock boundary, verify that a delivery which would exceed 500 is rejected before the upgrade. Verify the same boundary for citrus, berry, apples, cereal, bakery twists, and freezer meals as applicable.
6. Buy the center with a completed shift, then order and receive deliveries until near 1,000. Confirm capacity permits inventory above 500 but no order/receipt can push any individual SKU above 1,000. Verify separate SKUs do not share one combined capacity pool.
7. Place an inbound delivery that fits when ordered, then fill its SKU's remaining capacity before receiving. Confirm receipt rejects the over-cap shipment safely and does not add inventory or clear the pending shipment. Clear room and receive it successfully.
8. Save, leave and rejoin. Confirm center ownership, each SKU quantity, shipment state and facility appearance persist. Repeat once with Studio API services disabled or an unpublished local session to confirm the session-only fallback remains playable.
9. Test an existing v34 profile without the center. Confirm it loads as unowned, existing <=500 inventory is preserved, and after saving/rejoining it reports schema v35. Confirm no profile without the fleet can have center ownership.
10. Run one stock order/receipt with the delivery worker enabled and confirm its existing automation behavior and three-order fleet limit are unchanged. Confirm a client cannot alter price or capacity through remote arguments.

## Verification status and limits
- Static checks are recorded in `docs/PROJECT_STATUS.md` after they run.
- Roblox Studio appearance, prompt visibility, roles, inventory boundaries, in-flight delivery behavior, DataStore migration and save/rejoin remain unverified until manually tested. No Studio result is claimed here.
- This is a single-player-owned logistics upgrade; it does not add suppliers, shipping fees, dynamic routes or multiple stores.
