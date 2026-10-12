# First-session experience specification

Timing below is a pacing target, not a forced wait. Skilled players may advance as soon as tasks are complete. Every step is solo-completable.

| Target | Player beat | System response | Measurement |
|---|---|---|---|
| 0:00–0:30 | Arrive during a small commotion; stop/return the runaway cart | Short employee prompt, highlighted interaction, cart recovery animation, immediate modest reward | `onboarding_started`, `cart_objective_completed`, elapsed time |
| 0:30–2:00 | Stock a recognizable fictional product and help a customer | Shelf count/placement feedback; customer points toward checkout | `first_stock_completed`, `first_customer_served` |
| 2:00–4:00 | Scan items at first checkout | Clear scan and sale feedback; server records transaction | `first_sale_completed`, elapsed time |
| 4:00–7:00 | Serve a manageable rush | Queue pressure communicated visually and by concise UI | rush start/end, abandonment |
| 7:00–10:00 | Resolve one chaos event | Warning, one objective, recoverable outcome and celebratory response | `first_chaos_started/completed` |
| 10:00–12:00 | Close shift and purchase first upgrade | Earnings breakdown and visible store change | `first_shift_completed`, `first_upgrade_purchased` |
| 12:00–15:00 | See adjacent future commercial plot | Nonblocking preview of future opportunities | preview viewed; no forced conversion |

## Interaction contract
Every action has a clear prompt, response within the same interaction beat, success/failure feedback, and a recovery path. Guidance uses context and world placement rather than a long opening cutscene. Skip/resume behavior must not grant duplicate rewards. Tutorial completion and rewards are idempotent server-side.

## Design hypotheses
The master brief suggests targets of 90% first interaction, 85% first sale, 70% first upgrade, 65% first shift, and 40% voluntary second shift. Treat as hypotheses only. Establish cohort, sample size, session/device breakdown, and privacy review before interpreting results.
