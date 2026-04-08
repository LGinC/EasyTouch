#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const archDirectoryByNodeArch = {
  x64: "x64",
  arm64: "arm64",
};

function printUsage() {
  process.stdout.write(
    [
      "Usage:",
      "  node init.js [--output <path>] [--force]",
      "",
      "Behavior:",
      "  Copies the current Linux binary into the package directory as 'et' by default.",
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

function getAvailableArchitectures() {
  try {
    return fs
      .readdirSync(path.join(__dirname, "bin"), { withFileTypes: true })
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

  const sourcePath = path.join(__dirname, "bin", archDirectory, "et");
  if (!fs.existsSync(sourcePath)) {
    const availableArchitectures = getAvailableArchitectures();
    const availableMessage = availableArchitectures.length
      ? ` Available architectures: ${availableArchitectures.join(", ")}.`
      : "";
    fail(`The package is missing 'et' for architecture '${archDirectory}'.${availableMessage}`);
  }

  return sourcePath;
}

function resolveOutputPath(requestedOutput) {
  let outputPath = requestedOutput
    ? path.resolve(process.cwd(), requestedOutput)
    : path.join(__dirname, "et");

  if (fs.existsSync(outputPath)) {
    const stat = fs.statSync(outputPath);
    if (stat.isDirectory()) {
      outputPath = path.join(outputPath, "et");
    }
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
  fs.chmodSync(resolvedDestination, 0o755);
  process.stdout.write(`et init: copied ${resolvedSource} -> ${resolvedDestination}\n`);
}

const options = parseArgs(process.argv.slice(2));
initializeBinary(resolveBinaryPath(), resolveOutputPath(options.output), options.force);