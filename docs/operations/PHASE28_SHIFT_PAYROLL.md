# Phase 28 shift payroll

Completed shifts now charge the owner's current hired staff a predictable wage from the existing server-owned cash balance. Fixed payroll per shift is `$4` for a cashier, `$4` for a stocker, `$3` for a cleaner, `$3` for a delivery worker and `$2` for a customer assistant. The `$20` shift bonus is credited first; wages are then charged once in the same close-shift transition. Pausing automation does not end employment or avoid wages. The HUD status line and completed-shift objective show estimated payroll without adding a new panel.

## Acceptance criteria

- Payroll is derived only from server-owned hire flags and the fixed wage table; clients cannot supply roles, amounts or wage values.
- Closing a valid shift credits `$20` gross, deducts the exact total for currently hired staff once, and reports gross bonus, payroll and net bonus.
- Closing twice, closing from an invalid stage, or a stale prompt cannot charge payroll a second time.
- Employees continue to receive their fixed wage when automation is paused; un-hired employees contribute `$0`.
- Owners and store members with access see the current per-shift payroll in the existing status line; visitors receive `$0` and no payroll information.
- The existing cash field is the only persisted result; no new profile schema field or extra transaction source is introduced.

## Server/client boundary and failure handling

`Economy.getShiftPayroll` totals a fixed allow-list of server wage rates and server hire flags. `Economy.closeShift` already guards stage and the saved `shiftClosed` flag, then credits the existing shift bonus and charges payroll in one transition. `ProfileService.saveProgress` persists the resulting cash through its existing serialized save path. `ShiftService` sends only a computed payroll total to authorized viewers. The client displays that value but cannot change payroll or closeout.

## Manual Studio checklist

1. Complete a shift with no employees. Confirm the closeout retains the `$20` bonus and HUD payroll shows `$0`.
2. Hire one employee, complete a later shift, and compare the closeout with the employee's fixed wage table amount.
3. Hire all five roles and confirm payroll is `$16` per completed shift, the gross bonus is `$20`, and net shift bonus is `$4`.
4. Pause each automation separately and verify payroll still includes that hired employee.
5. Attempt a duplicate/stale close prompt and confirm neither balance nor message records a second wage charge.
6. Confirm the owner and authorized helpers see payroll while an outside visitor sees no private store payroll.
7. Rejoin after closeout and confirm saved cash equals sales/rewards less one payroll charge; restart and ensure the next shift can close once again.
8. Verify the HUD status remains readable at desktop and touch resolutions and that no extra screen panel was added.

## Limitations

- Wages are simple flat per-shift amounts, not hourly schedules, taxes, morale, hiring/termination choices or long-term accounts payable.
- Studio multiplayer, UI sizing, wage timing, save/rejoin and transaction race checks have not been run locally.
