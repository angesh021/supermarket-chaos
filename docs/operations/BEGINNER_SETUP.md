# Beginner setup — Roblox Studio and local source

This guide separates source scaffolding from Roblox account/project setup. No Roblox place has been created or linked by this repository yet.

## Prerequisites
1. Install Roblox Studio from Roblox and sign in. Use a test experience during development; keep production credentials private.
2. Install Git for Windows.
3. Install Rojo and the Roblox Studio Rojo plugin from their official sources, matching versions. Confirm with `rojo --version` and the Studio plugin status.
4. From the repository folder, run `rokit install` to install the versions pinned in `rokit.toml` (Rojo 7.7.0, Selene 0.32.0, StyLua 2.5.0).

## Run the game from a built file (simplest)
1. Open PowerShell in the repository folder.
2. Run `rokit install` once if this is a fresh setup.
3. Run `rojo build default.project.json -o build.rbxlx`.
4. Open `build.rbxlx` in Roblox Studio.
5. Press **Play** to run a local test session. Inspect Studio's Output window. Do not publish the place.

## Live-sync with Rojo
1. Open PowerShell in the repository folder.
2. Run `rokit install` once if this is a fresh setup.
3. Run `rojo serve default.project.json` and leave that window open. By default it listens on `localhost:34872`.
4. Open a place in Roblox Studio, then select **Plugins → Rojo → Connect**.
5. Connect to host `localhost`, port `34872`. This is the same computer; no public host or Roblox server is needed.
6. Press **Play** in Studio. Saving Luau source files will live-sync into Studio.

Use a Rojo 7 Studio plugin with the Rojo 7.7.0 CLI. The project's exact `default.project.json` mapping is built and should be used for both build and serve. If you change the port, enter the port printed by the terminal in the plugin. Do not publish the place.

## Troubleshooting and safety
- If a binary says home directory not found, verify the Windows user profile environment and tool-specific configuration; do not copy credentials or auth files into the repository.
- Keep `.rbxlx`/`.rbxl` development place files only if deliberately versioned; never commit account tokens or private data.
- Production publication, DataStore access, analytics and commerce require separate environment configuration and approval. Use a separate test experience and test products for any later verification.

## Phase 2 profile testing
DataStore is disabled in Studio by default. For persistence checks, create/use a private test experience that is separate from any future production experience, publish that test experience yourself, then in Studio open **File → Experience Settings → Security**, enable **Enable Studio Access to API Services**, and save. Studio then uses that test experience's DataStores; do not enable this against live player data. The game labels a profile `SESSION ONLY` when DataStore access fails, and does not write that fallback profile to the store.

Use the same Roblox account for the save/rejoin check. Complete an action, stop the local Play session, start it again, and confirm the saved shift resumes. To check the session lease, join the same test experience from a second server using the same account while the first session is still active; the second session must not load a writable copy. Disable Studio API access in the test experience to verify normal session-only play and the HUD warning.
- Record exact tool versions and successful commands in `docs/PROJECT_STATUS.md` after they are verified.
