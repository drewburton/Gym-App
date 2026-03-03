# Project Guidelines

This project uses a multi-agent workflow defined in `.gemini/agents/`.

## Workflow Rules

- Follow the logic defined in `orchestrator.md` for task coordination.
- Delegate tasks to specialized subagents (`researcher`, `planner`, `implementer`, etc.) via their corresponding tools.
- Maintain project state in `docs/plan/workout_tracker_fixes_20250124/plan.yaml`.
- Current Plan ID: `workout_tracker_fixes_20250124`
- Use the `IMPLEMENTATION_PLAN.md` as the high-level roadmap, but manage atomic tasks via `plan.yaml`.

## Available Agents

- `orchestrator`: Project coordinator (Primary role)
- `researcher`: Codebase navigation and discovery
- `planner`: Strategic planning and task decomposition
- `implementer`: Code implementation and bug fixing
- `reviewer`: Code review and validation
- `documentation-writer`: Documentation and comments
- `devops`: Infrastructure and CI/CD
- `browser-tester`: UI and browser-based testing
- `critical-thinking`: Deep analysis and problem solving
