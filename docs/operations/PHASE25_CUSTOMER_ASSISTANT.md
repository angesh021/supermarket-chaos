# Phase 25 customer assistant

After a completed shift, the Owner or Manager can hire a Customer Assistant for `$160`. The assistant appears in the store and reduces customer aisle-browsing travel time by 30%. Customers still browse the same server-derived basket, queue at checkout, and use the existing server-owned sale transition. Profile schema v16 stores the employee flag; schemas v1–v15 default to not hired.

## Acceptance criteria

- The hire prompt appears only in `Complete`; the server charges exactly `$160` once and rejects insufficient funds, duplicate, stale-stage and unauthorized attempts.
- Owner and Manager can hire. Cashier, Stocker, Maintenance, Visitor and unapproved players cannot hire or change another profile.
- A hired assistant appears at its designated store position and remains visible after restart/rejoin. The prompt stays disabled after purchase.
- The assistant reduces only the fixed customer browsing waypoint durations by 30%. It does not change product selection, basket contents, price, quantity, sale eligibility, rewards or currency.
- Customer navigation remains bounded by the existing route timeout/recovery; missing or interrupted route tweens do not grant sales or block recovery.
- Profile schema v16 validates the optional employee flag as a boolean. Schemas v1–v15 load with no assistant; no warehouse or other employee ownership is required.
- Save-lock, profile-load and session-only behavior continue through existing profile paths. No Robux, third-party assets or new client remotes are added.

## Server/client boundary and failure handling

`Economy.hireCustomerAssistant` owns stage, fixed cost and hire state. `ShiftService` binds the physical board prompt through the existing Owner/Manager authorization, range, cooldown, owner readiness and profile-lease checks. `ProfileService` validates and persists the hire flag with schema v16. `WorldBuilder` shows the employee and applies a fixed browse-speed multiplier to procedural route tweens; this is presentation only. Customer checkout still recomputes basket inventory and price on the server.

## Manual Studio checklist

1. Start Rojo and connect Studio to `localhost:34872` in the private development universe `10770581249`; keep Output visible.
2. With a completed shift and at least `$160`, hire the assistant. Confirm exactly `$160` is deducted, the model appears at its service position, and the prompt disables.
3. Try the hire with insufficient funds and as Cashier, Stocker, Maintenance, visitor and unapproved player. Confirm no invalid attempt charges or changes the model.
4. With the assistant not hired, observe customer route timing from entry through browsing to checkout. Hire the assistant and repeat with the same basket; confirm browsing travel takes about 30% less time while the selected departments, basket label, checkout readiness and sale total are unchanged.
5. Interrupt a customer route through a stage change/restart and confirm the existing route cancellation/recovery still works. Verify the assistant does not create sales when a route is interrupted.
6. Save/rejoin and confirm the assistant remains visible and the hire is not charged again. Load a legacy profile missing the flag and confirm no assistant appears until hired.
7. Verify Manager can hire and other roles cannot. Check save-lock rejection, session-only mode and Studio Output for errors.

## Known limits

- The assistant only speeds the current fixed browse route. It does not provide dialogue, product recommendations, satisfaction, staffing schedules or independent economic rewards.
- Studio timing, visibility, permissions, migration and rejoin behavior have not been run locally.
