#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const repoRoot = path.dirname(fileURLToPath(import.meta.url));

function printUsage() {
  console.log(`Usage:
  node release-tag.mjs <version-or-tag> [--remote <name>] [--allow-dirty] [--skip-branch-push] [--dry-run]
  npm run release:tag -- <version-or-tag>

Examples:
  node release-tag.mjs 1.0.9
  node release-tag.mjs v1.0.9 --remote origin
  node release-tag.mjs 1.0.9 --dry-run`);
}

function fail(message) {
  console.error(`release-tag: ${message}`);
  process.exit(1);
}

function quoteArg(value) {
  if (/^[A-Za-z0-9_./:=@-]+$/.test(value)) {
    return value;
  }
  return JSON.stringify(value);
}

function formatCommand(command, args) {
  return [command, ...args].map(quoteArg).join(" ");
}

function run(command, args, options = {}) {
  const {
    capture = true,
    allowFailure = false,
    dryRun = false,
  } = options;

  const printable = formatCommand(command, args);
  if (dryRun) {
    console.log(`[dry-run] ${printable}`);
    return { status: 0, stdout: "", stderr: "" };
  }

  const result = spawnSync(command, args, {
    cwd: repoRoot,
    encoding: "utf8",
    stdio: capture ? "pipe" : "inherit",
  });

  if (result.error) {
    fail(`${printable}\n${result.error.message}`);
  }

  if (result.status !== 0 && !allowFailure) {
    const stderr = (result.stderr || "").trim();
    const stdout = (result.stdout || "").trim();
    const detail = stderr || stdout;
    fail(`${printable}${detail ? `\n${detail}` : ""}`);
  }

  return {
    status: result.status ?? 1,
    stdout: result.stdout || "",
    stderr: result.stderr || "",
  };
}

function parseArgs(argv) {
  const options = {
    remote: "origin",
    allowDirty: false,
    skipBranchPush: false,
    dryRun: false,
  };

  let versionOrTag = null;

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];

    switch (arg) {
      case "-h":
      case "--help":
        printUsage();
        process.exit(0);
        break;
      case "--remote":
        index += 1;
        if (index >= argv.length) {
          fail("Missing value for --remote.");
        }
        options.remote = argv[index];
        break;
      case "--allow-dirty":
        options.allowDirty = true;
        break;
      case "--skip-branch-push":
        options.skipBranchPush = true;
        break;
      case "--dry-run":
        options.dryRun = true;
        break;
      default:
        if (arg.startsWith("-")) {
          fail(`Unknown option '${arg}'.`);
        }
        if (versionOrTag !== null) {
          fail(`Unexpected extra argument '${arg}'.`);
        }
        versionOrTag = arg;
        break;
    }
  }

  if (!versionOrTag) {
    const packageJsonPath = path.join(repoRoot, "package.json");
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
    versionOrTag = packageJson.version;
    console.log(`release-tag: using package.json version ${versionOrTag}`);
  }

  return { versionOrTag, options };
}

function normalizeTag(versionOrTag) {
  const trimmed = versionOrTag.trim();
  if (!trimmed) {
    fail("Version or tag cannot be empty.");
  }
  if (/\s/.test(trimmed)) {
    fail(`Tag cannot contain whitespace: '${trimmed}'.`);
  }
  return trimmed.startsWith("v") ? trimmed : `v${trimmed}`;
}

function ensureGitRepository() {
  run("git", ["rev-parse", "--show-toplevel"], { capture: true });
}

function ensureRemoteExists(remote) {
  run("git", ["remote", "get-url", remote], { capture: true });
}

function ensureCleanWorktree(allowDirty) {
  if (allowDirty) {
    return;
  }

  const status = run("git", ["status", "--porcelain"], { capture: true });
  if (status.stdout.trim()) {
    fail("Working tree is not clean. Commit or stash changes first, or use --allow-dirty.");
  }
}

function getCurrentBranch() {
  const result = run("git", ["rev-parse", "--abbrev-ref", "HEAD"], { capture: true });
  return result.stdout.trim();
}

function ensureTagDoesNotExist(tag, remote) {
  const local = run("git", ["rev-parse", "-q", "--verify", `refs/tags/${tag}`], {
    capture: true,
    allowFailure: true,
  });
  if (local.status === 0) {
    fail(`Local tag '${tag}' already exists.`);
  }

  const remoteCheck = run("git", ["ls-remote", "--tags", remote, `refs/tags/${tag}`], {
    capture: true,
    allowFailure: true,
  });
  if (remoteCheck.stdout.trim()) {
    fail(`Remote tag '${tag}' already exists on '${remote}'.`);
  }
}

function main() {
  const { versionOrTag, options } = parseArgs(process.argv.slice(2));
  const tag = normalizeTag(versionOrTag);

  ensureGitRepository();
  ensureRemoteExists(options.remote);
  ensureCleanWorktree(options.allowDirty);
  ensureTagDoesNotExist(tag, options.remote);

  const branch = getCurrentBranch();
  if (!options.skipBranchPush && branch === "HEAD") {
    fail("Detached HEAD detected. Use --skip-branch-push if you only want to push the tag.");
  }

  console.log(`release-tag: target tag ${tag}`);
  console.log(`release-tag: remote ${options.remote}`);

  if (!options.skipBranchPush) {
    run("git", ["push", options.remote, branch], {
      capture: false,
      dryRun: options.dryRun,
    });
  }

  run("git", ["tag", "-a", tag, "-m", `Release ${tag}`], {
    capture: false,
    dryRun: options.dryRun,
  });

  run("git", ["push", options.remote, `refs/tags/${tag}`], {
    capture: false,
    dryRun: options.dryRun,
  });

  console.log(`release-tag: pushed ${tag} to ${options.remote}`);
}

main();