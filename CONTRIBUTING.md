# Contributing to CircuitVerse

We're thrilled that you're interested in contributing! This guide will help you get started.

## Code of Conduct

We expect all contributors to abide by our [Code of Conduct](https://github.com/CircuitVerse/CircuitVerse/blob/master/code-of-conduct.md). Assume good intentions, be respectful, and if you experience violations, report them via [Slack](https://circuitverse.org/slack).

## Before You Start

1. Review our [Product Statement](https://github.com/CircuitVerse/CircuitVerse/wiki/Product-Statement) - We focus on circuit simulation, community interaction, and educational tools. We prioritize maintainability, efficient development, and UX over UI complexity.
2. Follow the [setup guide](https://github.com/CircuitVerse/CircuitVerse/blob/master/SETUP.md)
3. Check existing issues to avoid duplicates
4. Join [Slack](https://circuitverse.org/slack) or [Discussions](https://github.com/CircuitVerse/CircuitVerse/discussions) for questions

### ⚠️ Simulator Migration

**The `simulator` directory no longer accepts contributions.** All simulator work has moved to [cv-frontend-vue](https://github.com/CircuitVerse/cv-frontend-vue). Platform contributions are still welcome here.

## Understanding Labels

**Status:**
- `pending triage` - New issue not yet verified. **Don't work on these until the label is removed**
- `good first issue` - Great for newcomers
- `help wanted` - Contributor needs assistance

**Type:**
- `🌟 feature` - New features/enhancements
- `🐞 bug` - Errors in existing code
- `documentation` - Docs improvements

**Priority:** `high` > `medium` > `less`

**Difficulty:** `easy` (isolated changes) → `medium` (broader changes) → `hard` (architectural changes)

**Scope:**
- `platform` - Website issues (contributions welcome)
- `simulator` - DEPRECATED (use cv-frontend-vue)

## How to Claim Issues

1. Find an issue **without** the `pending triage` label
2. Check no one else has claimed it
3. Leave a comment: "I'd like to work on this"
4. Start working immediately - no need to wait for assignment
5. Comment if you can no longer work on it

## Creating an Issue

1. Search for duplicates first
2. Use the appropriate template (Bug Report, Feature Request)
3. Write a clear, descriptive title
4. Provide detailed information (steps to reproduce, screenshots, use cases)
5. For features, explain alignment with our Product Statement

Your issue will get the `pending triage` label. Once maintainers verify and remove it, contributors can claim the issue.

> [!NOTE]  
If the issue is about minor spelling mistakes, you may create pull request directly, do not create separate issue for that

## Contributing Code

### Setup and Workflow

```bash
# Fork on GitHub, then clone
git clone https://github.com/YOUR_USERNAME/CircuitVerse.git
cd CircuitVerse

# Add upstream
git remote add upstream https://github.com/CircuitVerse/CircuitVerse.git

# Keep your fork updated
git fetch upstream
git checkout master
git pull upstream master

# Create feature branch (format: feature-name#issue-number)
git checkout -b forgot-password#44

# After changes, push to your fork
git push origin forgot-password#44
```

### Commit Convention

```bash
# Format: <type>: <description> (#issue-number)
git commit -m "feat: add password reset (#44)"
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Use present tense, imperative mood, keep first line under 72 characters.

### Testing

```bash
# Run tests before pushing
bundle exec rspec
rubocop  # if applicable
```

## Pull Request Guidelines

### Checklist
- ✅ All tests pass
- ✅ Code follows project style
- ✅ Documentation updated
- ✅ Commits follow convention
- ✅ PR addresses single concern
- ✅ PR template filled out
- ✅ Screenshots for UI changes

### Creating a PR
1. Click "Compare & pull request" on GitHub
2. Reference the issue: `Fixes #44` or `Closes #44`
3. Fill out the PR template completely
4. Request review from maintainers

### Best Practices
- Keep PRs small and focused
- Use Draft PRs for work in progress
- Don't resolve reviewer comments unless asked
- Re-request review after making changes
- Be patient - reviews typically take 3-7 days

### PR Labels
- `under-review` - Being reviewed by core team
- `waiting for contributor` - Awaiting your response
- `waiting for design` - Awaiting UI/UX review
- `no activity` - Inactive for 2+ months (may be closed)
- `blocked` - Cannot proceed with review
- `do not merge` - Should not merge yet

## Merge Conflicts

```bash
git checkout master && git pull upstream master
git checkout your-feature-branch
git merge master
# Resolve conflicts, then:
git add . && git commit -m "resolve merge conflicts"
git push origin your-feature-branch
```

## Getting Help

- Comment on the issue/PR with `@username`
- Ask in [Slack](https://circuitverse.org/slack)
- Post in [Discussions](https://github.com/CircuitVerse/CircuitVerse/discussions)
- Add `help wanted` label

## Community

Join our discussions and connect with contributors:
- **GitHub Discussions** - Questions and general discussions
- **Slack** - Real-time community chat
- **Issues/PRs** - Technical discussions

### Support Us

Become a [financial contributor](https://opencollective.com/CircuitVerse/contribute) to help sustain our community.

<a href="https://opencollective.com/CircuitVerse"><img src="https://opencollective.com/CircuitVerse/individuals.svg?width=890" alt="Contributors"></a>

## Quick Tips

- Always work on feature branches, never on master
- Keep your fork's master synced with upstream
- Write descriptive commit messages
- Test thoroughly before submitting
- Be respectful and patient
- Ask questions when unsure

## The Bottom Line

We are all humans working together to improve this community. Always be kind and appreciate the need for tradeoffs. ❤️

Thank you for contributing to CircuitVerse!
