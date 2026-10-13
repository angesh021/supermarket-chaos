# Phase 26 repeat-shift analytics

The existing development-only onboarding funnel is complemented by a `RepeatShift` funnel. It records first-shift completion, the next shift start, and completion of that repeat shift. Returning profiles begin at the profile-loaded step. Funnel IDs remain in server memory; Roblox associates events with the required Player argument. No custom player identifiers, balances, products, purchases or profile contents are sent. Analytics remain disabled outside development universe `10770581249`.

## Acceptance criteria

- A new profile emits no repeat-play steps until the first shift completes; that event records `First Shift Completed` as step 1.
- Restarting from Complete records `Another Shift Started` as step 2; closing that repeat shift records `Repeat Shift Completed` as step 3.
- A profile with one or more previously completed shifts records `Returning Store Profile Loaded` as step 1 when its profile is opened. A subsequent restart and shift completion advance steps 2 and 3.
- Duplicate, stale or out-of-order calls do not advance the funnel. Analytics API failures are caught and cannot block gameplay or profile saving.
- The existing FirstShift funnel retains its original six milestones.
- No analytics events are emitted in other universes. No game-owned player identifier, session ID, product/balance field or other custom player data is sent; the API receives only Roblox's required `Player` plus funnel metadata.

## Server/client boundary and failure handling

`TelemetryService` observes server-confirmed profile/shift milestones only. The server keeps ephemeral funnel UUIDs and last-step counters in memory. `AnalyticsService:LogFunnelStepEvent` is wrapped in `pcall`; failed logging does not update the last successful step and does not affect gameplay. The service checks the configured development universe before logging. No client analytics remote or DataStore field is added.

## Manual Studio and dashboard checklist

1. Confirm the development experience uses universe `10770581249` and platform analytics are enabled for the private test experience.
2. With a clean test profile, complete the first shift. In Creator Dashboard analytics, confirm `RepeatShift` steps arrive in order: **First Shift Completed**, **Another Shift Started**, **Repeat Shift Completed**.
3. Rejoin with a profile that already has a completed shift. Confirm **Returning Store Profile Loaded** begins the funnel, then restart and complete another shift to reach steps 2 and 3.
4. Restart the same shift multiple times and confirm each event appears at most once for the tracked three-step funnel instance; steps never move backward.
5. In a non-development copy, confirm the existing session-only behavior and no onboarding or repeat-shift funnel events.
6. Temporarily test AnalyticsService failure only in a disposable development session. Confirm Output may report no event, but shift close/restart, profile saving and gameplay still work.
7. Review the dashboard dimensions and verify only the required Roblox Player association and static funnel metadata are present; no game-owned user ID or economic data is attached.

## Known limits

- Local static checks cannot confirm Creator Dashboard ingestion, reporting delay, retention cohort quality or player behavior. This funnel is an engagement signal, not proof of Day-1/Day-7 retention or revenue.
- Studio and dashboard verification have not been run locally.
