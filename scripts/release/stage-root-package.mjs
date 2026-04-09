import fs from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

function stagedBinaryName(platformId, arch, sourceFileName) {
  const extension = path.extname(sourceFileName);
  const baseName = extension ? sourceFileName.slice(0, -extension.length) : sourceFileName;
  return `${baseName}_${platformId}_${arch}${extension}`;
}

async function collectRawBinarySpecs(rawRoot) {
  const binarySpecs = [];

  let platformEntries = [];
  try {
    platformEntries = await fs.readdir(rawRoot, { withFileTypes: true });
  } catch {
    return binarySpecs;
  }

  for (const platformEntry of platformEntries) {
    if (!platformEntry.isDirectory()) {
      continue;
    }

    const platformId = platformEntry.name;
    const platformRoot = path.join(rawRoot, platformId);
    const archEntries = await fs.readdir(platformRoot, { withFileTypes: true });

    for (const archEntry of archEntries) {
      if (!archEntry.isDirectory()) {
        continue;
      }

      const arch = archEntry.name;
      const archRoot = path.join(platformRoot, arch);
      const fileEntries = await fs.readdir(archRoot, { withFileTypes: true });
      const binaryEntry = fileEntries.find((entry) => entry.isFile() && (entry.name === "et" || entry.name === "et.exe"));

      if (!binaryEntry) {
        continue;
      }

      binarySpecs.push({
        platformId,
        arch,
        sourcePath: path.join(archRoot, binaryEntry.name),
        targetName: stagedBinaryName(platformId, arch, binaryEntry.name),
      });
    }
  }

  return binarySpecs.sort((left, right) => left.targetName.localeCompare(right.targetName));
}

function readFlag(flagName) {
  const index = process.argv.indexOf(flagName);
  if (index === -1 || index + 1 >= process.argv.length) {
    throw new Error(`Missing required flag: ${flagName}`);
  }
  return process.argv[index + 1];
}

const repoRoot = path.resolve(fileURLToPath(new URL("../../", import.meta.url)));
const templateDir = path.resolve(repoRoot, readFlag("--template"));
const outputDir = path.resolve(repoRoot, readFlag("--output"));
const rawRoot = path.join(repoRoot, "dist", "raw");
const binarySpecs = await collectRawBinarySpecs(rawRoot);

if (binarySpecs.length === 0) {
  throw new Error("No raw binaries were found under dist/raw. Stage binaries before staging the root npm package.");
}

await fs.rm(outputDir, { recursive: true, force: true });
await fs.mkdir(outputDir, { recursive: true });

await fs.copyFile(path.join(templateDir, "package.json"), path.join(outputDir, "package.json"));
await fs.copyFile(path.join(templateDir, "init.js"), path.join(outputDir, "init.js"));
await fs.mkdir(path.join(outputDir, "bin"), { recursive: true });
await fs.copyFile(path.join(repoRoot, "LICENSE.txt"), path.join(outputDir, "LICENSE.txt"));
await fs.copyFile(path.join(repoRoot, "README.md"), path.join(outputDir, "README.md"));
await fs.copyFile(path.join(repoRoot, "README.en.md"), path.join(outputDir, "README.en.md"));
await fs.copyFile(path.join(repoRoot, "SKILL.md"), path.join(outputDir, "SKILL.md"));
await fs.copyFile(path.join(repoRoot, "SKILL.en.md"), path.join(outputDir, "SKILL.en.md"));

for (const { sourcePath, targetName } of binarySpecs) {
  const targetPath = path.join(outputDir, "bin", targetName);
  await fs.copyFile(sourcePath, targetPath);

  if (path.extname(targetPath) !== ".exe") {
    await fs.chmod(targetPath, 0o755);
  }
}

await fs.chmod(path.join(outputDir, "init.js"), 0o755);

console.log(`staged ${path.relative(repoRoot, outputDir)} as root npm package`);