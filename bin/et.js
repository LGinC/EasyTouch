#!/usr/bin/env node

const cp = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const packageByPlatform = {
  win32: "easytouch-windows",
  linux: "easytouch-linux",
  darwin: "easytouch-macos",
};

function fail(message) {
  process.stderr.write(`et: ${message}\n`);
  process.exit(1);
}

function resolveBinaryPath() {
  const packageName = packageByPlatform[process.platform];
  if (!packageName) {
    fail(`Unsupported platform '${process.platform}'.`);
  }

  let packageJsonPath;
  try {
    packageJsonPath = require.resolve(`${packageName}/package.json`);
  } catch (error) {
    fail(`The platform package '${packageName}' is not installed. Reinstall 'easytouch' on this host.`);
  }

  const binaryName = process.platform === "win32" ? "et.exe" : "et";
  const binaryPath = path.join(path.dirname(packageJsonPath), "bin", binaryName);
  if (!fs.existsSync(binaryPath)) {
    fail(`The platform package '${packageName}' is missing '${binaryName}'.`);
  }

  return binaryPath;
}

const result = cp.spawnSync(resolveBinaryPath(), process.argv.slice(2), {
  stdio: "inherit",
});

if (result.error) {
  fail(result.error.message);
}

process.exit(result.status ?? 1);
