# Morpheus Aruba Tasks - Copilot Instructions

## Copilot / AI agent quick instructions — Morpheus Aruba Tasks

Short guide so AI coding agents are productive immediately. This file is generated from
`docs/AGENTS.md` by `tools/generate-copilot-instructions.sh`; prefer updating `docs/AGENTS.md`
if you need persistent changes.

Key points (actionable):

- Big picture: this repo implements Bash-based Aruba/Morpheus automations. The core libraries live
  in `lib/commons.sh` and `scripts/commons.sh`. Top-level script families are under `scripts/`
  (e.g. `scripts/aruba/vrf`, `scripts/aruba/cli`). Examples and workflows are under `examples/`.

- Header + structure: every executable script must include the exact header with `# Script:` and
  `# Description:` lines, `#!/bin/bash`, `source "$(dirname "${BASH_SOURCE[0]}")/commons.sh"` as
  the first functional line, implement a `main()` function and include the standard sourcing
  protection block (see `tests/*.bats` for automated checks).

- Logging & lifecycle: all functions must call `_log_func_enter "fn_name"` as their first line and
  `_log_func_exit_ok` / `_log_func_exit_fail` before returning. Use logging helpers from the
  commons libs: `log_info`, `log_error`, `log_success`, `log_warn`, `log_debug`.

- Naming & style: filenames use kebab-case (e.g. `create-vrf-aoscx.sh`), functions use snake_case
  (e.g. `check_dependencies()`), globals are UPPER_SNAKE and locals lower_snake.

- Validations & tests: run tests with `./tests/run-tests.sh` (requires `bats`). All scripts are
  expected to pass `shellcheck`. Markdown is validated with `markdownlint`. The BATS tests
  enforce header, logging and structure rules (see `tests/*.bats`).

- Generator: `tools/generate-copilot-instructions.sh` produces this file from `docs/AGENTS.md` and
  `copilot-codegen-instructions.json`. Editing this file directly is temporary — update
  `docs/AGENTS.md` for persistent changes.

- Quick file map (where to look first):
  - `docs/AGENTS.md` — canonical, full agent rules
  - `lib/commons.sh`, `scripts/commons.sh` — logging, OS/dependency helpers
  - `scripts/aruba/*` and `examples/` — canonical script patterns and argument handling
  - `tests/*.bats`, `tests/run-tests.sh` — enforcement and CI expectations
  - `tools/generate-copilot-instructions.sh` — generator used to refresh this file

- Concrete workflow snippets:
  - Run all tests: `./tests/run-tests.sh`
  - Run a single BATS file: `./tests/run-tests.sh test_create-vrf.bats`
  - Run shellcheck: `shellcheck scripts/aruba/vrf/create-vrf-aoscx.sh`
  - Regenerate instructions: `bash tools/generate-copilot-instructions.sh`

If you want a narrower copy of rules (for example: VRF scripts only, or CI-specific linting
commands), tell me which area to expand and I will update this file.
