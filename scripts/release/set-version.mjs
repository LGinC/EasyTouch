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

const packageFiles = [
  path.join(repoRoot, "package.json"),
  path.join(repoRoot, "packages", "easytouch-windows", "package.json"),
  path.join(repoRoot, "packages", "easytouch-linux", "package.json"),
  path.join(repoRoot, "packages", "easytouch-macos", "package.json"),
];

for (const filePath of packageFiles) {
  const packageJson = JSON.parse(await fs.readFile(filePath, "utf8"));
  packageJson.version = normalizedVersion;

  if (packageJson.name === "easytouch") {
    packageJson.optionalDependencies = {
      "easytouch-windows": normalizedVersion,
      "easytouch-linux": normalizedVersion,
      "easytouch-macos": normalizedVersion,
    };
  }

  await fs.writeFile(filePath, `${JSON.stringify(packageJson, null, 2)}\n`, "utf8");
  console.log(`updated ${path.relative(repoRoot, filePath)} -> ${normalizedVersion}`);
}
