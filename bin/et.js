#!/usr/bin/env node

const cp = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const packageByPlatform = {
  win32: "easytouch-windows",
  linux: "easytouch-linux",
  darwin: "easytouch-macos",
};

const archDirectoryByNodeArch = {
  x64: "x64",
  arm64: "arm64",
};

function fail(message) {
  process.stderr.write(`et: ${message}\n`);
  process.exit(1);
}

function getAvailableArchitectures(binRoot) {
  try {
    return fs
      .readdirSync(binRoot, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .map((entry) => entry.name)
      .sort();
  } catch {
    return [];
  }
}

function resolveBinaryPath() {
  const packageName = packageByPlatform[process.platform];
  if (!packageName) {
    fail(`Unsupported platform '${process.platform}'.`);
  }

  const archDirectory = archDirectoryByNodeArch[process.arch];
  if (!archDirectory) {
    fail(`Unsupported architecture '${process.arch}' on platform '${process.platform}'.`);
  }

  let packageJsonPath;
  try {
    packageJsonPath = require.resolve(`${packageName}/package.json`);
  } catch (error) {
    fail(`The platform package '${packageName}' is not installed. Install that platform package on this host.`);
  }

  const packageRoot = path.dirname(packageJsonPath);
  const binaryName = process.platform === "win32" ? "et.exe" : "et";
  const binRoot = path.join(packageRoot, "bin");
  const binaryPath = path.join(binRoot, archDirectory, binaryName);
  if (!fs.existsSync(binaryPath)) {
    const availableArchitectures = getAvailableArchitectures(binRoot);
    const availableMessage = availableArchitectures.length
      ? ` Available architectures: ${availableArchitectures.join(", ")}.`
      : "";
    fail(
      `The platform package '${packageName}' is missing '${binaryName}' for architecture '${archDirectory}'.${availableMessage}`
    );
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
