# what are they?

from what i have understood, they work similar to how LXC containers work on proxmox.
It spins up a very lightweight barebones linux virtual machine, and then, runs them as

---

## Prerequisites: Enabling `wslc`

Because `wslc` is currently an experimental feature, it is not available in the standard stable release of WSL. To use WSL Containers, you must update WSL to a pre-release version (specifically version **2.9.3.0** or newer).
To do this, open PowerShell as an Administrator and run the following command with the specific pre-release flag:

```powershell
wsl --update --pre-release
```

_(If you do not include the `--pre-release` flag, the `wslc` command will not be available or installed)._

---

## how to modify a docker compose file to work on windows.

Because `wslc` does not natively execute `docker-compose up`, you must manually translate the instructions from your `docker-compose.yml` into a `wslc run` shell command.

**Translation Guide:**

- `image: ghcr.io/immich-app/...` ➔ `wslc run ghcr.io/immich-app/...`
- `ports: - 3003:3003` ➔ `-p 3003:3003`
- `environment: - DB_HOSTNAME=...` ➔ `-e DB_HOSTNAME=...`
- `volumes: - /path/to/data:/data` ➔ `-v /path/to/data:/data`

_Example:_
If your yaml says:

```yaml
services:
  immich-machine-learning:
    image: ghcr.io/immich-app/immich-machine-learning:release
    ports:
      - 3003:3003
```

You translate that to:
`wslc run -d --name immich-machine-learning -p 3003:3003 ghcr.io/immich-app/immich-machine-learning:release`

## How to Auto-Boot `wslc` Containers on Windows

Unlike Docker's `restart: always` policy, `wslc` containers rely on the Windows host to initiate their startup because they are tied to a specific Windows User Profile.

**Steps to Auto-Boot:**

1. Configure Windows Auto-Login (e.g., via the Sysinternals `Autologon` app or `netplwiz`) so your user logs in automatically when the PC powers on.
2. Create a Windows Scheduled Task with the following properties:
   - **Trigger:** `At Logon` (specifically for your user account).
   - **Action:** Start a program.
   - **Program/script:** `"C:\Program Files\WSL\wslc.exe"`
   - **Add arguments:** `start <container-name>` (e.g., `start immich-machine-learning`).
   - **Settings:** Ensure "Start the task only if the computer is on AC power" is unchecked if running on a laptop or UPS, and disable any time limits that might kill the task.

Once configured, the exact second Windows logs you into the desktop, the Scheduled Task will fire and silently start the container in the background!
