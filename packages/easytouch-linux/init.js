#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const helperCommandName = "easytouch-linux";
const generatedCommandName = "et";

const supportedArchitectures = new Set(["x64", "arm64"]);

function printUsage() {
  process.stdout.write(
    [
      "Usage:",
      "  easytouch-linux init [--output <path>] [--force]",
      "  npx easytouch-linux init [--output <path>] [--force]",
      "  node init.js [init] [--output <path>] [--force]",
      "",
      "Behavior:",
      "  Copies the current Linux binary out of this package as 'et' by default.",
      "  By default, writes into this package directory.",
      "  When installed through npm, also refreshes the 'et' command if possible.",
      "  Use --output to write to a different file or directory.",
    ].join("\n") + "\n"
  );
}

function fail(message) {
  process.stderr.write(`et init: ${message}\n`);
  process.exit(1);
}

function normalizeArgs(argv) {
  if (argv[0] === "init") {
    return argv.slice(1);
  }

  return argv;
}

function parseArgs(rawArgv) {
  const argv = normalizeArgs(rawArgv);
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

function getAvailableBinaries() {
  try {
    return fs
      .readdirSync(path.join(__dirname, "bin"), { withFileTypes: true })
      .filter((entry) => entry.isFile() && entry.name.startsWith("et_"))
      .map((entry) => entry.name)
      .sort();
  } catch {
    return [];
  }
}

function binaryNameForArch(arch = process.arch) {
  if (!supportedArchitectures.has(arch)) {
    fail(`Unsupported architecture '${arch}' on platform '${process.platform}'.`);
  }

  return `et_${arch}`;
}

function resolveBinaryPath() {
  const fileName = binaryNameForArch();
  const sourcePath = path.join(__dirname, "bin", fileName);
  if (!fs.existsSync(sourcePath)) {
    const availableBinaries = getAvailableBinaries();
    const availableMessage = availableBinaries.length
      ? ` Available binaries: ${availableBinaries.join(", ")}.`
      : "";
    fail(`The package is missing '${fileName}' for architecture '${process.arch}'.${availableMessage}`);
  }

  return sourcePath;
}

function defaultOutputPath() {
  return path.join(__dirname, "et");
}

function resolveOutputPath(requestedOutput) {
  let outputPath = requestedOutput
    ? path.resolve(process.cwd(), requestedOutput)
    : defaultOutputPath();

  if (fs.existsSync(outputPath)) {
    const stat = fs.statSync(outputPath);
    if (stat.isDirectory()) {
      outputPath = path.join(outputPath, "et");
    }
  }

  return outputPath;
}

function filesAreIdentical(leftPath, rightPath) {
  try {
    const leftStat = fs.statSync(leftPath);
    const rightStat = fs.statSync(rightPath);
    if (leftStat.size !== rightStat.size) {
      return false;
    }

    const leftContent = fs.readFileSync(leftPath);
    const rightContent = fs.readFileSync(rightPath);
    return leftContent.equals(rightContent);
  } catch {
    return false;
  }
}

function initializeBinary(sourcePath, destinationPath, force) {
  const resolvedSource = path.resolve(sourcePath);
  const resolvedDestination = path.resolve(destinationPath);
  if (resolvedSource === resolvedDestination) {
    process.stdout.write(`et init: binary already available at ${resolvedDestination}\n`);
    return;
  }

  if (fs.existsSync(resolvedDestination)) {
    if (filesAreIdentical(resolvedSource, resolvedDestination)) {
      process.stdout.write(`et init: binary already available at ${resolvedDestination}\n`);
      return;
    }

    if (!force) {
      fail(`Destination '${resolvedDestination}' already exists. Use --force to overwrite it.`);
    }
  }

  fs.mkdirSync(path.dirname(resolvedDestination), { recursive: true });
  fs.copyFileSync(resolvedSource, resolvedDestination);
  fs.chmodSync(resolvedDestination, 0o755);
  process.stdout.write(`et init: copied ${resolvedSource} -> ${resolvedDestination}\n`);
}

function findNodeModulesRoot(startDir) {
  let current = path.resolve(startDir);

  while (true) {
    if (path.basename(current) === "node_modules") {
      return current;
    }

    const parent = path.dirname(current);
    if (parent === current) {
      return null;
    }
    current = parent;
  }
}

function uniquePaths(paths) {
  return [...new Set(paths.filter(Boolean).map((entry) => path.resolve(entry)))];
}

function resolveCommandBinDir(startDir, commandName) {
  const nodeModulesRoot = findNodeModulesRoot(startDir);
  if (!nodeModulesRoot) {
    return null;
  }

  const installRoot = path.dirname(nodeModulesRoot);
  const candidates = [path.join(nodeModulesRoot, ".bin")];

  if (path.basename(installRoot) === "lib") {
    candidates.push(path.join(path.dirname(installRoot), "bin"));
  }
  candidates.push(path.join(installRoot, "bin"));

  for (const candidate of uniquePaths(candidates)) {
    if (fs.existsSync(path.join(candidate, commandName))) {
      return candidate;
    }
  }

  for (const candidate of uniquePaths(candidates)) {
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }

  return null;
}

function managedCommandMarker() {
  return "EasyTouch generated by init";
}

function readTextFile(filePath) {
  try {
    return fs.readFileSync(filePath, "utf8");
  } catch {
    return null;
  }
}

function assertManagedCommandTarget(filePath, force) {
  if (!fs.existsSync(filePath)) {
    return;
  }

  const content = readTextFile(filePath);
  if (content && content.includes(managedCommandMarker())) {
    return;
  }

  if (!force) {
    fail(`Command '${filePath}' already exists. Use --force to overwrite it.`);
  }
}

function writeManagedCommand(filePath, content, force) {
  assertManagedCommandTarget(filePath, force);
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, content, "utf8");
  fs.chmodSync(filePath, 0o755);
}

function relativeShellPath(fromDir, toFile) {
  return path.relative(fromDir, toFile).split(path.sep).join("/");
}

function installGeneratedCommand(targetBinaryPath, force) {
  const binDir = resolveCommandBinDir(__dirname, helperCommandName);
  if (!binDir) {
    return;
  }

  const relativePath = relativeShellPath(binDir, path.resolve(targetBinaryPath));
  writeManagedCommand(
    path.join(binDir, generatedCommandName),
    [
      "#!/bin/sh",
      `# ${managedCommandMarker()}`,
      'basedir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)',
      `exec "$basedir/${relativePath}" "$@"`,
      "",
    ].join("\n"),
    force
  );

  process.stdout.write(`et init: updated command '${generatedCommandName}' in ${binDir}\n`);
}

const options = parseArgs(process.argv.slice(2));
const outputPath = resolveOutputPath(options.output);
initializeBinary(resolveBinaryPath(), outputPath, options.force);

if (path.resolve(outputPath) === path.resolve(defaultOutputPath())) {
  installGeneratedCommand(outputPath, options.force);
}