# Contributing to dbscan_dart

Thank you for considering contributing to dbscan_dart! This document outlines the process for contributing to the project and the standards we follow.

## Table of Contents

- [Contributing to dbscan\_dart](#contributing-to-dbscan_dart)
  - [Table of Contents](#table-of-contents)
  - [Code of Ethics](#code-of-ethics)
  - [Getting Started](#getting-started)
  - [Development Workflow](#development-workflow)
  - [Pull Request Process](#pull-request-process)
  - [Coding Standards](#coding-standards)
  - [Testing](#testing)
  - [Documentation](#documentation)
  - [Commit Messages](#commit-messages)

## Code of Ethics

All contributors are expected to adhere to our [Code of Ethics](CODE_OF_ETHICS.md). Please read it before contributing.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally

   ```bash
   git clone https://github.com/yourusername/dbscan_dart.git
   cd dbscan_dart
   ```

3. Add the original repository as a remote

   ```bash
   git remote add upstream https://github.com/helpisdev/dbscan_dart.git
   ```

4. Install dependencies

   ```bash
   dart pub get
   ```

## Development Workflow

1. Create a new branch for your feature or bugfix

   ```bash
   git checkout -b feature/your-feature-name
   ```

   or

   ```bash
   git checkout -b fix/issue-you-are-fixing
   ```

2. Make your changes, following our [coding standards](#coding-standards)

3. Write or update tests as needed

4. Run tests to ensure they pass

   ```bash
   dart test
   ```

5. Update documentation as needed

6. Commit your changes using [conventional commits](#commit-messages)

## Pull Request Process

1. Update your fork to include the latest changes from the upstream repository

   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. Push your branch to your fork

   ```bash
   git push origin feature/your-feature-name
   ```

3. Create a pull request through the GitHub interface

4. Ensure your PR includes:
   - A clear description of the changes
   - Any relevant issue numbers (using the format `Fixes #123`)
   - Tests for new functionality
   - Updated documentation

5. Address any feedback from code reviews

6. Once approved, your PR will be merged by a maintainer

## Coding Standards

We follow the style guidelines outlined in our [STYLEGUIDE.md](STYLEGUIDE.md) and [STYLEGUIDE_DART.md](STYLEGUIDE_DART.md) files. Please read these documents before contributing.

Key points:

- Use 2-space indentation
- No lines over 80 characters in length
- No tabs
- Follow Dart's official style guide
- Write code that is readable and maintainable through the year 2050

## Testing

- All new code should include appropriate tests
- We use Behavioral Driven Development as our main testing strategy
- Every new feature should be accompanied by a corresponding BDD feature
- Check code coverage to ensure all new code is tested

## Documentation

- Document all public APIs
- Keep documentation up-to-date with code changes
- Follow the documentation guidelines in our style guide
- Use clear, concise language

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/) for our commit messages. This helps us maintain clear history and automate versioning.

Format: `type(scope): description`

Types include:

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code changes that neither fix bugs nor add features
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `build`: Changes to build system or dependencies
- `ci`: Changes to CI configuration
- `chore`: Other changes that don't modify src or test files
- `revert`: Reverts a previous commit
- `merge`: Merges two branches

Example: `feat(algorithm): implement density-based clustering`

Thank you for contributing to dbscan_dart!
