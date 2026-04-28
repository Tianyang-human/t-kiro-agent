# t-kiro-agent

A spec-driven development workflow for Claude Code and Cursor. Four agents that walk a feature from requirements through design, task breakdown, and implementation — each stage gated by explicit user approval.

Inspired by [Amazon Kiro](https://kiro.dev/)'s spec-driven approach.

## Why

Coding agents often jump straight to implementation and miss important requirements, architectural decisions, or edge cases. This workflow forces a disciplined pause between stages:

1. **Requirements** — what are we building, for whom, and what's out of scope?
2. **Design** — how will it work technically? What alternatives were considered?
3. **Tasks** — what are the discrete, testable chunks of work?
4. **Execution** — implement one main task at a time with verification gates.

Each stage produces a durable markdown artifact outside the repository (under `~/.kiro/`), and each stage requires an explicit `APPROVE` from the user before moving on.

## Workflow

The recommended entry point is the unified router:

```
/kiro <feature>                →  routes to the right phase based on `.status`
/kiro <feature> --redo <phase> →  re-run a previously approved phase
```

Under the hood, `/kiro` dispatches to one of four phase agents:

```
requirements  →  requirements-agent  →  ~/.kiro/<repo>/<feature>/requirements.md  →  APPROVE
design        →  design-agent        →  ~/.kiro/<repo>/<feature>/design.md        →  APPROVE
tasks         →  tasks-agent         →  ~/.kiro/<repo>/<feature>/tasks.md         →  APPROVE
execute       →  execution-agent     →  implements one main task at a time
```

Each phase is also exposed as a standalone slash command (`/requirements`, `/design`, `/tasks`, `/execute`) if you prefer to drive phases manually.

Specs live under `~/.kiro/<repo-name>/<feature-name>/` (outside the repository). They are intentionally **not** committed to the repo — they are for the developer's benefit during feature planning, not part of the codebase history.

A small `.status` file in the same directory tracks the current phase and approval state, so re-running `/kiro <feature>` resumes mid-flight rather than starting over.

## Install

### Claude Code and Cursor

Both read `~/.claude/agents/` and `~/.claude/commands/`.

```bash
git clone https://github.com/Tianyang-human/t-kiro-agent.git
cd t-kiro-agent
./install.sh
```

Then fully restart Claude Code or reload the Cursor window (`Cmd+Shift+P` → `Developer: Reload Window`).

### Manual install

Copy the four agent files to `~/.claude/agents/` and the five command files (`requirements.md`, `design.md`, `tasks.md`, `execute.md`, `kiro.md`) to `~/.claude/commands/`.

## Usage

From within any git repository:

```
/kiro <feature-name>
# Routes to the right phase based on ~/.kiro/<repo>/<feature>/.status:
#   - no .status        → starts requirements
#   - draft_written     → re-displays the existing draft and re-prompts for APPROVE
#   - approved          → confirms before advancing to the next phase
#   - approved + edits  → warns about staleness and re-prompts for APPROVE
```

To re-run a previously approved phase:

```
/kiro <feature-name> --redo <phase>
# <phase> is one of: requirements | design | tasks | execute
```

`<feature-name>` is a short slug (e.g., `user-auth`, `bulk-export`). The same slug is used across all four stages.

## Agents

| Agent | Writes to | Purpose |
|---|---|---|
| `requirements-agent` | `~/.kiro/<repo>/<feature>/requirements.md` | Gather user stories, edge cases, constraints, success criteria, out-of-scope items |
| `design-agent` | `~/.kiro/<repo>/<feature>/design.md` | Produce component breakdown, data models, API contracts, mermaid diagrams, alternatives considered |
| `tasks-agent` | `~/.kiro/<repo>/<feature>/tasks.md` | Break design into hierarchical main tasks and sub-tasks with acceptance criteria |
| `execution-agent` | source files in the repo | Implement one main task at a time; run tests + compile after each; pause for user confirmation |

### Guardrails

- Agents may **only** write to `~/.kiro/` except for `execution-agent`, which edits source files
- Agents do **not** `git add` or `git commit` anything unless explicitly asked
- Each stage requires `APPROVE` before progressing
- `execution-agent` runs package-level tests and compile after every main task; failing verification blocks completion

### Workspace conventions

If `AGENT.md` and/or `CLAUDE.md` exist in the repository, every agent reads them at startup and binds the resulting coding-style and testing rules to its output. When both files exist and disagree, `CLAUDE.md` wins. If neither exists, agents proceed silently.

### Superpower skills

Agents auto-invoke relevant [`obra/superpowers`](https://github.com/obra/superpowers) skills where they add value:

| Agent | Skills |
|---|---|
| `requirements-agent` | `brainstorming`, `writing-plans` |
| `design-agent` | `brainstorming` |
| `tasks-agent` | `writing-plans` |
| `execution-agent` | `test-driven-development`, `verification-before-completion`, `systematic-debugging`, `finishing-a-development-branch` |

If the `obra/superpowers` plugin isn't installed, agents log an inline note and continue without the skill.

## Uninstall

```bash
./uninstall.sh
```

Removes the four agents and five commands from `~/.claude/`. Your `~/.kiro/` specs are preserved.

## Customizing for your own workflow

The path `~/.kiro/` is a convention. If you prefer in-repo specs (e.g., `docs/specs/`), edit the four agent files and the four command files to reference your preferred location. Be consistent across both — agents and commands must agree.

## Repository layout

```
t-kiro-agent/
├── subagents/     # Claude Code / Cursor subagent definitions (installed into ~/.claude/agents/)
├── commands/      # Slash command definitions (installed into ~/.claude/commands/)
├── install.sh
├── uninstall.sh
└── README.md
```

> The directory is named `subagents/` rather than `agents/` because `agents/` is a restricted path under Instacart's GitHub push protection. At install time, these files are placed into `~/.claude/agents/`.

## Development

Edit the files in `subagents/` and `commands/`, then re-run `./install.sh` to apply.
