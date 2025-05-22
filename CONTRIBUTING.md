# Contributing to Othello iOS

Thank you for your interest in contributing to Othello iOS! This document provides guidelines for contributing to the project.

## Development Workflow

### Prerequisites

- Xcode 15.0+ with iOS 17+ SDK
- Swift 5.9+
- SwiftLint (install with `brew install swiftlint`)
- Git with configured user name and email

### Getting Started

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/your-username/othello-ios.git
   cd othello-ios
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feat/your-feature-name
   ```

3. **Install dependencies and verify setup**
   ```bash
   swift build
   swift test
   ```

### Development Guidelines

Please read our comprehensive development guidelines:

- **[AGENTS.md](AGENTS.md)** - AI agent development guidelines and coding standards
- **[QUALITY-EXCELLENCE.md](QUALITY-EXCELLENCE.md)** - Quality framework and standards
- **[ARCHITECTURE.md](Documentation/ARCHITECTURE.md)** - Technical architecture decisions
- **[TESTING.md](Documentation/TESTING.md)** - Testing strategies and conventions
- **[ACCESSIBILITY.md](Documentation/ACCESSIBILITY.md)** - Accessibility requirements

### Code Standards

#### Swift Style
- Follow Apple's Swift API Design Guidelines
- Use SwiftLint configuration (`.swiftlint.yml`)
- Maximum line length: 120 characters
- Prefer explicit types in public APIs
- Use meaningful variable and function names

#### Architecture
- Strict MVVM separation
- Models as immutable value types
- ViewModels as `@MainActor` `ObservableObject` classes
- Protocol-based services for testability

#### Testing Requirements
- **Minimum 90% code coverage** for all new code
- All public functions must have corresponding tests
- Use Swift Testing framework (not XCTest)
- Critical game logic requires 100% coverage

### Commit Message Format

We use [Conventional Commits](https://conventionalcommits.org/) format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Types
- `feat` - A new feature
- `fix` - A bug fix
- `docs` - Documentation only changes
- `style` - Code style changes (formatting, etc.)
- `refactor` - Code changes that neither fix bugs nor add features
- `test` - Adding or correcting tests
- `chore` - Maintenance tasks
- `ci` - CI/CD changes
- `perf` - Performance improvements
- `build` - Build system changes

#### Examples
```bash
feat: add AI difficulty selection
fix(board): correct piece capture logic
docs: update README with setup instructions
test: add comprehensive board validation tests
```

### Pull Request Process

1. **Ensure your branch is up to date**
   ```bash
   git checkout main
   git pull origin main
   git checkout your-feature-branch
   git rebase main
   ```

2. **Run all quality checks**
   ```bash
   swift build
   swift test
   swiftlint lint
   ```

3. **Create a pull request**
   - Use a descriptive title following conventional commit format
   - Fill out the PR template completely
   - Link any related issues
   - Add screenshots for UI changes
   - Ensure all CI checks pass

4. **Code Review Process**
   - At least one approving review required
   - All conversations must be resolved
   - CI/CD pipeline must pass
   - Documentation must be updated for API changes

### Pre-commit Hooks

The repository includes pre-commit hooks that will run automatically:

- **Build verification** - Ensures code compiles
- **Test execution** - All tests must pass
- **SwiftLint** - Code style validation
- **Common issue detection** - Checks for TODO/FIXME, debug prints, etc.

### CI/CD Pipeline

Our GitHub Actions pipeline includes:

- **Swift build and test** on multiple Xcode versions
- **SwiftLint** code style checking
- **Code coverage** reporting
- **Security scanning** (planned)
- **Performance benchmarks** (planned)
- **Automated releases** based on conventional commits

### Accessibility Requirements

All UI changes must meet accessibility standards:

- VoiceOver support with proper labels and hints
- Dynamic Type support
- High contrast mode compatibility
- Minimum touch target sizes (44x44 points)
- Keyboard navigation support

See [ACCESSIBILITY.md](Documentation/ACCESSIBILITY.md) for detailed requirements.

### Performance Standards

- App launch time: < 2 seconds
- AI move calculation: < 5 seconds (hard difficulty)
- Memory usage: < 150MB
- 60fps during gameplay
- Crash-free rate: > 99.9%

### Documentation Requirements

- All public APIs must have documentation comments
- Update relevant markdown files for architectural changes
- Include usage examples for complex APIs
- Update README for feature additions

### Issue Reporting

When reporting bugs:

1. **Search existing issues** first
2. **Use the issue template**
3. **Provide minimal reproduction steps**
4. **Include device/OS information**
5. **Add relevant logs or screenshots**

### Feature Requests

For new features:

1. **Check the roadmap** ([TODO.md](TODO.md) and [SERVER-TODO.md](SERVER-TODO.md))
2. **Open a discussion** first for major features
3. **Provide clear use cases**
4. **Consider accessibility implications**
5. **Think about testing requirements**

### Security

- Never commit secrets or API keys
- Follow secure coding practices
- Report security vulnerabilities privately
- Use proper input validation
- Implement appropriate error handling

### Getting Help

- **Documentation**: Start with our comprehensive docs
- **Issues**: Check existing issues and discussions
- **Code**: Reference existing implementations
- **Architecture**: See [ARCHITECTURE.md](Documentation/ARCHITECTURE.md)

### Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- Special recognition for accessibility improvements

## License

By contributing to Othello iOS, you agree that your contributions will be licensed under the same license as the project (MIT License).

Thank you for contributing to making Othello iOS an excellent, accessible game! 🎮