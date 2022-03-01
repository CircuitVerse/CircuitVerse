# Contributing to Circuitverse

- We expect contributors to abide by our underlying [Code of Conduct](https://github.com/CircuitVerse/CircuitVerse/blob/master/code-of-conduct.md) . All discussions about this project must be respectful and harassment-free.
- Remember that communication is the lifeblood of any Open Source project. We are all working on this together, and we are all benefiting from this software.
- It's very easy to misunderstand one another in asynchronous, text-based conversations. When in doubt, assume everyone has the best intentions.
- If you feel anyone has violated our Code of Conduct, you should anonymously contact the team with our abuse report form via [Slack](https://circuitverse.org/slack), necessary action will be taken by the team.

## Issue label

Please note:  If you wanted to work on an issue, let us know by leaving a comment on the issue. If someone is already assigned or working on the issue, do not try to start working without asking in a thread. Also let us know later if you are no longer working on it.

- `maintainers` label are internal tasks that will be completed by a Circuitverse core team member. 
- [good first issue](https://github.com/CircuitVerse/CircuitVerse/labels/good%20first%20issue) labeled issues are meant for newer developers.
- [feature](https://github.com/CircuitVerse/CircuitVerse/labels/%F0%9F%8C%9F%20feature) labeled issues are meant to propose new features.
- [bugs](https://github.com/CircuitVerse/CircuitVerse/labels/%F0%9F%90%9E%20bug) labeled issues are meant to have errors in existing code base.
- [domumentation](https://github.com/CircuitVerse/CircuitVerse/labels/documentation) labeled issues are meant to have typo errors in documentation.
- [Simulator](https://github.com/CircuitVerse/CircuitVerse/labels/simulator) issues are meant specifically in the scope of circuitverse simulator.
- [platform](https://github.com/CircuitVerse/CircuitVerse/labels/platform) labeled issues are meant specifically in the scope of circuitverse website.
- `difficulty: easy` issues are usually confined to isolated areas of existing code.
- `difficulty: medium` issues sometimes entail new features and might affect a significant area of the codebase, but aren't overly complex.
- `difficulty: hard` issues are typically far-reaching, and might need architecture decisions during implementation. This label might also denote highly complex issues.
- `duplicate` labeled issues are meant to be already existing issue in the repository.
- `priority: less` labeled issues are meant to have priority comparatavily lesser than other issues.
- `priority: medium` labeled issues are meant to have priority comparatively intermediate than other issues.
- `priority: high` labeled issues are meant to have the highest priority and need to fix as soon as possible.
- `help wanted` labeled issues signify that the contributor requires help with something specific in the issue and your help is very much appreciated.

## Creating an issue.

- Check if the issue you are going to propose is not duplicate of another issue.
- Open a new issue according to type i.e., if issue is a bug open a new issue by clicking on `Get Started` in the scope of `Bug Report`.
- Give a precise and meaningful name of the issue.
- Describe your issue as good as possible that may ease the process of issue-reviewing by a community member.

## How to contribute

1. Fork the project and clone it to your local machine. Follow the [setup](https://github.com/CircuitVerse/CircuitVerse/blob/master/SETUP.md) guideline.
2. Always take a pull from the remote repository to your master branch to keep it at par with the main project(updated repository).
        
        git pull upstream master
        
3. Create a branch. For example, if you are going to work on issue number #44 (which is, say, a new feature for ‘forgot password’ management):

        git checkout -b forgot-password#44

    This both creates and checks out that branch in one command.  
    The feature name should provide a (short) description of the issue.

4. Update the README.md with details of changes to the interface, this includes new environment variables, exposed ports, useful file locations and container parameters.
5. Commit your changes and push it to your fork of the repository.
6. Create Pull Request (PR). Make sure to comment the issue that your PR is supposed to solve.

## Create a pull request

- Try to keep the pull requests small. A pull request should try its very best to address only a single concern.
- For work in progress pull requests, please use the Draft PR feature.
- Make sure all tests pass and add additional tests for the code you submit.
- Document your reasoning behind the changes. Explain why you wrote the code in the way you did. The code should explain what it does.
- If there's an existing issue, reference to it by adding something like `References/Closes/Fixes/Resolves #123`, where 123 is the issue number. 
- Please fill out the PR Template when making a PR.

> Please note: maintainers may close your PR if it has gone stale or if we don't plan to merge the code.

## Pull request reviews

- Requested changes must be resolved (with code or discussion) before merging.
- If you make changes to a PR, be sure to re-request a review.
- Don't repeadetely tag someone(may be it is not the right time to review your PR), be patient.
- Do not 'resolve conversation' unnecessary raised by a community member or any workflow tools(codeclimate or hound) as they may have some purpose, try to resolve the request changes and if any help wanted tag a communtiy member to give views about that.

#### PR Lebels

- `under-review` labeled PRs are under review by core team.
- `waiting for contributor` labeled PRs are meant to waiting for contributor to respond.
- `waiting for design` labeled PRs are meant to waiting for review from UI/UX core team.
- `no activity` labeled PRs are meant to have no activity in the PR from since a while.
- `blocked` labeled PRs are meant not to go ahead for review.
- `do not merge` labeled PRs are meant not to merge the PR right now(may be later).
- [awaiting-approval](https://github.com/CircuitVerse/CircuitVerse/labels/awaiting-approval) labeled PRs are meant to be waiting for other communtiy members.

## Community
Discussions about CircuitVerse issues and features take place on the repository's [Discussions](https://github.com/CircuitVerse/CircuitVerse/discussions) sections. Anybody is welcome to join these conversations. See the [README](README.md) for more information on communication channels.

### Financial Contributors

Becoming a [financial contributor](https://opencollective.com/CircuitVerse/contribute) helps us sustain our community and platform.

#### Individuals
<a href="https://opencollective.com/CircuitVerse"><img src="https://opencollective.com/CircuitVerse/individuals.svg?width=890" alt="Individual financial contributors"></a>

#### Organizations
Support this project with your organization. Your logo will show up here with a link to your website. [[Contribute](https://opencollective.com/CircuitVerse/contribute)]

<a href="https://opencollective.com/CircuitVerse/organization/0/website"><img src="https://opencollective.com/CircuitVerse/organization/0/avatar.svg" alt="Organization 1"></a>

### Code Contributors

This project exists because of all the people who have [contributed]((CONTRIBUTING.md)).
<a href="https://github.com/CircuitVerse/CircuitVerse/graphs/contributors"><img src="https://opencollective.com/CircuitVerse/contributors.svg?width=890&button=false" alt="Code contributors" /></a>

## The bottom line

We are all humans trying to work together to improve the community. Always be kind and appreciate the need for tradeoffs. ❤️
