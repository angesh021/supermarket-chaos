# Phase 31 reproducible chaos director

## Scope and behavior

The fixed spill-then-outage script is replaced with a server-derived shift plan. The plan uses the owner's UserId and completed-shift count to choose among four bounded schedules: spill on sale 1 plus outage on sale 2; outage on sale 1 plus spill on sale 2; spill only on sale 1; or outage only on sale 2. The existing optional Customer Rush check remains after the third base sale when stock permits. Event selection is reproducible for a player and shift, while varying across completed shifts.

The plan is not accepted from clients or stored as a new profile field. On rejoin, the same plan is derived from the server-known owner ID and profile shift count. Active interruption stage and event deadlines continue through existing profile persistence. A shift without a scheduled outage never enters `PowerOutage`; a scheduled outage deadline remains server-timed and recoverable.

## Server/client boundaries and failure handling

- `Economy.newState` derives the schedule from server-supplied `Player.UserId` and validated `completedShifts`.
- `Economy.sellProduct` remains the sole selector/activator. Sale pricing, stock deductions, event order and timing stay server-owned.
- `ProfileService` persists active stages and deadlines. Its validator accepts an outage at either supported early sale (1 or 2); stage/deadline consistency is still required.
- Clients receive ordinary stage/objective presentation only. They cannot select a schedule, event, deadline, reward, or recovery result.
- All planned events are distinct across the first two sales. Existing recovery paths return the queue to checkout; Customer Rush eligibility remains gated by the third base sale and remaining stock.

## Acceptance criteria

1. The same owner and completed-shift count reconstruct the same schedule after rejoin.
2. Different shifts for the same owner eventually produce different schedules; no sequence uses more than one event per sale.
3. Spill and outage may occur in either order, or one may be omitted. No scheduled event is activated at the wrong sale.
4. Each activated event retains its existing authorization, one-time reward behavior, server deadline, recovery, save and queue semantics.
5. Customer Rush can still begin after the third base sale when at least two units remain, regardless of which earlier events occurred.
6. Cash, inventory and sales change only through the original approved sale and event transactions; event selection itself is free.

## Manual Studio verification

1. In development universe `10770581249`, record the owner shift count and run a full shift. Record when the spill/outage occurs or whether one is absent.
2. Complete and restart shifts several times. Confirm the event plan varies for the same owner; do not expect a specific distribution over a short sample.
3. Rejoin during an active spill or outage. Confirm the same shift resumes the active event and, after recovery, follows its planned remaining events.
4. Test outage after sale 1 and sale 2. Confirm the appropriate deadline, manual Owner/Manager/Maintenance recovery, automatic recovery, cashier pause, and no extra sale/reward.
5. Test spill at sale 1 and sale 2. Confirm the existing cleanup authorization, exactly-once `$5` reward and queue continuation.
6. With sufficient stock, serve three baseline customers and confirm the optional rush still follows the third sale and preserves its deadline/reward/timeout rules.
7. As Cashier, Stocker, visitor, and out-of-range helper, attempt the existing event actions; confirm the director grants no additional permission.
8. Inspect Output and profile save status. Record owner shift count, event stage, sale number, cash, inventory and deadlines for each run.

## Verification status and limits

Local formatting, lint, Rojo build, and diff checks are run for this implementation. Studio scheduling, rejoin, multiplayer and deadline behavior remain unverified. The schedule is deterministic and bounded rather than an unpredictable real-time random event; the plan currently varies only spill and outage. It does not yet model equipment damage, event costs, sound, weather, or event-specific customer reactions beyond the existing stages.
