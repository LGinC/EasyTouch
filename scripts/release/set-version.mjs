import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(fileURLToPath(new URL("../../", import.meta.url)));
const requestedVersion = process.argv[2];

if (!requestedVersion) {
  console.error("Usage: node scripts/release/set-version.mjs <version-or-tag>");
  process.exit(1);
}

const normalizedVersion = requestedVersion.startsWith("v")
  ? requestedVersion.slice(1)
  : requestedVersion;

function toPublishableSemver(version) {
  const semverPattern =
    /^\d+\.\d+\.\d+(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$/;

  if (semverPattern.test(version)) {
    return version;
  }

  // Support tags like v1.2.3.4 by converting to semver prerelease 1.2.3-4.
  const fourPartMatch = version.match(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/);
  if (fourPartMatch) {
    const [, major, minor, patch, build] = fourPartMatch;
    return `${major}.${minor}.${patch}-${build}`;
  }

  return null;
}

const publishableVersion = toPublishableSemver(normalizedVersion);

if (!publishableVersion) {
  console.error(
    `Invalid npm version '${normalizedVersion}'. Use semver like 1.2.3 or 1.2.3-beta.1. Four-part tags like 1.2.3.4 are supported and will be converted to 1.2.3-4.`
  );
  process.exit(1);
}

const packageFiles = [
  path.join(repoRoot, "package.json"),
  path.join(repoRoot, "packages", "easytouch-windows", "package.json"),
  path.join(repoRoot, "packages", "easytouch-linux", "package.json"),
  path.join(repoRoot, "packages", "easytouch-macos", "package.json"),
];

for (const filePath of packageFiles) {
  const packageJson = JSON.parse(await fs.readFile(filePath, "utf8"));
  packageJson.version = publishableVersion;

  if (packageJson.name === "easytouch") {
    packageJson.optionalDependencies = {
      "easytouch-windows": publishableVersion,
      "easytouch-linux": publishableVersion,
      "easytouch-macos": publishableVersion,
    };
  }

  await fs.writeFile(filePath, `${JSON.stringify(packageJson, null, 2)}\n`, "utf8");
  console.log(`updated ${path.relative(repoRoot, filePath)} -> ${publishableVersion}`);
}
