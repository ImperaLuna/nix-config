# pi-claude-code-provider

Date: 2026-09-23

Question: Is "pi-claude-code-provider", a pi extension that routes model requests through Claude Code so a Claude Pro/Max subscription can be used, real, how does it work, is it stable, and does Anthropic allow it? The claim to test: it is the "most stable & compliant" option.

## TL;DR

- It exists: npm `pi-claude-code-provider` 0.4.0 (2026-09-20), MIT, repo github.com/chem/pi-claude-code-provider, about 1.9k downloads/month, 25 stars, 1 open issue. Other packages with similar names use different methods (listed below).
- It spawns the unmodified `claude` binary in print mode (`claude -p --input-format stream-json --output-format stream-json`) once per request, replays pi's full history, and exposes pi's tools through a proposal-only MCP server that refuses to execute anything. It does not use the Agent SDK, does not read the OAuth token, and does not spoof headers. Pi's own built-in Anthropic OAuth path does spoof Claude Code headers; this package avoids that.
- Billing: Anthropic's help center says (update of June 15, 2026) that "`claude -p`, and third-party app usage still draw from your subscription's usage limits". Pi's "draws from extra usage" warning only fires for pi's built-in `anthropic` provider, not for this one.
- Compliance: no Anthropic source names this pattern. Anthropic's docs forbid third-party developers from offering Claude.ai login or routing requests through Pro/Max credentials "on behalf of their users", and the consumer terms bar automated access "except ... where we otherwise explicitly permit it". This package is the most conservative design I found, but "compliant" is the author's framing, not Anthropic's. Treat it as a gray area Anthropic could close.
- Verdict: technically the cleanest of the options and actively maintained, but it depends on undocumented Claude Code behavior, resends the whole context each turn, and has an open bug on pi 0.87.1 (the version installed here). Fine to try for personal use if you accept account risk and possible breakage.

## 1. Does it exist, and which package is which

### The package in question

| Field | Value | Source |
| --- | --- | --- |
| npm name | `pi-claude-code-provider` | `npm view pi-claude-code-provider` |
| Description | "The convenience of your Claude subscription in Pi, with the fewest possible surprises. Uses Claude Code's CLI under the hood." | npm registry |
| Repo | https://github.com/chem/pi-claude-code-provider | npm `repository.url`; GitHub API |
| Author / maintainer | GitHub user `chem`; npm maintainer `sineverbisnon` (author field `chem <sineverbisnon@gmail.com>`) | npm registry |
| License | MIT | npm registry, GitHub `licenseInfo` |
| Latest version | 0.4.0, published 2026-09-20T23:38:40Z, tag `v0.4.0` = commit `a8f89c19652338be28aab5bb80dd5c4a36e5a2b3` | npm `time`, `git log` |
| First release | 0.1.0 on 2026-07-19 (8 versions total) | npm `time` |
| Commit activity | 108 commits between 2026-07-19 and 2026-09-20; 58 of them in September | `git log` of a local clone |
| GitHub | 25 stars, 7 forks, created 2026-07-19, last push 2026-09-20, not archived | `gh repo view` |
| Issues | 1 open (#8), 4 closed; 5 PRs (2 merged) | `gh issue list`, `gh pr list` |
| Downloads | 1,912 in 2026-08-23 to 2026-09-21 | api.npmjs.org/downloads/point/last-month |
| pi.dev listing | https://pi.dev/packages/pi-claude-code-provider | search result |

The README states it was mostly machine-written: "Almost all of the docs and code were written by machines except for this introductory material" (README.md at v0.4.0, line 8).

I did not find the phrase "most stable & compliant" in the package README, DESIGN.md, npm description, or pi.dev search snippet. Its origin is unverified.

### Similarly named packages

| Package | Repo | Mechanism (from its own description or README) | Downloads, last month | Latest |
| --- | --- | --- | --- | --- |
| `pi-claude-code-provider` | chem/pi-claude-code-provider | spawns `claude -p` per request, MCP proposal bridge | 1,912 | 0.4.0, 2026-09-20 |
| `pi-claude-bridge` | elidickinson/pi-claude-bridge | "uses Claude Code (via Agent SDK) as a model provider and adds an AskClaude tool"; README: "integrates Claude Code via the Agent SDK" | 44,537 | 0.8.0, 2026-09-21 |
| `@schuettc/pi-claude-bridge` | schuettc/pi-claude-bridge | fork of the above (same description), version `0.8.0-schuettc.4` | 1,947 | 2026-09-23 |
| `@yassimba/pi-claude-bridge` | Yassimba/ai-setup | "Reviewed, pinned distribution of Pi Claude Bridge" | 117 | 0.1.3, 2026-07-16 |
| `@saccolabs/pi-claude-cli` | agustinsacco/pi-claude-cli | "routes LLM calls through the Claude Code CLI"; README: since 0.7.0 a long-lived `claude -p` process persists across turns | 3,931 | 0.8.3, 2026-09-17 |
| `claude-code-pi` | luongnv89/pi-extensions | "Bridge Claude Code CLI models into Pi strictly through claude -p" | 128 | 1.0.1, 2026-08-21 |
| `@zgltyq/pi-provider-claude` | ZGltYQ/pi-provider-claude (repo returns 404) | "Claude (Anthropic OAuth/subscription) compatibility layer ... mapping unknown flat tool names to mcp__pi__<name> on the wire". This works on pi's direct OAuth path, not through Claude Code | 86 | 1.3.3, 2026-07-21 |

Sources: `npm view <pkg>`, `npm search`, api.npmjs.org download counts, `gh api repos/...`. Issue #1 of chem's repo also names `pi-claude-cli` and `pi-doppelclaude` as sharing the same custom-api pattern.

## 2. How it works

All quotes are from https://github.com/chem/pi-claude-code-provider at tag `v0.4.0` (commit `a8f89c1`).

Stated design (README.md, line 6): "This package never imitates private OAuth traffic, does not use the Agents SDK, and does not modify Claude's internal session files. It never reads Claude credentials or uses an Anthropic API key."

The code backs this up:

- No Anthropic SDK dependency. `package.json` has no `dependencies`; peer dependencies are only `@earendil-works/pi-ai`, `@earendil-works/pi-coding-agent` and `typebox`. `grep @anthropic-ai` over `src/`, `extensions/` and `package.json` returns nothing.
- It spawns the `claude` executable. `src/claude-process.ts`, lines 75 to 83:
  ```ts
  const launch = claudeLaunch(options.installation.executable, options.args);
  const child = spawn(launch.command, launch.args, {
    cwd: options.cwd ?? options.directory,
    env: buildClaudeEnvironment({ ...launch.env, ...options.env }),
  ```
- The arguments are print mode with stream-json in and out. `src/claude-args.ts`, `baseClaudeArgs()` and `providerArgs()`:
  ```ts
  "-p", "--setting-sources", "", "--settings", SETTINGS,
  "--disable-slash-commands", "--strict-mcp-config",
  "--permission-mode", "dontAsk", "--no-chrome", "--no-session-persistence", ...
  "--mcp-config", mcpConfig, "--tools", "", "--model", model, ...
  "--input-format", "stream-json", "--output-format", "stream-json",
  "--include-partial-messages", "--verbose",
  "--system-prompt-file", prepared.systemPromptPath,
  ```
  `--tools ""` disables all of Claude Code's built-in tools. `--system-prompt-file` replaces Claude Code's system prompt with pi's.
- Auth check shells out to `claude auth status` (`src/auth.ts` line 87) and requires `authMethod === "claude.ai"`, `apiProvider === "firstParty"` and a subscription type in `pro | max | team | enterprise` (`parseAuthStatus`, lines 44 to 60). It never opens the credentials file.
- The child environment is an allowlist. `src/auth.ts` `DENIED_ENVIRONMENT` refuses to forward `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL`, `CLAUDE_CODE_OAUTH_TOKEN`, `CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, and sets `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`, `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`, `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS=1`.
- Tools: pi's tool schemas are exposed to Claude through a local MCP server that only lists tools. `bridge/mcp-proposal-server.js` lines 97 to 102:
  ```js
  if (message.method === "tools/call") {
    mark(process.env.PI_CLAUDE_TOOL_VIOLATION, "tools/call reached proposal-only MCP server\n");
    ...sendError(requestId, -32001, "Security invariant: this server proposes tools but never executes them");
  ```
  DESIGN.md "Tool proposal boundary": the provider waits for a tool proposal, "maps complete known proposals back to Pi, terminates Claude", and pi runs the tool. So pi's tools run, Claude Code's tools do not.
- Session handling: stateless. Each request serializes pi's system prompt, messages and tools into a "versioned semantic transcript" and starts a fresh `claude -p` process (DESIGN.md, "Request and transcript transport"). README "Compatibility limitation": "Claude Code's public headless protocol cannot accept arbitrary past assistant messages or tool results. The provider therefore sends Pi's current history on every request."
- Prompt caching relies on two things outside Claude Code's public surface: an undocumented settings key `totalTokensReminder: "off"` (`src/claude-args.ts` line 11; DESIGN.md calls it "an undocumented settings key ... on upstream maintainer guidance") and a hidden flag `--thinking-display` ("hidden from Claude Code's `--help` on purpose", `src/claude-args.ts`). It also inserts its own `cache_control` breakpoint with a 1 hour TTL into the prompt blocks.

What Claude Code adds that the provider cannot remove (DESIGN.md, "What Claude Code adds on its own"): a billing header block carrying the CLI version, the identity line "You are a Claude agent, built on Anthropic's Claude Agent SDK." prepended to the system prompt in print mode, and an environment block with the working directory. Claude Code also runs `git ls-files`, `git remote` and `rg --files` in the project on every launch.

For contrast, pi's own built-in Anthropic subscription path does impersonate Claude Code. In the installed pi 0.87.1, `node_modules/@earendil-works/pi-ai/dist/api/anthropic-messages.js`:

```js
// Stealth mode: Mimic Claude Code's tool naming exactly
const claudeCodeVersion = "2.1.280";
...
"user-agent": `claude-cli/${claudeCodeVersion}`,
"x-app": "cli",
...
features.push("claude-code-20250219", "oauth-2025-04-20");
...
// For OAuth tokens, we MUST include Claude Code identity
text: "You are Claude Code, Anthropic's official CLI for Claude.",
```

`pi-claude-code-provider` does none of that. It runs Anthropic's binary as published.

## 3. Stability

From the repo's own records:

- Open issue #8 (2026-09-22): "Error: Unsupported Pi message role: system" on pi v0.87.1 after the Opus 5.5 launch. The thrown message comes from `src/context-serializer.ts` line 271. The maintainer could not reproduce it on "claude code 2.1.280 / pi 0.87.1" and asked for details. Unresolved. This machine runs pi 0.87.1 and Claude Code 2.1.280.
- Closed issue #1: on pi 0.84.0 the custom api id was not registered with pi-ai's compat registry, so pi crashed after the first turn or in `-p` mode. The maintainer could not reproduce; v0.4.0 now registers the stream function with both pi and pi-ai (DESIGN.md, "Request and transcript transport").
- Closed PR #5: Claude Code `api_retry` after streaming began produced a duplicate `message_start` error. Fixed in 0.4.0 by failing the turn as retryable (`stream_interrupted`) so pi re-runs it (CHANGELOG 0.4.0; DESIGN.md "Mid-response recovery is a failure").
- CHANGELOG shows repeated breakage from Claude Code changes: 0.1.4 "Restore prompt-cache reuse broken by Claude Code 2.1.233's undocumented, changing token reminder"; 0.3.0 "On Claude Code 2.1.268 and later, Claude no longer proposes tool calls into the provider's private directory" and "Prompt caching works again on Claude Code 2.1.268 and later".
- Version coupling: minimum pi 0.86.1 and Claude Code 2.1.270; verified baseline pi 0.86.1 and Claude Code 2.1.278 (`src/compatibility.ts`). 0.4.0 made pi 0.86.1 a breaking minimum. pi 0.87.1 is newer than the verified baseline.
- Caching limits (DESIGN.md "Compatibility and performance"): a Claude Code release that adds a fourth cache breakpoint "would fail every request"; a step with about 19 or more parallel tool calls loses all cache reuse silently. Every Claude Code upgrade invalidates cached prefixes.
- Performance: one process launch per tool round trip, plus a full-history resend. DESIGN.md: "very large repositories add measurable latency to each tool round trip" because of the `rg --files` count.
- Rate limits: the provider parses `rate_limit_event` records and shows reset times (`src/stream-events.ts` line 182; README "Subscription usage"). It reports zero monetary cost because "it cannot determine subscription billing" (README).
- Features not exposed: fast mode, deliberately, because it bills usage credits (DESIGN.md; issue #6). Haiku has no effort control.
- Users' own Claude Code settings, hooks, MCP servers and CLAUDE.md are ignored (`--setting-sources ""`), by design. Admin-managed policy still applies.

Inference: the design is careful and heavily tested (about 8k lines of unit tests, paid live gates), but it sits on Claude Code's print-mode internals and pi's provider internals, both of which move weekly. Expect breakage after upgrades of either, and upgrade them together with this package.

## 4. Compliance and billing

### What Anthropic's primary sources say

Billing for `claude -p` and third-party apps. Help center, "Use the Claude Agent SDK with your Claude plan", last updated 2026-06-16 (https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan):

> Update June 15: We're pausing the changes to Claude Agent SDK usage described below. For now, nothing has changed: Claude Agent SDK, claude -p, and third-party app usage still draw from your subscription's usage limits. The previously announced monthly credit, which would have been available to eligible claimants in connection with these changes, isn't available. We're working to update the plan to better support how users build with Claude subscriptions. When we have an update, we'll share it before anything takes effect.

The paused plan would have moved "The claude -p command in Claude Code (non-interactive mode)" and "Third-party apps that authenticate with your Claude subscription through the Agent SDK" off plan limits onto a separate monthly credit, then "usage credits at standard API rates". Anthropic groups `claude -p` with the Agent SDK for billing purposes.

Authentication rules. Claude Code docs, "Legal and compliance" (https://code.claude.com/docs/en/legal-and-compliance), section "Authentication and credential use":

> OAuth authentication is intended exclusively for purchasers of Claude Free, Pro, Max, Team, and Enterprise subscription plans and is designed to support ordinary use of Claude Code and other native Anthropic applications.

> Developers building products or services that interact with Claude's capabilities, including those using the Agent SDK, should use API key authentication through Claude Console or a supported cloud provider. Anthropic does not permit third-party developers to offer Claude.ai login into their own applications, or to route requests through Free, Pro, or Max plan credentials on behalf of their users. Moreover, developers may not collect, store, or intermediate Claude.ai credentials or session tokens — sign-in to a Claude account must complete through Anthropic's own flow.

(That dash is Anthropic's, quoted verbatim.)

> Nor does it prevent an end user from signing in to the unmodified Claude Code binary with their own Claude subscription, including where a platform hosts Claude Code as described under *Can customers offer Claude Code in their products?* above.

> Anthropic reserves the right to take measures to enforce these restrictions and may do so without prior notice.

The same page, for products that run Claude Code: "The Claude Code binary must not be modified" and "Each end user must authenticate with their own Anthropic API key, Claude subscription plan credentials, or 3P inference provider credential".

Agent SDK overview (https://code.claude.com/docs/en/agent-sdk/overview):

> Unless previously approved, Anthropic does not allow third party developers to offer claude.ai login or rate limits for their products, including agents built on the Claude Agent SDK. Use the API key authentication methods described in the Quickstart instead.

Consumer Terms of Service, effective October 8, 2025 (https://www.anthropic.com/legal/consumer-terms), list of prohibited uses:

> Except when you are accessing our Services via an Anthropic API Key or where we otherwise explicitly permit it, to access the Services through automated or non-human means, whether through a bot, script, or otherwise.

Usage Policy, effective September 15, 2025 (https://www.anthropic.com/legal/aup), includes: "Engage in actions or behaviors that circumvent the guardrails or terms of other platforms or services". Nothing in it addresses subscriptions or third-party clients directly.

Usage credits (https://support.claude.com/en/articles/12429409-manage-extra-usage-for-paid-claude-plans, updated 2026-08-10): past plan limits, with usage credits enabled, "Your subsequent usage will be billed at standard API pricing rates." "Buy usage bundles" (https://support.claude.com/en/articles/14246112-buy-usage-bundles) says a bundle balance applies to "third-party products that use your Claude account", which shows Anthropic expects some third-party products to run on a Claude account.

### What pi says

The warning in pi 0.87.1 is defined in `dist/modes/interactive/interactive-mode.js` line 140:

```js
const ANTHROPIC_SUBSCRIPTION_AUTH_WARNING = "Anthropic subscription auth is active. Third-party harness usage draws from extra usage and is billed per token, not your Claude plan limits. ...";
```

It fires only when `model.provider === "anthropic"` and pi's own Anthropic auth is OAuth or an `sk-ant-oat` token (`maybeWarnAboutAnthropicSubscriptionAuth`, lines 4248 to 4270). It is about pi's built-in provider that calls the API directly with the spoofed headers shown in section 2. It does not fire for `pi-claude-code-provider`, whose provider id is different. Pi's CHANGELOG added it in 0.66.0 (2026-04-08): "Interactive Anthropic subscription auth warning ... clarifying that Anthropic third-party usage draws from extra usage and is billed per token."

I could not find a public Anthropic web page for that April 2026 change. The wording that circulated ("Starting April 4, third-party harnesses like OpenClaw connected to your Claude account will draw from extra usage instead of from your subscription") appears to come from an email to subscribers, quoted on Hacker News (news.ycombinator.com/item?id=47633464). That is a lead, not a verified primary source.

### Inference (not stated by Anthropic)

- Plan limits vs extra usage. The provider's traffic is sent by the real Claude Code binary in print mode with Claude Code's own billing header. Anthropic's June 15 update says `claude -p` usage draws from subscription limits. So requests through this provider most likely count against plan limits, not extra usage, until Anthropic changes the `claude -p` policy. The package README says the same and links the same article. I have not measured it; checking `/usage` in Claude Code or claude.ai Settings > Usage after a pi session would confirm.
- Permission. No Anthropic source mentions a user-installed wrapper that drives the user's own unmodified `claude -p`. Points in its favor: the user signs in through Anthropic's own flow, the binary is unmodified, no credential is read or intermediated, the user is not someone else's "end user", and `claude -p` with stream-json is a documented interface. Points against: the Agent SDK note forbids third parties offering "claude.ai login or rate limits for their products", which a pi provider arguably does; the legal page scopes OAuth to "ordinary use of Claude Code and other native Anthropic applications"; the consumer terms bar automated access unless "explicitly permit[ted]", and I found no explicit permission for this pattern. The April harness change and the paused June plan both show Anthropic actively moving non-interactive and third-party usage off plan limits.
- Relative risk. It is clearly lower risk than pi's built-in OAuth provider, which impersonates Claude Code on the wire, and than packages that reuse the OAuth token directly. It is similar in kind to Agent SDK bridges like `pi-claude-bridge`, since the Agent SDK also drives the Claude Code binary and Anthropic bills both the same way.
- "Most stable & compliant" is partly supported on compliance (most conservative mechanism of the packages checked) and not supported on stability (0.x, one open bug on the current pi, repeated breakage from Claude Code updates, a fifth of the downloads of `pi-claude-bridge`).

## 5. Verdict

Worth trying if you want pi's UI and tool loop with Claude models on your Max plan and accept two risks. It is the cleanest implementation of the idea: unmodified binary, no token handling, pi owns every tool call.

Risks:

- Policy risk. Anthropic has not said this use is permitted, reserves enforcement "without prior notice", and has twice moved to change how non-interactive and third-party use is billed. The billing could shift to usage credits with notice; Anthropic promised to "share it before anything takes effect". Keep usage credits off or capped so a policy change cannot silently spend money.
- Breakage risk. Relies on an undocumented setting and a hidden flag, and on pi internals. Pin versions and run `/pi-claude-code-provider-doctor` after each pi or Claude Code update. Issue #8 hits pi 0.87.1, the version this flake installs.
- Cost in quota. Full history resent every turn and one process per tool round trip. Caching reduces token cost, but you will use plan limits faster than in interactive Claude Code, and the 1 hour cache TTL doubles cache-write cost.
- Nix fit (inference). `pi install npm:...` installs into pi's own package dir at runtime, outside the flake. The provider needs `claude` on `PATH`, which `agents.claude-code` in `modules/terminal/features/llm-cli-tools.nix` already provides (2.1.280 here, above the 2.1.270 minimum).

If policy certainty matters more than pi's UI, the safe options are plain Claude Code on the subscription, or pi with an API key.

## Sources

Package and code
- npm registry metadata, `npm view pi-claude-code-provider` (and the other packages listed), 2026-09-23
- npm download counts, https://api.npmjs.org/downloads/point/last-month/pi-claude-code-provider
- Repo, https://github.com/chem/pi-claude-code-provider, tag `v0.4.0`, commit `a8f89c19652338be28aab5bb80dd5c4a36e5a2b3`: README.md, DESIGN.md, DEVELOPING.md, CHANGELOG.md, package.json, src/claude-args.ts, src/claude-process.ts, src/auth.ts, src/compatibility.ts, src/context-serializer.ts, src/stream-events.ts, bridge/mcp-proposal-server.js
- Issues and PRs: https://github.com/chem/pi-claude-code-provider/issues/8, /issues/1, /issues/6, /issues/7, /pull/5
- pi.dev listing, https://pi.dev/packages/pi-claude-code-provider
- https://github.com/elidickinson/pi-claude-bridge (README)
- https://github.com/agustinsacco/pi-claude-cli (README)

pi (installed 0.87.1, /nix/store/lwz79fpgr0jjrssggypmm54cvz5bbxsk-pi-0.87.1/lib/node_modules/@earendil-works/pi-coding-agent)
- dist/modes/interactive/interactive-mode.js, lines 140 to 143 and 4248 to 4270
- node_modules/@earendil-works/pi-ai/dist/api/anthropic-messages.js, lines 41 to 42, 692 to 730, 772, 817 to 822
- CHANGELOG.md, 0.66.0 entry; docs/settings.md line 150

Anthropic
- Use the Claude Agent SDK with your Claude plan, updated 2026-06-16, https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan
- Legal and compliance, https://code.claude.com/docs/en/legal-and-compliance
- Agent SDK overview, https://code.claude.com/docs/en/agent-sdk/overview
- CLI reference, https://code.claude.com/docs/en/cli-reference
- Consumer Terms of Service, effective 2025-10-08, https://www.anthropic.com/legal/consumer-terms
- Usage Policy, effective 2025-09-15, https://www.anthropic.com/legal/aup
- Manage usage credits for paid Claude plans, updated 2026-08-10, https://support.claude.com/en/articles/12429409-manage-extra-usage-for-paid-claude-plans
- Use Claude Code with your Pro or Max plan, updated 2026-08-19, https://support.claude.com/en/articles/11145838-use-claude-code-with-your-pro-or-max-plan
- Buy usage bundles, https://support.claude.com/en/articles/14246112-buy-usage-bundles

Leads only, not primary
- Hacker News thread quoting Anthropic's April 2026 email on third-party harnesses, https://news.ycombinator.com/item?id=47633464
