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

function binaryNameForPlatform(platform = process.platform) {
  return platform === "win32" ? "et.exe" : "et";
}

function getPlatformPackageName(platform = process.platform) {
  const packageName = packageByPlatform[platform];
  if (!packageName) {
    throw new Error(`Unsupported platform '${platform}'.`);
  }
  return packageName;
}

function getArchDirectory(arch = process.arch, platform = process.platform) {
  const archDirectory = archDirectoryByNodeArch[arch];
  if (!archDirectory) {
    throw new Error(`Unsupported architecture '${arch}' on platform '${platform}'.`);
  }
  return archDirectory;
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

function findPackageRoot(startDir) {
  let current = path.resolve(startDir);

  while (true) {
    if (fs.existsSync(path.join(current, "package.json"))) {
      return current;
    }

    const parent = path.dirname(current);
    if (parent === current) {
      return path.resolve(startDir);
    }
    current = parent;
  }
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

function resolveInstallRoot(startDir) {
  const nodeModulesRoot = findNodeModulesRoot(startDir);
  if (nodeModulesRoot) {
    return path.dirname(nodeModulesRoot);
  }
  return findPackageRoot(startDir);
}

function readCurrentPackageVersion(startDir) {
  const packageRoot = findPackageRoot(startDir);
  const packageJsonPath = path.join(packageRoot, "package.json");
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
  return String(packageJson.version || "").trim();
}

function npmCommand() {
  return process.platform === "win32" ? "npm.cmd" : "npm";
}

function resolveInstalledPlatformPackageJson(startDir, packageName) {
  try {
    return require.resolve(`${packageName}/package.json`, { paths: [startDir] });
  } catch {
    return null;
  }
}

function installSpec(startDir, packageName) {
  const override = String(process.env.EASYTOUCH_PLATFORM_PACKAGE_SOURCE || "").trim();
  if (override) {
    return override;
  }

  const version = readCurrentPackageVersion(startDir);
  if (!version) {
    throw new Error(`Cannot determine the version for '${packageName}'.`);
  }

  return `${packageName}@${version}`;
}

function installPlatformPackage(startDir, packageName, logPrefix) {
  const cwd = resolveInstallRoot(startDir);
  const spec = installSpec(startDir, packageName);

  process.stdout.write(`${logPrefix}: installing ${spec} into ${cwd}\n`);

  const result = cp.spawnSync(
    npmCommand(),
    ["install", "--no-save", "--no-package-lock", "--no-audit", "--fund=false", spec],
    {
      cwd,
      stdio: "inherit",
      shell: process.platform === "win32",
    }
  );

  if (result.error) {
    throw new Error(`Failed to start npm while installing '${spec}': ${result.error.message}`);
  }

  if ((result.status ?? 1) !== 0) {
    throw new Error(`npm install failed while installing '${spec}' (exit code ${result.status ?? 1}).`);
  }
}

function ensurePlatformPackageInstalled(startDir, options = {}) {
  const logPrefix = options.logPrefix || "et";
  const packageName = getPlatformPackageName();

  let packageJsonPath = resolveInstalledPlatformPackageJson(startDir, packageName);
  if (!packageJsonPath && options.autoInstall) {
    installPlatformPackage(startDir, packageName, logPrefix);
    packageJsonPath = resolveInstalledPlatformPackageJson(startDir, packageName);
  }

  if (!packageJsonPath) {
    throw new Error(
      `The platform package '${packageName}' is not installed. Run the root package init.js first, or install '${packageName}' on this host.`
    );
  }

  return packageJsonPath;
}

function resolvePlatformBinaryPath(startDir, options = {}) {
  const packageName = getPlatformPackageName();
  const archDirectory = getArchDirectory();
  const packageJsonPath = ensurePlatformPackageInstalled(startDir, options);
  const packageRoot = path.dirname(packageJsonPath);
  const binRoot = path.join(packageRoot, "bin");
  const binaryName = binaryNameForPlatform();
  const binaryPath = path.join(binRoot, archDirectory, binaryName);

  if (!fs.existsSync(binaryPath)) {
    const availableArchitectures = getAvailableArchitectures(binRoot);
    const availableMessage = availableArchitectures.length
      ? ` Available architectures: ${availableArchitectures.join(", ")}.`
      : "";
    throw new Error(
      `The platform package '${packageName}' is missing '${binaryName}' for architecture '${archDirectory}'.${availableMessage}`
    );
  }

  return binaryPath;
}

module.exports = {
  binaryNameForPlatform,
  resolvePlatformBinaryPath,
};