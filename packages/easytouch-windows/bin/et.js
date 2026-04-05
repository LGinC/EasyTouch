#!/usr/bin/env node

const cp = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const archDirectoryByNodeArch = {
  x64: "x64",
  arm64: "arm64",
};

const packageName = require(path.join(__dirname, "..", "package.json")).name;

function fail(message) {
  process.stderr.write(`et: ${message}\n`);
  process.exit(1);
}

function getAvailableArchitectures() {
  try {
    return fs
      .readdirSync(__dirname, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .map((entry) => entry.name)
      .sort();
  } catch {
    return [];
  }
}

function resolveBinaryPath() {
  const archDirectory = archDirectoryByNodeArch[process.arch];
  if (!archDirectory) {
    fail(`Unsupported architecture '${process.arch}' on platform '${process.platform}'.`);
  }

  const binaryName = process.platform === "win32" ? "et.exe" : "et";
  const binaryPath = path.join(__dirname, archDirectory, binaryName);
  if (!fs.existsSync(binaryPath)) {
    const availableArchitectures = getAvailableArchitectures();
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