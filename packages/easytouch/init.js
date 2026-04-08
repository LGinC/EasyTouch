#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");
const { binaryNameForPlatform, resolvePlatformBinaryPath } = require("./bin/platform-package");

function printUsage() {
  const binaryName = binaryNameForPlatform();
  process.stdout.write(
    [
      "Usage:",
      "  node init.js [--output <path>] [--force]",
      "",
      "Behavior:",
      `  For @whuanle/easytouch, installs the current platform package if needed, then copies '${binaryName}' by default.`,
      "  Use --output to write to a different file or directory.",
    ].join("\n") + "\n"
  );
}

function fail(message) {
  process.stderr.write(`et init: ${message}\n`);
  process.exit(1);
}

function parseArgs(argv) {
  let output = null;
  let force = false;

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") {
      printUsage();
      process.exit(0);
    }
    if (arg === "--force") {
      force = true;
      continue;
    }
    if (arg === "--output") {
      index += 1;
      if (index >= argv.length) {
        fail("Missing value for --output.");
      }
      output = argv[index];
      continue;
    }
    fail(`Unknown argument '${arg}'.`);
  }

  return { output, force };
}

function binaryName() {
  return binaryNameForPlatform();
}

function resolveBinaryPath() {
  try {
    return resolvePlatformBinaryPath(__dirname, {
      autoInstall: true,
      logPrefix: "et init",
    });
  } catch (error) {
    fail(error.message);
  }
}

function resolveOutputPath(requestedOutput) {
  let outputPath = requestedOutput
    ? path.resolve(process.cwd(), requestedOutput)
    : path.join(__dirname, binaryName());

  if (fs.existsSync(outputPath)) {
    const stat = fs.statSync(outputPath);
    if (stat.isDirectory()) {
      outputPath = path.join(outputPath, binaryName());
    }
  }

  if (process.platform === "win32" && path.extname(outputPath) === "") {
    outputPath = `${outputPath}.exe`;
  }

  return outputPath;
}

function initializeBinary(sourcePath, destinationPath, force) {
  const resolvedSource = path.resolve(sourcePath);
  const resolvedDestination = path.resolve(destinationPath);
  if (resolvedSource === resolvedDestination) {
    process.stdout.write(`et init: binary already available at ${resolvedDestination}\n`);
    return;
  }

  if (fs.existsSync(resolvedDestination) && !force) {
    fail(`Destination '${resolvedDestination}' already exists. Use --force to overwrite it.`);
  }

  fs.mkdirSync(path.dirname(resolvedDestination), { recursive: true });
  fs.copyFileSync(resolvedSource, resolvedDestination);
  if (process.platform !== "win32") {
    fs.chmodSync(resolvedDestination, 0o755);
  }

  process.stdout.write(`et init: copied ${resolvedSource} -> ${resolvedDestination}\n`);
}

const options = parseArgs(process.argv.slice(2));
initializeBinary(resolveBinaryPath(), resolveOutputPath(options.output), options.force);