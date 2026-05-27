# Mobile SDK Consumer Skills

Agent skills for **developers building apps with Mobile SDK**. Installable via the [vercel-labs/skills](https://github.com/vercel-labs/skills) CLI:

```bash
npx skills add forcedotcom/SalesforceMobileSDK-Templates
```

The `npx skills` CLI scans this `./skills/` directory for subdirectories containing a `SKILL.md`.

| Skill | Description |
|---|---|
| `ios-mobile-sdk/` | Comprehensive guide for integrating Salesforce Mobile SDK into iOS Swift applications. Uses progressive disclosure to guide you through scenarios: creating new apps, adding SDK authentication, SmartStore (encrypted database), MobileSync (cloud sync), and biometric authentication (Face ID / Touch ID). |
| `android-mobile-sdk/` | Comprehensive guide for integrating Salesforce Mobile SDK into Android Kotlin applications. Uses progressive disclosure to guide you through scenarios: creating new apps, adding SDK authentication, SmartStore (encrypted database), MobileSync (cloud sync), and biometric authentication (fingerprint / face / iris). |

> SDK-developer skills (for contributors working on the Mobile SDK itself) live in [`.claude/skills/`](../.claude/skills/) and are not published through this CLI.

## Adding a New Consumer Skill

Create a subdirectory with a `SKILL.md`:

```markdown
---
name: my-skill
description: What this skill does and when to use it
---

# My Skill
...
```

## Using the Skills

Each skill uses **progressive disclosure** to guide you through the right scenario:

1. Invoke the skill for your platform (`ios-mobile-sdk` or `android-mobile-sdk`)
2. Answer the initial question about your scenario (create new app, add SDK, add SmartStore, etc.)
3. Follow the section-specific instructions for your use case

All scenarios for a platform are now in one skill, making it easier to discover capabilities and navigate between related tasks.

## Testing a Consumer Skill

Before shipping a new or updated consumer skill, exercise it against a real blank app to verify it produces a working result end-to-end.

### Process

1. **Create a blank app** using `xcodegen` (iOS) or Gradle (Android) in a temp directory
2. **Apply the skill** — run Claude Code in that directory and invoke the skill, selecting the appropriate scenario
3. **Build** — `xcodebuild` (iOS) or `./gradlew assembleDebug` (Android) to confirm no compile errors
4. **Run on simulator/emulator** — verify the skill's core behaviour (e.g. login screen appears, SDK initializes)
5. **Test additional scenarios** — if the skill covers multiple scenarios (e.g., add SmartStore after SDK), test the progression
6. **Clean up** — delete the temp directory after validation

### Example: testing `ios-mobile-sdk` (Add SDK scenario)

```bash
mkdir /tmp/SkillTest && cd /tmp/SkillTest
# ... write project.yml, generate with xcodegen ...

# Apply the skill (Claude Code invokes it), select "Add Mobile SDK" scenario, then build:
xcodebuild -workspace SkillTest.xcworkspace \
  -scheme SkillTest \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

Expected: `** BUILD SUCCEEDED **` and Salesforce login screen on first run.

### What to check

- [ ] Project builds without errors
- [ ] Login screen appears on first launch
- [ ] Post-login screen is reachable
- [ ] No crash on cold start
- [ ] Progressive disclosure flow is clear and easy to navigate
- [ ] Each scenario's instructions are self-contained and work independently
