// Coverage/validity report for one source's SourceFile. Deliberately objective:
// schema validity + a flat list of concrete gaps — a spec entirely absent, or an
// expected category with zero data. No heuristics or thresholds: "missing" means
// literally no data, nothing is judged "too thin". Catching a spec whose data
// *shrank* (a parse regression) is a diff-against-last-good job for the pipeline,
// not a magic cutoff here. Powers GET /:flavor/status/:source.
import { CLASSES, REGISTRY, SourceFile, type ClassToken } from "../schema/index.js";
import { expectedCategories, type Category } from "./matrix.js";

export interface CoverageIssue {
  spec: string;
  category?: Category; // omitted when the whole spec is absent
  kind: "absent" | "missing";
}

export interface CoverageReport {
  source: string;
  flavor: string;
  generatedAt?: string;
  ok: boolean;
  schemaValid: boolean;
  schemaErrors: string[];
  specsCovered: number;
  specsTotal: number;
  issues: CoverageIssue[];
}

function allSpecs(): { cls: ClassToken; spec: string }[] {
  const out: { cls: ClassToken; spec: string }[] = [];
  for (const cls of CLASSES) for (const spec of Object.keys(REGISTRY[cls])) out.push({ cls, spec });
  return out;
}

// A category has data when it holds at least one non-empty leaf. Recursive so it
// works for every shape: hero→context→array/object, or the flat links url map.
function hasData(v: unknown): boolean {
  if (v == null) return false;
  if (Array.isArray(v)) return v.length > 0;
  if (typeof v === "object") return Object.values(v as Record<string, unknown>).some(hasData);
  return true;
}

export function buildCoverageReport(source: string, flavor: string, file: unknown): CoverageReport {
  const parsed = SourceFile.safeParse(file);
  const schemaErrors = parsed.success
    ? []
    : parsed.error.issues.map((i) => `${i.path.join(".")}: ${i.message}`).slice(0, 50);

  const data = (file as { data?: Record<string, Record<string, Record<string, unknown>>> })?.data ?? {};
  const generatedAt = (file as { meta?: { generatedAt?: string } })?.meta?.generatedAt;

  const specs = allSpecs();
  const present = new Map<string, Record<string, unknown>>();
  const issues: CoverageIssue[] = [];

  for (const { cls, spec } of specs) {
    const key = `${cls}/${spec}`;
    const specData = data[cls]?.[spec];
    if (specData) present.set(key, specData);
    else issues.push({ spec: key, kind: "absent" });
  }

  for (const cat of expectedCategories(source)) {
    for (const [key, specData] of present) {
      if (!hasData(specData[cat])) issues.push({ spec: key, category: cat, kind: "missing" });
    }
  }

  return {
    source,
    flavor,
    generatedAt,
    ok: parsed.success && issues.length === 0,
    schemaValid: parsed.success,
    schemaErrors,
    specsCovered: present.size,
    specsTotal: specs.length,
    issues,
  };
}
