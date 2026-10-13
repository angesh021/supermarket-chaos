# Phase 59 — Maple Corner Florist

## Acceptance criteria
- After Little Sprout Garden is owned, the player can purchase Maple Corner Florist for $1,500 between shifts.
- Stockers and Owners/Managers can restock four bouquets for $320, up to a 12-bouquet cap. Cashiers and Owners/Managers can sell one bouquet for $240.
- The florist shows bouquet inventory and cumulative sales on its sign; stocked bouquets become visible procedural display items.
- Plaza visitors may browse the florist. Their sale uses the same server economy transition, with the existing 15-second per-business throttle and shared sale transaction lock.
- Schema v38 saves florist ownership, stock and sales. Existing v37 profiles migrate with the florist unowned, empty, and otherwise unchanged, including their `locations.neighborhood` snapshot.

## Server/client boundaries and failure handling
- Purchase, price, stock, cap, sales, and visitor purchase are server-owned. Client-supplied cash, quantity, price, visitor SKU, or ownership is never accepted.
- Existing `bind` role, distance, rate, owner readiness and profile-save checks protect physical prompts. Role actions are explicit: Manager can build/restock/sell; Stocker can restock; Cashier can sell.
- Insufficient funds, wrong shift stage, missing prerequisite, full display, empty stock, unavailable profile, duplicate transaction, or reached counter limit leave state unchanged and return a status message.
- The florist is one business inside the existing neighborhood location; this increment does not claim multi-location runtime support.

## Manual Roblox Studio checklist
Use the private development experience in universe `10770581249`. Sync the pushed `main` branch with Rojo and use Play Solo; use a second account for the role checks.

1. On a fresh profile, finish a shift and purchase the earlier plaza businesses through Little Sprout Garden. Confirm Maple Corner's purchase pad appears only between shifts and not before Garden ownership.
2. With less than $1,500, try the purchase. Confirm it is declined and the cash is unchanged. Earn enough and purchase it; confirm exactly $1,500 is charged and the florist counter, sign and display activate.
3. Try to restock during an active shift. Confirm no cash or stock changes. Between shifts, restock once: confirm $320 is charged, stock becomes 4, and four bouquets appear. Restock twice more to reach 12, then confirm the next restock is disabled/rejected with no charge.
4. Sell one bouquet with the prompt. Confirm cash increases by exactly $240, stock drops by one, sales rises by one and one bouquet disappears. Sell down to zero and confirm further sales do not change state.
5. Invite a Cashier and Stocker. Confirm Cashier can sell but cannot restock/build; Stocker can restock but cannot sell/build; Manager can use all three florist actions. Remove a role and confirm its access ends.
6. With stock available, let a plaza visitor browse the florist. Confirm at most one bouquet is sold during the 15-second business throttle, the server cash/stock/sales match the physical sale, and empty stock creates no transaction.
7. Rejoin. Confirm florist ownership, stock and sales persist. With a v37 test profile, confirm all preexisting money, shift, inventory, upgrades, business data and location snapshot values remain unchanged while florist defaults to unowned/empty/zero sales.
8. Inspect Output and walk around the storefront. Report any prompt that appears at the wrong time, sign/display mismatch, visitor path obstruction, duplicate transaction, or runtime error.

## Verification status
- StyLua 2.5.0 `--check src`, Selene 0.32.0 (0 errors, 0 warnings, 0 parse errors), Rojo 7.7.0 build to `%TEMP%\supermarket-chaos-phase59.rbxlx`, and `git diff --check` passed on 2026-10-13.
- Studio appearance, permissions, transactions, visitor sales and v37 migration remain unverified until the checklist is run.
