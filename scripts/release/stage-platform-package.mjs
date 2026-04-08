import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

function readFlag(flagName) {
  const index = process.argv.indexOf(flagName);
  if (index === -1 || index + 1 >= process.argv.length) {
    throw new Error(`Missing required flag: ${flagName}`);
  }
  return process.argv[index + 1];
}

function readFlagValues(flagName) {
  const values = [];

  for (let index = 0; index < process.argv.length; index += 1) {
    if (process.argv[index] === flagName) {
      if (index + 1 >= process.argv.length) {
        throw new Error(`Missing required flag value: ${flagName}`);
      }
      values.push(process.argv[index + 1]);
    }
  }

  return values;
}

function parseBinarySpec(repoRoot, rawSpec) {
  const separatorIndex = rawSpec.indexOf("=");
  if (separatorIndex <= 0) {
    throw new Error(`Invalid --binary value '${rawSpec}'. Expected <arch>=<path>.`);
  }

  const arch = rawSpec.slice(0, separatorIndex);
  const sourcePath = rawSpec.slice(separatorIndex + 1);
  if (!arch || !sourcePath) {
    throw new Error(`Invalid --binary value '${rawSpec}'. Expected <arch>=<path>.`);
  }

  return {
    arch,
    sourcePath: path.resolve(repoRoot, sourcePath),
  };
}

const repoRoot = path.resolve(fileURLToPath(new URL("../../", import.meta.url)));
const templateDir = path.resolve(repoRoot, readFlag("--template"));
const outputDir = path.resolve(repoRoot, readFlag("--output"));
const binaryName = readFlag("--binary-name");
const binarySpecs = readFlagValues("--binary").map((rawSpec) => parseBinarySpec(repoRoot, rawSpec));

if (binarySpecs.length === 0) {
  throw new Error("At least one --binary <arch>=<path> value is required.");
}

await fs.rm(outputDir, { recursive: true, force: true });
await fs.cp(templateDir, outputDir, { recursive: true });
await fs.mkdir(path.join(outputDir, "bin"), { recursive: true });
await fs.copyFile(path.join(repoRoot, "LICENSE.txt"), path.join(outputDir, "LICENSE.txt"));
await fs.copyFile(path.join(repoRoot, "README.md"), path.join(outputDir, "README.md"));
await fs.copyFile(path.join(repoRoot, "SKILL.md"), path.join(outputDir, "SKILL.md"));

for (const { arch, sourcePath } of binarySpecs) {
  const targetDir = path.join(outputDir, "bin", arch);
  const targetPath = path.join(targetDir, binaryName);
  await fs.mkdir(targetDir, { recursive: true });
  await fs.copyFile(sourcePath, targetPath);

  if (binaryName !== "et.exe") {
    await fs.chmod(targetPath, 0o755);
  }
}

const launcherPath = path.join(outputDir, "bin", "et.js");
await fs.chmod(launcherPath, 0o755);

const initScriptPath = path.join(outputDir, "init.js");
try {
  await fs.chmod(initScriptPath, 0o755);
} catch {
  // Optional for templates that do not ship init.js.
}

console.log(
  `staged ${path.relative(repoRoot, outputDir)} with architectures ${binarySpecs
    .map((entry) => entry.arch)
    .join(", ")}`
);
