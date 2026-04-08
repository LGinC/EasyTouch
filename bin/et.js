#!/usr/bin/env node

const cp = require("node:child_process");
const path = require("node:path");
const { resolvePlatformBinaryPath } = require("./platform-package");

function fail(message) {
  process.stderr.write(`et: ${message}\n`);
  process.exit(1);
}

function runInit() {
  const initScriptPath = path.resolve(__dirname, "..", "init.js");
  const result = cp.spawnSync(process.execPath, [initScriptPath, ...process.argv.slice(3)], {
    stdio: "inherit",
  });

  if (result.error) {
    fail(`Failed to run init.js: ${result.error.message}`);
  }

  process.exit(result.status ?? 1);
}

if (process.argv[2] === "init") {
  runInit();
}

function resolveBinaryPath() {
  try {
    return resolvePlatformBinaryPath(__dirname, {
      autoInstall: true,
      logPrefix: "et",
    });
  } catch (error) {
    fail(error.message);
  }
}

const result = cp.spawnSync(resolveBinaryPath(), process.argv.slice(2), {
  stdio: "inherit",
});

if (result.error) {
  fail(result.error.message);
}

process.exit(result.status ?? 1);
