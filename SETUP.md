# Setting up CircuitVerse
[Back to `README.md`](README.md)

Please go through the [Contribution Guidelines](CONTRIBUTING.md) before going forward with any development. This helps us keep the process streamlined and results in better PRs.

If you have any setup problems, please ensure you have read through all the instructions have all the required software installed before creating an issue.

---

## Note
If you are facing any issues with the setup, first check out the [troubleshooting guide](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/troubleshooting_guide.md) and if you are still facing issues, feel free to ask in the [slack](https://github.com/CircuitVerse/CircuitVerse/blob/master/README.md#community) channel.

## Installation
There are several ways to run your own instance of CircuitVerse:

| Operating System | Method | Documentation |
| --- | --- | --- |
| Any | GitHub Codespaces | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/remote_development.md#github-codespaces) |
| Mac | Native Setup | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/manual/mac.md) |
| Mac | Docker Development Environment | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/docker.md#macos) |
| Linux | Native Setup | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/manual/linux.md) |
| Linux | Docker Development Environment | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/docker.md#linux) |
| Windows | Docker Development Environment | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/docker.md#windows) |
| Windows | WSL Setup | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/manual/windows-wsl.md) |
| Windows | Native Setup | [Click Here](https://github.com/CircuitVerse/CircuitVerse/tree/master/installation_docs/manual/windows.md) |

## Tools Setup
| Tool | Documentation Link |
| --- | --- |
| Code Auto Completion | [Click Here](https://github.com/CircuitVerse/CircuitVerse/blob/master/LSP-SETUP.md) |
| Ruby Debugger | [Click Here](https://github.com/CircuitVerse/CircuitVerse/blob/master/DEBUGGER-SETUP.md) |

## Tests
Before making a pull request, it is a good idea to check that all tests are passing locally.

- To run the system tests, run `bundle exec rspec`.
- To run the simulator tests, run `yarn run test`.

**Note:** To pass the system tests, you need the [Chrome Browser](https://www.google.com/chrome/) installed. For docker based setup, you can ignore this.

## CircuitVerse API documentation
CircuitVerse API documentation is available at - https://api.circuitverse.org/

If you like to setup CircuitVerse API documentation locally, refer [docs/README.md](docs/README.md)

---

## VAPID API Keys (Required)

After integrating Vuesim, generating VAPID API keys is required before running the development server.

### Generating VAPID API Keys

VAPID keys are used for authenticating push notifications.

1. Install `web-push` globally:
```bash
npm install -g web-push

2. Generate the VAPID keys:
```bash
web-push generate-vapid-keys

```md
3. Copy the generated keys and add them to your environment variables:
```env
VAPID_PUBLIC_KEY=<YOUR_PUBLIC_KEY>
VAPID_PRIVATE_KEY=<YOUR_PRIVATE_KEY>