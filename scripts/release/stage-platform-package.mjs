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

const repoRoot = path.resolve(fileURLToPath(new URL("../../", import.meta.url)));
const templateDir = path.resolve(repoRoot, readFlag("--template"));
const outputDir = path.resolve(repoRoot, readFlag("--output"));
const binarySource = path.resolve(repoRoot, readFlag("--binary"));
const binaryName = readFlag("--binary-name");

await fs.rm(outputDir, { recursive: true, force: true });
await fs.mkdir(path.join(outputDir, "bin"), { recursive: true });
await fs.cp(templateDir, outputDir, { recursive: true });
await fs.copyFile(path.join(repoRoot, "LICENSE.txt"), path.join(outputDir, "LICENSE.txt"));
await fs.copyFile(path.join(repoRoot, "README.md"), path.join(outputDir, "README.md"));
await fs.copyFile(path.join(repoRoot, "SKILL.md"), path.join(outputDir, "SKILL.md"));
await fs.copyFile(binarySource, path.join(outputDir, "bin", binaryName));

if (binaryName === "easytouch") {
  await fs.chmod(path.join(outputDir, "bin", binaryName), 0o755);
}

console.log(`staged ${path.relative(repoRoot, outputDir)} from ${path.relative(repoRoot, binarySource)}`);
