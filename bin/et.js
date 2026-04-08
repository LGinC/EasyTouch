#!/usr/bin/env node

const cp = require("node:child_process");
const { resolvePlatformBinaryPath } = require("./platform-package");

function fail(message) {
  process.stderr.write(`et: ${message}\n`);
  process.exit(1);
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
