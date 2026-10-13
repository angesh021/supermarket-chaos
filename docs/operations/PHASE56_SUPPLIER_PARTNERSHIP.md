# Phase 56 — Regional supplier partnership

## Acceptance criteria
- The one-time `$2,500` partnership purchase appears only after the regional distribution center is owned and the current shift is Complete.
- Owner and Manager can buy it once. A successful purchase deducts exactly `$2,500`, persists ownership and updates every warehouse order prompt to its discounted price.
- Every SKU delivery costs 20% less, rounded down to a whole unit. Shipment quantities, capacity, wait time, inventory, shelf price and sales do not change.
- Profile schema v35 migrates to v36 with no partnership. A saved partnership without a distribution center is invalid.

## Server/client boundaries and failures
- Client: can activate the fixed purchase prompt; sends no price, discount, SKU or quantity.
- Server: `ShiftService` checks the Owner/Manager role, prompt distance, interaction rate, profile lock and shared transaction lock. `Economy` checks stage, distribution-center ownership, funds and prior purchase. `Economy.getDeliveryCost` computes order charges. `ProfileService` validates the persisted prerequisite.
- Insufficient cash, duplicate purchase, wrong stage or missing center changes neither cash nor contract state. A delivery that fails space/funds/ready-time checks remains rejected by its existing server path.

## Manual Roblox Studio checklist
Use the private development experience (`10770581249`), connect Rojo as described in `docs/operations/QUALITY.md`, and keep Output visible. Record cash, displayed prompt prices, purchase results, order charges and profile status.

1. Without the distribution center, confirm no supplier partnership prompt is visible or enabled.
2. Own the center and complete a shift. Confirm Owner and Manager can see the contract prompt. Confirm Cashier, Stocker, Maintenance and read-only visitors cannot buy it.
3. With less than `$2,500`, try to purchase; confirm no cash or ownership changes. Add enough balance, purchase once, and confirm exactly `$2,500` is deducted. Try again and confirm no repeat charge.
4. Compare each of the six displayed prompt prices to the discounted cost: Citrus Pop `$48`, Berry Bites `$36`, Golden Apples `$28`, Sunrise Cereal `$36`, Cinnamon Twists `$40`, and Freezer Meals `$44`.
5. Order each available SKU in a safe test profile. Confirm the matching server charge, quantity, 15-second arrival delay and SKU tagging. Confirm shelf price and sales payout are unchanged.
6. With the partnership unowned, verify original catalog delivery costs remain `$60`, `$45`, `$35`, `$45`, `$50`, and `$55` respectively. Confirm existing profiles do not receive the discount automatically.
7. Rejoin after purchase and confirm the prompt remains hidden, discounted prices remain displayed, and the agreement is not charged again. Load a v35 profile, confirm it migrates to v36 without the agreement, then buy it and verify persistence.
8. Test in a session-only environment and confirm the game remains playable without claiming the agreement persists. Check Studio Output for errors and confirm one order cannot be charged twice by rapid prompt activation.

## Verification status and limits
- Static checks are recorded in `docs/PROJECT_STATUS.md` after they run.
- Roblox Studio prompt visibility, role behavior, exact displayed and charged prices, migration, and save/rejoin have not been run locally and remain manual checks.
- The partnership is a fixed fictional agreement. It does not represent a real vendor, add external commerce, alter customer prices or model changing market rates.
