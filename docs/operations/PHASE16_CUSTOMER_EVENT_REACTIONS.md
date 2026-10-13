# Phase 16 customer event reactions verification

Waiting customers now show stage-specific billboard reactions for the checkout spill, power outage and Customer Rush. The label changes immediately from the server-owned stage and is retained when the customer reaches the queue or the route recovery reconstructs the line. The reactions are presentation only: they do not change event timing, queue count, sale eligibility, rewards or inventory. No profile schema change is needed.

Studio appearance and timing have not been run locally.

## Acceptance criteria

- Customers visibly display `WAITING • SPILL` while the saved shift stage is `Spill`.
- Customers visibly display `WAITING • POWER OUT` while the saved shift stage is `PowerOutage`.
- Rush customers visibly display `RUSH CUSTOMER` while the stage is `CustomerRush`.
- Returning to normal checkout restores `NEXT CUSTOMER`/`IN QUEUE` labels on active customers.
- Labels remain correct after route recovery and save/rejoin reconstruction.
- Reaction text never changes the server-owned queue, sales count, stock, balance, event deadline or reward.
- No new client remote, saved field or schema version is added.

## Server/client boundary and recovery

`WorldBuilder` receives the current stage through the existing server `setStage` call. It updates only customer billboard text. Queue count and transaction state remain owned by `Economy` and `ShiftService`; route recovery uses the same stage-aware display helper. If a label is missed during animation, the existing queue recovery repaints it on reconstruction. The client cannot select a reaction or use it to advance checkout.

## Manual Studio checklist

1. In the private development universe `10770581249`, start Rojo and connect Studio at `localhost:34872`; keep Output visible.
2. Trigger the checkout spill and confirm visible waiting customer labels mention the spill. Clean it and confirm the line returns to normal customer labels.
3. Reach the second-sale outage and confirm the line displays the power-out reaction until the breaker or timer restores power.
4. Trigger Customer Rush and confirm the bonus shoppers display the rush reaction. Serve them and confirm the label is purely visual and the existing rush reward/queue rules still work.
5. Let a route take longer than the recovery window or rejoin during an event. Confirm recovered customers display the correct reaction for the restored stage.
6. Record stage, visible labels, customer count, sales, balance and Output errors. Confirm reactions alone never change an economy counter.

## Known limits

- Reactions are short text only; no customer facial animation, audio, patience or event-specific decision behavior is implemented.
- Visual legibility and animation timing await Studio review.
