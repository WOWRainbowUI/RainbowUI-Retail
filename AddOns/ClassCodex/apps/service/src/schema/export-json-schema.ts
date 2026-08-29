// Emit JSON Schema from the Zod definitions -> schema/*.schema.json
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import { zodToJsonSchema } from "zod-to-json-schema";
import { SourceFile } from "./normalized.js";
import { ReferenceFile } from "./reference.js";

const outDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../schema");
fs.mkdirSync(outDir, { recursive: true });

const write = (name: string, schema: unknown) =>
  fs.writeFileSync(path.join(outDir, name), JSON.stringify(schema, null, 2) + "\n");

write("source-file.schema.json", zodToJsonSchema(SourceFile, "SourceFile"));
write("reference-file.schema.json", zodToJsonSchema(ReferenceFile, "ReferenceFile"));
console.log("Wrote JSON Schemas to", path.relative(process.cwd(), outDir));
