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
- Record exact tool versions and successful commands in `docs/PROJECT_STATUS.md` after they are verified.
