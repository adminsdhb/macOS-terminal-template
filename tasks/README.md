# Agent task handoffs

This directory is the shared handoff contract for work that moves between HeyClicky, local agent CLIs, and human review. Keep each task small enough that another agent can pick it up without reconstructing the conversation.

## Inputs

Create one task file per handoff. Markdown is the default format:

```md
# Task: short title

- ID: 2026-09-07-example
- Owner: agent or person
- Tool: codex, claude, copilot, gemini, or aider
- Status: ready
- Created: 2026-09-07T00:00:00Z

## Objective

One clear sentence describing the outcome.

## Context

Relevant files, decisions, links, and constraints.

## Inputs

- Files or data to inspect
- Commands or checks to run

## Expected output

The files, report, decision, or patch the next agent must produce.
```

Use repository-relative paths. Do not put secrets, credentials, or private customer data in task files.

## Running a handoff

Run the same entry point from the repository root:

```sh
./bin/run-agent codex "Read tasks/2026-09-07-example.md and complete the objective."
./bin/run-agent claude "Review the handoff in tasks/2026-09-07-example.md and report gaps."
```

The wrapper accepts the tool name followed by the task description. It only routes to known CLIs and never installs or auto-approves an agent. If a selected CLI is missing, it exits with a useful install hint instead of failing the terminal setup.

## Outputs

The agent that completes a task should update the task file or add a matching result file with:

```md
## Result

- Status: complete, blocked, or needs-review
- Completed: 2026-09-07T00:00:00Z
- Summary: What changed and why
- Files changed: repository-relative paths
- Checks run: commands and pass/fail results
- Open questions: Anything the next person must decide
```

Never claim a check passed unless it was actually run. If the task changes code, leave the working tree in a reviewable state and include the relevant test or validation command.

## Logging

Logging is opt-in so normal agent output stays clean and sensitive prompts are not written unexpectedly. Set `RUN_AGENT_LOG_FILE` when a durable transcript is useful:

```sh
RUN_AGENT_LOG_FILE=tasks/logs/2026-09-07-example.log \
  ./bin/run-agent codex "Complete the example handoff."
```

Logs include UTC start and finish times, the selected tool, the task description, combined agent output, and the exit status. Treat logs as potentially sensitive and do not commit them when they contain secrets or customer data.
