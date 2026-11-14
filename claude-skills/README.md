# claude-skills

Personal Claude Code skills, versioned here so every machine bootstrapped with
`my_setup` (or synced with `CLAUDE_SKILLS_ONLY=yes`) ends up with the same
`~/.claude/skills/`.

## Adding a skill

1. Create a folder here named after the skill, e.g. `claude-skills/my-skill/`.
2. Add a `SKILL.md` inside it (plus any supporting files) following Claude
   Code's skill format: YAML frontmatter with `name` and `description`, then
   the skill body.
3. Commit and push.

Each top-level folder under `claude-skills/` is copied as-is into
`~/.claude/skills/<folder-name>/` by `install.sh`.

## Syncing an existing VPS

To pull the latest skills onto a machine without re-running the full
bootstrap:

```sh
curl -fsSL https://raw.githubusercontent.com/rapha4lx/my_setup/main/install.sh | CLAUDE_SKILLS_ONLY=yes sh
```

This only clones this repo and refreshes `~/.claude/skills/`; it does not
touch packages, zsh, Docker, etc.
