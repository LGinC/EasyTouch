#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");

const helperCommandName = "easytouch";
const generatedCommandName = "et";

const platformIdByNodePlatform = {
  win32: "windows",
  linux: "linux",
  darwin: "macos",
};

const supportedArchitectures = new Set(["x64", "arm64"]);

function printUsage() {
  const binaryName = binaryNameForPlatform();
  process.stdout.write(
    [
      "Usage:",
      "  easytouch init [--output <path>] [--force]",
      "  npx @whuanle/easytouch init [--output <path>] [--force]",
      "  node init.js [init] [--output <path>] [--force]",
      "",
      "Behavior:",
      `  Copies the current host binary out of this package as '${binaryName}' by default.`,
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

function binaryName() {
  return binaryNameForPlatform();
}

function binaryNameForPlatform(platform = process.platform) {
  return platform === "win32" ? "et.exe" : "et";
}

function stagedBinaryName(platform = process.platform, arch = process.arch) {
  const platformId = platformIdByNodePlatform[platform];
  if (!platformId) {
    fail(`Unsupported platform '${platform}'.`);
  }

  if (!supportedArchitectures.has(arch)) {
    fail(`Unsupported architecture '${arch}' on platform '${platform}'.`);
  }

  const extension = platform === "win32" ? ".exe" : "";
  return `et_${platformId}_${arch}${extension}`;
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

function resolveBinaryPath() {
  const fileName = stagedBinaryName();
  const sourcePath = path.join(__dirname, "bin", fileName);

  if (!fs.existsSync(sourcePath)) {
    const availableBinaries = getAvailableBinaries();
    const availableMessage = availableBinaries.length
      ? ` Available binaries: ${availableBinaries.join(", ")}.`
      : "";
    fail(
      `The package is missing '${fileName}' for platform '${process.platform}' and architecture '${process.arch}'.${availableMessage}`
    );
  }

  return sourcePath;
}

function defaultOutputPath() {
  return path.join(__dirname, binaryName());
}

function resolveOutputPath(requestedOutput) {
  let outputPath = requestedOutput
    ? path.resolve(process.cwd(), requestedOutput)
    : defaultOutputPath();

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
  if (process.platform !== "win32") {
    fs.chmodSync(resolvedDestination, 0o755);
  }

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

function commandFileCandidates(commandName) {
  if (process.platform === "win32") {
    return [`${commandName}.cmd`, `${commandName}.ps1`, commandName];
  }

  return [commandName];
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

  if (process.platform === "win32") {
    candidates.push(installRoot);
  } else {
    if (path.basename(installRoot) === "lib") {
      candidates.push(path.join(path.dirname(installRoot), "bin"));
    }
    candidates.push(path.join(installRoot, "bin"));
  }

  for (const candidate of uniquePaths(candidates)) {
    for (const fileName of commandFileCandidates(commandName)) {
      if (fs.existsSync(path.join(candidate, fileName))) {
        return candidate;
      }
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

function writeManagedCommand(filePath, content, force, executable) {
  assertManagedCommandTarget(filePath, force);
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, content, "utf8");
  if (executable) {
    fs.chmodSync(filePath, 0o755);
  }
}

function escapeForSingleQuotedPowerShell(value) {
  return value.replace(/'/g, "''");
}

function relativeShellPath(fromDir, toFile) {
  return path.relative(fromDir, toFile).split(path.sep).join("/");
}

function installGeneratedCommand(targetBinaryPath, force) {
  const binDir = resolveCommandBinDir(__dirname, helperCommandName);
  if (!binDir) {
    return;
  }

  const resolvedTarget = path.resolve(targetBinaryPath);
  const relativeWindowsPath = path.relative(binDir, resolvedTarget);
  const relativePosixPath = relativeShellPath(binDir, resolvedTarget);

  if (process.platform === "win32") {
    writeManagedCommand(
      path.join(binDir, generatedCommandName),
      [
        "#!/bin/sh",
        `# ${managedCommandMarker()}`,
        'basedir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)',
        `exec "$basedir/${relativePosixPath}" "$@"`,
        "",
      ].join("\n"),
      force,
      true
    );

    writeManagedCommand(
      path.join(binDir, `${generatedCommandName}.cmd`),
      [
        "@ECHO off",
        `:: ${managedCommandMarker()}`,
        "SETLOCAL",
        `SET \"_ET_TARGET=%~dp0${relativeWindowsPath}\"`,
        '"%_ET_TARGET%" %*',
        "",
      ].join("\r\n"),
      force,
      false
    );

    writeManagedCommand(
      path.join(binDir, `${generatedCommandName}.ps1`),
      [
        `# ${managedCommandMarker()}`,
        `$target = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '${escapeForSingleQuotedPowerShell(relativeWindowsPath)}'))`,
        "& $target @args",
        "exit $LASTEXITCODE",
        "",
      ].join("\r\n"),
      force,
      false
    );
  } else {
    writeManagedCommand(
      path.join(binDir, generatedCommandName),
      [
        "#!/bin/sh",
        `# ${managedCommandMarker()}`,
        'basedir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)',
        `exec "$basedir/${relativePosixPath}" "$@"`,
        "",
      ].join("\n"),
      force,
      true
    );
  }

  process.stdout.write(`et init: updated command '${generatedCommandName}' in ${binDir}\n`);
}

const options = parseArgs(process.argv.slice(2));
const outputPath = resolveOutputPath(options.output);
initializeBinary(resolveBinaryPath(), outputPath, options.force);

if (path.resolve(outputPath) === path.resolve(defaultOutputPath())) {
  installGeneratedCommand(outputPath, options.force);
}