# Project status — 2026-10-12

## Summary
The user verified the desktop first-shift flow in Roblox Studio, including stocking visuals, customer visibility, the upgrade, and the compact HUD. Phase 2 progression and profile persistence are implemented locally. StyLua, Selene and Rojo build pass; Studio DataStore behavior is not verified.

## Phase 1 gate
- Desktop Play Solo core flow: user reported all requested steps passed after commit `5982419`.
- Studio screenshot feedback was addressed: objective/HUD placement, readable stats, visible stock, checkout customer, and upgrade discoverability.
- Mobile/device emulation and multiplayer behavior are not verified. G1 is accepted for desktop first-playable; mobile and multiplayer remain follow-up validation.

## Phase 2 implementation
- Player-owned profile with integer balance, in-progress shift state, upgrade ownership, completed shift count, and lifetime sales.
- Versioned profile envelope with atomic `UpdateAsync` acquisition, a server-session lease, autosave, final save/release, retry/backoff, and session-only fallback when DataStore access is unavailable.
- The first player joining a server owns its one physical store. Other players are read-only visitors until Phase 3 adds explicit cooperative roles.
- Shift state resumes after rejoin; the first shelf upgrade remains built; a completed store can start another shift and earn further currency.
- G2 is not passed until Studio DataStore access, save/rejoin, conflict, and failure handling are manually verified.

## Toolchain and checks
- Rojo 7.7.0, Selene 0.32.0, StyLua 2.5.0 are pinned in `rokit.toml`.
- Run StyLua format/check, Selene, and Rojo build for each code increment; remote GitHub Actions validates JSON and docs only.
- Roblox Studio is not controlled from this environment. Never report manual runtime checks as passed unless the user confirms them.

## Current limitations and risks
1. The first player in each server owns its single store; visitors cannot help or transfer ownership until Phase 3.
2. DataStore calls require a published private test experience with Studio API access enabled. If the service is unavailable, gameplay continues session-only and is clearly labeled; no default profile is saved over existing data.
3. The profile lease and save behavior need multi-server and failure-path Studio testing before persistent progression is treated as production-safe.
4. Mobile layout, performance profiling, full visual polish, and malicious-client tests remain outstanding.
5. Production publication, commerce, analytics transport, and live data are not configured.

## Required Phase 2 manual verification
- Enable Studio API access only on a private test experience.
- Complete a shift, stop Play, start again, and confirm balance and purchased shelf remain.
- Leave during each supported objective and confirm the next join resumes it.
- Start a second server with the same account; verify the active profile lock prevents a second writable session.
- Disable API access in a test copy and confirm the session-only badge/warning, normal local gameplay, and no overwrite attempt.
- Confirm the shift board starts another shift and that each completed shift updates the saved summary once.

## Gate
**G0:** approved. **G1:** desktop first-shift flow accepted by the user; mobile and multiplayer remain open. **G2:** implementation ready for manual verification, not yet passed.
