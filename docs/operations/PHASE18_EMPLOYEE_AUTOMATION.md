# Phase 18 employee automation controls

Owners and Managers can pause or resume the automation for each hired employee from that employee's staff board. Paused employees remain hired and visible; player-operated actions remain available. The settings save with the player-owned profile.

Profile schema v12 adds three booleans. Profiles from schemas v1–v11 default each setting to enabled, preserving existing employee behavior. No client remote argument chooses an employee or setting: each physical prompt has a fixed server ActionId, and the server validates role, distance, cooldown, save state, and that the employee is hired.

Automation timers recheck their generation token, current employee setting, shift stage, owner readiness, and profile lease before mutating the economy. A pause invalidates pending timers. The existing economy methods still own all inventory, sales, and reward changes.

## Acceptance criteria

- A hired cashier, stock clerk, or cleaner has a visible board prompt that reads **Pause Automation** while active and **Resume Automation** while paused.
- Owner and Manager can toggle the matching employee; other helper roles and visitors cannot.
- Pausing before an automation timer fires prevents that timer from making a sale, stocking product, or cleaning the spill. Resuming permits future eligible actions.
- A paused employee remains hired, visible, and saved. Manual player actions still work through the existing role-gated actions.
- Each setting saves and restores independently after leaving and rejoining. Legacy schemas v1–v11 retain the previous default-on behavior.
- Invalid, unauthorized, out-of-range, stale, lock-lost, and rapid prompt actions do not change employee settings, cash, inventory, sales, or shift stage.

## Server/client boundary and failure handling

`Economy.toggleEmployeeAutomation` allow-lists the three employee IDs and requires the employee to be hired. `ShiftService` binds separate fixed prompts through the common Owner/Manager role, range, cooldown, owner-readiness, and save-lock gate. It persists only the resulting booleans. `ProfileService` validates the schema v12 flags and normalizes absent legacy values to true. `WorldBuilder` displays prompt text and employee visuals only; it does not decide whether an action is authorized. Scheduled callbacks are invalidated on every automation reschedule and recheck server state before using existing economy transitions.

If a save is pending or the session lease is lost, the standard action gate rejects the prompt; any timer that observes a pending save or lost lease exits without mutation. Membership roles remain session-only and are not persisted.

## Manual Studio checklist

1. In the private development universe `10770581249`, start Rojo and connect Studio at `localhost:34872`. Keep Output visible.
2. Complete a shift and hire each employee. Confirm each employee appears and its staff board offers **Pause Automation**.
3. Toggle the cashier off and on. Confirm the prompt changes to **Resume Automation** and back, and the dashboard message reports the new state.
4. Start a shift with the cashier paused. When customers reach checkout, wait longer than four seconds; confirm no automatic sale occurs. Resume automation and confirm one eligible sale occurs.
5. Pause the stock clerk before recovering the cart. Confirm it does not automatically stock after the cart action. Resume it while the shift is at Stock and confirm stocking occurs once.
6. Pause the cleaner before triggering/entering Spill. Confirm the spill remains until a player cleans it. Resume it in a subsequent spill and confirm automatic cleanup occurs once.
7. For each employee, verify pausing does not remove the employee, prevent a helper with the appropriate role from performing the manual action, or grant an unauthorized role new permissions.
8. Leave and rejoin after saving a mix of enabled/paused settings. Confirm all three settings restore independently. Test a legacy profile through the normal schema migration path and confirm hired employees default to enabled.
9. Race a player/helper action against an automation timer and verify the existing economy transition happens at most once. Check Owner, Manager, Cashier, Stocker, Maintenance, visitor, too-distant, rapid-repeat, and profile-lock cases.
10. Confirm no Output errors and record each employee's hire/automation state, resulting inventory/sales, role and save status.

## Known limits

- Employee behavior still covers only the existing starter stock, checkout, and spill automation loops. Wages, schedules, broader SKU handling, and full staff simulation are not included.
- Studio timers, permission behavior, persistence, legacy migration, and player/employee races have not been run locally.
