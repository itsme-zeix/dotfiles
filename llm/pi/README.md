# Pi setup

From the repository root:

```sh
./llm/pi/install.sh
```

Requires Node.js, npm, and `patch`. The installer installs pinned Pi packages,
applies tracked patches, and links configuration into `~/.pi/agent`.
Set `PI_CODING_AGENT_DIR` to use another agent directory.

- `AGENTS.md` links to the shared instructions.
- `skills/shared/` links to `llm/shared/skills/`.
- Pi-specific skills and extensions link from this directory.

New shared skills are available through the folder link without rerunning setup.
To sync the instructions and skill links, run `./llm/pi/update-symlinks.sh`; the installer
also calls it. Set `SHARED_DIR` to use a different shared folder.
Use `/skill:<name>` to invoke a skill. The installer preserves unrelated files
and refuses conflicting destinations.

Extensions live in `extensions/`; package patches live in `patches/`.
Authentication, sessions, settings, caches, and installed packages stay local.
Ketch is installed when missing; existing Ketch configuration is preserved.
