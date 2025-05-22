# GitHub Setup Guide

This document provides step-by-step instructions for setting up the Othello iOS project on GitHub with full CI/CD integration.

## Repository Setup

### 1. Create GitHub Repository

```bash
# On GitHub.com:
# 1. Go to https://github.com/new
# 2. Repository name: othello-ios
# 3. Description: "Modern, accessible Othello game for iOS built with SwiftUI"
# 4. Set to Public (or Private if preferred)
# 5. DO NOT initialize with README, .gitignore, or license (we already have these)
# 6. Click "Create repository"
```

### 2. Connect Local Repository

```bash
# Add GitHub as remote origin
git remote add origin https://github.com/YOUR_USERNAME/othello-ios.git

# Verify remote
git remote -v

# Push initial commit
git push -u origin main
```

### 3. Configure Repository Settings

#### Branch Protection Rules
1. Go to **Settings → Branches**
2. Click **Add rule** for `main` branch
3. Configure:
   - [x] Require a pull request before merging
   - [x] Require approvals (1 reviewer minimum)
   - [x] Dismiss stale PR approvals when new commits are pushed
   - [x] Require review from code owners
   - [x] Require status checks to pass before merging
   - [x] Require branches to be up to date before merging
   - [x] Require conversation resolution before merging
   - [x] Include administrators

#### Required Status Checks
Add these status checks (they'll appear after first CI run):
- `Test Suite / Test Suite`
- `Quality Gates / Quality Gates`
- `Dependency Audit / Dependency Audit`

## CI/CD Configuration

### 1. GitHub Actions Setup
The CI/CD pipeline is already configured in `.github/workflows/ci.yml` and will run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` branch

### 2. Secrets Configuration
Add these secrets in **Settings → Secrets and variables → Actions**:

#### Required Secrets (for future iOS builds)
```
APPLE_DEVELOPER_TEAM_ID=YOUR_TEAM_ID
APPLE_DEVELOPER_CERTIFICATE_P12=BASE64_ENCODED_CERTIFICATE
APPLE_DEVELOPER_CERTIFICATE_PASSWORD=CERTIFICATE_PASSWORD
APPLE_DEVELOPER_PROVISIONING_PROFILE=BASE64_ENCODED_PROFILE
APP_STORE_CONNECT_API_KEY_ID=YOUR_KEY_ID
APP_STORE_CONNECT_API_ISSUER_ID=YOUR_ISSUER_ID
APP_STORE_CONNECT_API_PRIVATE_KEY=YOUR_PRIVATE_KEY
```

#### Optional Secrets (for notifications)
```
SLACK_WEBHOOK_URL=YOUR_SLACK_WEBHOOK
DISCORD_WEBHOOK_URL=YOUR_DISCORD_WEBHOOK
```

### 3. Environment Setup
Create environments in **Settings → Environments**:

#### Development Environment
- **Name**: `development`
- **Protection rules**: None
- **Environment secrets**: Development-specific secrets

#### Staging Environment  
- **Name**: `staging`
- **Protection rules**: Required reviewers (1)
- **Environment secrets**: Staging-specific secrets

#### Production Environment
- **Name**: `production`
- **Protection rules**: Required reviewers (2), Deploy to production branches only
- **Environment secrets**: Production secrets

## Code Coverage Integration

### 1. Codecov Setup
1. Go to [codecov.io](https://codecov.io)
2. Sign in with GitHub
3. Add the repository
4. Copy the upload token
5. Add as repository secret: `CODECOV_TOKEN`

### 2. Code Climate (Optional)
1. Go to [codeclimate.com](https://codeclimate.com)
2. Add repository
3. Configure maintainability and test coverage
4. Add webhook for PR comments

## Issue and Project Management

### 1. Issue Labels
Create these labels in **Issues → Labels**:

#### Type Labels
- `bug` (Red) - Something isn't working
- `enhancement` (Blue) - New feature or request  
- `documentation` (Yellow) - Improvements to documentation
- `accessibility` (Purple) - Accessibility improvements
- `performance` (Orange) - Performance improvements
- `security` (Red) - Security-related issues

#### Priority Labels
- `priority: low` (Light gray)
- `priority: medium` (Yellow)
- `priority: high` (Orange)
- `priority: critical` (Red)

#### Component Labels
- `component: models` (Green)
- `component: ui` (Blue)
- `component: ai` (Purple)
- `component: testing` (Yellow)
- `component: ci-cd` (Gray)

### 2. GitHub Projects (Optional)
1. Go to **Projects → New project**
2. Choose "Board" layout
3. Add columns:
   - 📋 **Backlog** - New issues and ideas
   - 🚀 **Ready** - Issues ready for development
   - 👥 **In Review** - Pull requests under review  
   - ✅ **Done** - Completed work

### 3. Milestones
Create milestones for major releases:
- **v1.0.0 - Core Game** (Phase 3 completion)
- **v1.1.0 - AI Enhancements** (Phase 5 completion)
- **v1.2.0 - Polish & Performance** (Phase 7 completion)
- **v2.0.0 - Multiplayer** (Server integration)

## Security Configuration

### 1. Security Advisories
Enable in **Settings → Security & analysis**:
- [x] Dependency graph
- [x] Dependabot alerts
- [x] Dependabot security updates
- [x] Code scanning with CodeQL

### 2. Dependabot Configuration
Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "swift"
    directory: "/"
    schedule:
      interval: "weekly"
    commit-message:
      prefix: "chore"
      prefix-development: "chore"
      include: "scope"
```

## Documentation Setup

### 1. GitHub Pages (for documentation)
1. Go to **Settings → Pages**
2. Source: Deploy from a branch
3. Branch: `main` / `docs` folder
4. Custom domain: `othello-ios.github.io` (optional)

### 2. Wiki Configuration
1. Enable Wiki in **Settings → Features**
2. Add pages for:
   - Game Rules
   - Development Guide
   - Accessibility Guidelines
   - Contribution Guidelines

## Release Management

### 1. Release Automation
The CI/CD pipeline includes automatic release creation based on conventional commits.

### 2. Release Templates
Configure release templates in **Settings → Repository → Release**:

```markdown
## What's Changed
<!-- Auto-generated list of changes -->

## Breaking Changes
<!-- List any breaking changes -->

## New Features
<!-- List new features -->

## Bug Fixes  
<!-- List bug fixes -->

## Performance Improvements
<!-- List performance improvements -->

## Accessibility Improvements
<!-- List accessibility improvements -->

## Full Changelog
**Full Changelog**: https://github.com/YOUR_USERNAME/othello-ios/compare/v1.0.0...v1.1.0
```

## Monitoring and Analytics

### 1. Repository Insights
Monitor these metrics in **Insights**:
- **Traffic**: Page views and clones
- **Contributors**: Contribution activity
- **Community Standards**: Repository health
- **Dependency Graph**: Security vulnerabilities

### 2. GitHub Actions Usage
Monitor CI/CD usage in **Settings → Billing and plans → Plans and usage**

## Team Management

### 1. Collaborators
Add team members in **Settings → Collaborators**:
- **Admin**: Full access
- **Maintain**: Manage without admin access
- **Write**: Push access
- **Triage**: Manage issues and PRs
- **Read**: View and clone only

### 2. Code Owners
The `.github/CODEOWNERS` file defines who must review changes:

```
# Global owners
* @YOUR_USERNAME

# Documentation
*.md @YOUR_USERNAME
/docs/ @YOUR_USERNAME

# Core models  
/OthelloApp/Models/ @YOUR_USERNAME

# CI/CD
/.github/ @YOUR_USERNAME
```

## Verification Checklist

After setup, verify:

- [ ] Repository is properly configured
- [ ] Branch protection rules are active
- [ ] CI/CD pipeline runs successfully
- [ ] Code coverage reporting works
- [ ] Issue templates are available
- [ ] PR template is configured
- [ ] Security scanning is enabled
- [ ] Dependabot is configured
- [ ] Release automation works

## Troubleshooting

### Common Issues

1. **CI fails on first run**
   - Check secrets are properly configured
   - Verify Swift version in workflow matches Xcode

2. **Code coverage not reporting**
   - Verify CODECOV_TOKEN is set
   - Check coverage file generation in CI logs

3. **Branch protection too strict**
   - Temporarily disable for initial setup
   - Re-enable after first successful CI run

### Getting Help

- **GitHub Support**: [support.github.com](https://support.github.com)
- **Actions Documentation**: [docs.github.com/actions](https://docs.github.com/actions)
- **Swift Package Manager**: [swift.org/package-manager](https://swift.org/package-manager)

---

**Next Steps**: Once GitHub is configured, you can proceed with Phase 3 development and invite collaborators to contribute to the project.