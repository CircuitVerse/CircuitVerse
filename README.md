<img src="/app/assets/images/cvlogo.svg" alt="The CircuitVerse logo" width="736"/> </br></br>
[![Financial Contributors on Open Collective](https://opencollective.com/CircuitVerse/all/badge.svg?label=Financial+Contributors&style=for-the-badge&logo=open+collective)](https://opencollective.com/CircuitVerse) 
[![CircleCI Status](https://img.shields.io/circleci/build/github/CircuitVerse/CircuitVerse/master?label=circleci&style=for-the-badge&logo=circleci)](https://circleci.com/gh/CircuitVerse/CircuitVerse)
[![Coveralls Coverage Status](https://img.shields.io/coveralls/github/CircuitVerse/CircuitVerse/master?label=coveralls&style=for-the-badge&logo=coveralls)](https://coveralls.io/github/CircuitVerse/CircuitVerse?branch=master)
[![Rails Version](https://img.shields.io/badge/Rails-7.0.8.7-red.svg?style=for-the-badge&logo=ruby)](https://rubyonrails.org/)
[![Ruby Version](https://img.shields.io/badge/Ruby-3.2+-red.svg?style=for-the-badge&logo=ruby)](https://www.ruby-lang.org/)
[![Node.js Version](https://img.shields.io/badge/Node.js-18+-green.svg?style=for-the-badge&logo=node.js)](https://nodejs.org/)
[![Vite](https://img.shields.io/badge/Vite-5.4+-purple.svg?style=for-the-badge&logo=vite)](https://vitejs.dev/)

-----

[CircuitVerse](https://circuitverse.org) is a free, open-source platform which allows users to construct digital logic circuits online. We also offer the [Interactive Book](https://learn.circuitverse.org) which teaches users on the fundamentals of modern, digital circuits. Please also see our [documentation](https://docs.circuitverse.org) or [GitHub Wiki](https://github.com/CircuitVerse/CircuitVerse/wiki/).

## 🚀 Tech Stack

**Backend:**
- **Rails 7.0.8.7** - Web framework
- **Ruby 3.2+** - Programming language
- **PostgreSQL** - Database
- **Redis** - Caching and background jobs
- **Sidekiq** - Background job processing
- **Puma** - Web server

**Frontend:**
- **Vite 5.4+** - Build tool and dev server
- **Stimulus 3.2+** - JavaScript framework
- **Bootstrap 5.3+** - CSS framework
- **Sass** - CSS preprocessor
- **ESBuild** - JavaScript bundler

**Development Tools:**
- **Docker & Docker Compose** - Containerization
- **GitHub Codespaces** - Cloud development environment
- **Jest** - JavaScript testing
- **RSpec** - Ruby testing
- **RuboCop** - Code linting
- **ESLint** - JavaScript linting

## 🎯 Key Features

- **Interactive Circuit Simulator** - Build and simulate digital logic circuits
- **Multi-language Support** - Available in 11 languages including Arabic, Bengali, German, Spanish, French, Hindi, Japanese, Malayalam, Marathi, Nepali, and English
- **Social Features** - User profiles, project sharing, comments, and voting
- **LMS Integration** - Learning Management System support via LTI
- **API Access** - RESTful API for external integrations
- **Real-time Collaboration** - WebSocket support for live collaboration
- **Mobile Responsive** - Works seamlessly across all devices
- **Verilog RTL Synthesis** - Support for Verilog circuit creation (optional)

## 🎥 Getting Started with CircuitVerse

To help new contributors get started, we've created a comprehensive video guide:

**"Getting Started with CircuitVerse"** covers:
- Introduction to CircuitVerse and its technical architecture
- Step-by-step setup using GitHub Codespaces
- High-level walkthrough of the codebase structure
- Contribution guidelines and best practices

🎥 [Watch the "Getting Started with CircuitVerse" Video](https://youtu.be/TUdHWUdz_-8)  
*(Click the link above to watch the video on YouTube.)*

## 🛠️ Quick Start

### Option 1: GitHub Codespaces (Recommended for New Contributors)
1. Fork the repository
2. Click the "Code" button
3. Select "Create Codespace"
4. Wait for setup to complete
5. Run `./bin/dev` to start the development server

### Option 2: Local Development
See [`SETUP.md`](SETUP.md) for detailed installation instructions for your operating system.

### Option 3: Docker Development
```bash
# Clone the repository
git clone https://github.com/CircuitVerse/CircuitVerse.git
cd CircuitVerse

# Start the development environment
docker-compose up -d

# Access the application at http://localhost:3000
```

## 🧪 Testing

Before submitting a pull request, ensure all tests pass:

```bash
# Run Ruby/Rails tests
bundle exec rspec

# Run JavaScript/Simulator tests
yarn test

# Run linting
bundle exec rubocop
yarn lint
```

## 🌐 Community

We would love to hear from you! Join our community:

[![Slack](https://img.shields.io/badge/chat-on_slack-purple.svg?style=for-the-badge&logo=slack)](https://circuitverse.org/slack)
[![Discussions](https://img.shields.io/badge/discussions-github-blue.svg?style=for-the-badge&logo=github)](https://github.com/CircuitVerse/CircuitVerse/discussions)

## 📚 Documentation

- **[Setup Guide](SETUP.md)** - Detailed installation instructions
- **[Contributing Guidelines](CONTRIBUTING.md)** - How to contribute to CircuitVerse
- **[API Documentation](https://api.circuitverse.org/)** - REST API reference
- **[Interactive Book](https://learn.circuitverse.org)** - Learn digital circuits
- **[Main Documentation](https://docs.circuitverse.org)** - Comprehensive documentation

## 🔧 Development Tools

- **[LSP Setup](LSP-SETUP.md)** - Code completion and IntelliSense
- **[Debugger Setup](DEBUGGER-SETUP.md)** - Ruby debugging configuration
- **[Troubleshooting Guide](installation_docs/troubleshooting_guide.md)** - Common issues and solutions

## 🚀 Deployment

For production deployment, see the Docker configuration in `Dockerfile.production` and `docker-compose.yml`.

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 🧪 Testing with BrowserStack

This project is tested with BrowserStack for cross-browser compatibility.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code of Conduct
- Issue reporting and labeling
- Pull request process
- Development workflow
- Testing requirements

## 📊 Project Statistics

- **Languages:** Ruby, JavaScript, HTML, CSS, SCSS
- **Database:** PostgreSQL with Redis caching
- **Background Jobs:** Sidekiq with Redis
- **Search:** Solr (optional)
- **File Storage:** AWS S3 compatible
- **Monitoring:** OpenTelemetry distributed tracing

---

**CircuitVerse** - Empowering the next generation of digital circuit designers! 🚀
