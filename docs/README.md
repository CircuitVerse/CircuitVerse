## Setup CircuitVerse API Documentation

### Prerequisites
Make sure the following tools are installed before continuing:

- **Linux or macOS**  
  Windows may work but is not officially supported.
- **Ruby** (version 3.1.0 or newer)
- **Bundler**

Install Bundler if it is not already available:

```bash
gem install bundler
```

---

### Getting Started

1. Complete the main CircuitVerse setup first by following the instructions in `SETUP.md`.

2. Navigate to the API documentation directory:

```bash
cd CircuitVerse/docs
```

3. Initialize and start the Slate documentation server.

#### Run Locally

```bash
bundle install
bundle exec middleman server
```

#### Run with Vagrant (Optional)

```
vagrant up
```

4. Open your browser and visit:

```text
http://localhost:4567

> ⚠️ **Note:** If `bundle exec middleman server` fails, ensure dependencies are installed by running `bundle install` again.

