# Phase 9 — Checkout spill event

## Scope and rules

After the first successful sale in a shift, the server pauses the queue at the `Spill` stage. The spill is a fixed, procedural floor prop near checkout. The owner, Manager, or Maintenance helper may clean it through an in-world prompt; successful cleanup awards $5 once and resumes the queue. Customers remain visible while waiting. The spill state is saved as the shift stage, so rejoining restores the same objective.

This is a predictable first chaos event, not a randomized event director. It has no countdown, penalty, destructive outcome or client remote. Customer Rush and Power Outage remain future events and require their own safe failure/recovery designs.

## Acceptance criteria

- The first successful sale in a shift deducts one stock and credits $25 once, then activates the spill and disables checkout.
- The spill prompt and sign appear only while the saved stage is `Spill`; the queue remains visible and waiting.
- Owner and Manager can clean the active spill; Maintenance can clean it but cannot check out or close the shift. Other roles cannot.
- One successful cleanup adds exactly $5 and returns to Checkout. Replayed, stale, out-of-range, unauthorized or excessive prompt requests change no state or balance.
- If the owner leaves while the spill is active, rejoining restores the spill, queue count, balance and objective. The event does not expire while offline.
- A cashier does not bypass the spill; automatic sales resume only after an authorized cleanup.

## Authority and failure handling

- `Economy.CHAOS_EVENTS.CheckoutSpill` defines the event id, trigger sale, objective and fixed reward. `Economy.sellProduct` activates it; `Economy.cleanSpill` owns the one-time reward and resume transition.
- `ShiftService` reuses prompt ancestry, player role, active owner/save status, proximity and interaction cooldown validation. No client-controlled event identifier, reward, quantity or stage is accepted.
- Profile schema v5 includes `Spill` in the finite shift-stage allowlist. Older profiles retain the existing migration defaults. Invalid stage values reject profile loading rather than being coerced into an event.
- If no authorized player is available, the queue safely waits. A persistence failure blocks interactions under the existing profile save guard.
- Runtime visual placement and DataStore migration behavior are not established by local lint/build checks.

## Manual Studio verification

1. In the private development universe, recover the cart and stock three cans. Confirm checkout opens with three customers.
2. Serve the first customer. Confirm exactly $25 is added, one can is consumed, the checkout prompt disables and the spill sign/cleanup prompt appear. Confirm two customers remain visible.
3. As owner, clean the spill once. Confirm exactly $5 is added, the spill disappears, and checkout resumes with two customers.
4. Try cleaning again, invoke a stale prompt, and test from outside prompt range. Confirm the balance, stage and queue do not change.
5. Using a second account, approve it as Maintenance. Confirm it can clean the active spill but cannot use checkout or closeout. Repeat with Cashier, Stocker and unapproved Visitor; each must be unable to clean it.
6. Start a shift with a cashier employee. Confirm its automatic sale pauses at the spill and does not bypass cleanup; after the owner or Maintenance cleans it, confirm sales resume.
7. Leave/rejoin while the stage is `Spill`. Confirm the saved objective, spill visuals, queue of two, cash and stock are restored. Clean it and finish the remaining sales.
8. Repeat in a session-only universe if available; confirm the session proceeds without claiming persistent save status.

Record account roles, before/after balance, stock, sales, stage, Output errors and save/rejoin behavior. Do not describe Studio runtime behavior as passed until observed.
