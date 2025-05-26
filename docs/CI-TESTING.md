# 🧪 CI/CD Pipeline Testing Guide

This guide provides multiple ways to test your GitHub Actions CI/CD pipeline locally before pushing changes.

## 🚀 Quick Start

### 1. **Quick Health Check** (30 seconds)
```bash
./scripts/quick-ci-check.sh
```
- Tests XcodeGen, build, SwiftLint, and basic tests
- Perfect for rapid feedback during development

### 2. **Full Pipeline Simulation** (2-3 minutes)
```bash
./scripts/test-ci-locally.sh
```
- Mimics the exact GitHub Actions workflow
- Tests all CI steps including coverage and artifacts
- Most comprehensive local testing

## 📋 Testing Options

### Option 1: Manual Pipeline Simulation
**Best for: Complete accuracy with your exact environment**

```bash
# Run the full simulation
./scripts/test-ci-locally.sh

# Clean up afterward
rm -rf Othello.xcodeproj TestResults.xcresult *.json
```

**What it tests:**
- ✅ XcodeGen project generation
- ✅ Project validation 
- ✅ Xcode build process
- ✅ SwiftLint quality checks
- ✅ Swift Testing framework
- ✅ Test result bundling
- ✅ Code coverage generation
- ✅ Performance benchmarks

### Option 2: GitHub Actions Local Runner (act)
**Best for: Testing actual workflow files**

```bash
# Setup (one-time)
./scripts/setup-act.sh

# Run specific job
act -W .github/workflows/ci.yml -j test

# Run full workflow
act -W .github/workflows/ci.yml
```

⚠️ **Note:** Limited macOS compatibility in Linux containers

### Option 3: Pre-commit Hook
**Best for: Continuous validation**

The pre-commit hook automatically runs essential checks:
- XcodeGen project generation
- Xcode build validation
- SwiftLint quality gates
- Basic test execution

## 🔍 What Each Script Tests

### Quick Check (`quick-ci-check.sh`)
| Step | Time | Purpose |
|------|------|---------|
| XcodeGen | 5s | Project generation works |
| Build | 10s | Code compiles successfully |
| SwiftLint | 5s | Code quality standards |
| Model Tests | 10s | Core functionality works |

### Full Simulation (`test-ci-locally.sh`)
| Step | Time | Purpose |
|------|------|---------|
| Environment Setup | 2s | Clean CI environment |
| Dependencies | 1s | Required tools available |
| Project Generation | 5s | XcodeGen workflow |
| Project Validation | 2s | Target/scheme verification |
| Build | 15s | Complete compilation |
| SwiftLint | 10s | Quality gate validation |
| Full Test Suite | 60s | All tests with coverage |
| Swift Testing Verification | 5s | Framework compatibility |
| Coverage Generation | 10s | Report creation |
| Performance Tests | 15s | Benchmark validation |

## 🎯 When to Use Each Method

### Before Every Commit
```bash
./scripts/quick-ci-check.sh
```

### Before Major Pushes
```bash
./scripts/test-ci-locally.sh
```

### Testing Workflow Changes
```bash
act -W .github/workflows/ci.yml
```

### Debugging CI Issues
1. Run full simulation locally
2. Compare output with GitHub Actions logs
3. Check environment differences

## 🐛 Troubleshooting

### Common Issues

**XcodeGen not found:**
```bash
brew install xcodegen
```

**SwiftLint not found:**
```bash
brew install swiftlint
```

**Build failures:**
- Check MainActor/concurrency issues
- Verify all dependencies available
- Run clean build: `rm -rf Othello.xcodeproj && xcodegen generate`

**Test failures:**
- Run tests individually to isolate issues
- Check for timing-dependent tests
- Verify test data/mocks are correct

### Environment Differences

| Local | GitHub Actions | Solution |
|-------|----------------|----------|
| Your Xcode version | Xcode 16.2.0 | Update local Xcode |
| Your macOS version | macOS latest | Check compatibility |
| Local SwiftLint config | CI SwiftLint config | Use same .swiftlint.yml |

## 📊 Success Criteria

Your pipeline is ready when:
- ✅ Quick check completes without errors
- ✅ Full simulation matches expected CI behavior  
- ✅ All artifacts generated correctly (coverage, test results)
- ✅ Performance benchmarks within acceptable limits
- ✅ SwiftLint violations below threshold

## 🚀 Best Practices

1. **Test before every push:** Use quick check as minimum
2. **Simulate major changes:** Use full simulation for CI changes
3. **Keep scripts updated:** Sync with .github/workflows/ci.yml
4. **Monitor CI metrics:** Track build times, test coverage, violations
5. **Clean up artifacts:** Don't commit temporary test files

## 📈 Monitoring

After pushing, monitor your pipeline at:
`https://github.com/dweekly/othello-claude-4/actions`

Expected timing:
- **Dependencies & Setup:** ~2 minutes
- **Build & Test:** ~3 minutes  
- **Quality Gates:** ~1 minute
- **Total Pipeline:** ~6 minutes