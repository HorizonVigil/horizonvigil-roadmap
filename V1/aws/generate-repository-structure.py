import io, os, subprocess, sys

ROOT = r'C:\Users\Lenovo\Downloads\HorizonVigil\repos'
OUT  = r'C:\Users\Lenovo\Downloads\HorizonVigil\repos\horizonvigil-roadmap\V1\aws\REPOSITORY-STRUCTURE.md'

def tracked(repo):
    try:
        r = subprocess.run(['git', '-C', os.path.join(ROOT, repo), 'ls-files'],
                           capture_output=True, text=True, timeout=120)
        return sorted(x for x in r.stdout.splitlines() if x.strip())
    except Exception:
        return []

def tree(paths):
    """Render a flat path list as an indented tree."""
    out, prev = [], []
    for p in paths:
        parts = p.replace('\\', '/').split('/')
        # how much of the previous path do we share
        common = 0
        for a, b in zip(prev, parts[:-1]):
            if a != b:
                break
            common += 1
        for depth in range(common, len(parts) - 1):
            out.append('  ' * depth + parts[depth] + '/')
        out.append('  ' * (len(parts) - 1) + parts[-1])
        prev = parts[:-1]
    return out

repos = sorted(
    d for d in os.listdir(ROOT)
    if os.path.isdir(os.path.join(ROOT, d)) and os.path.exists(os.path.join(ROOT, d, '.git'))
)

buf = []
w = buf.append
w('# HorizonVigil — complete repository structure')
w('')
w('Every git-tracked file in every repository. Generated from `git ls-files`, so')
w('it reflects what is actually committed — `node_modules/`, `dist/` and other')
w('ignored output are excluded by definition, not by a filter that might drift.')
w('')
w('Regenerate: `python scratchpad/gen_tree.py`')
w('')

total = 0
w('## Repository index')
w('')
w('| repository | tracked files | role |')
w('|---|---:|---|')
ROLE = {
    'horizonvigil-connector-aws': 'AWS collection, cost, posture — the AWS service',
    'horizonvigil-connector-gcp': 'GCP collection',
    'horizonvigil-connector-azure': 'Azure collection',
    'horizonvigil-frontend': 'React/Vite SPA — every customer-facing screen',
    'horizonvigil-shared-lib': 'Cross-service auth, RBAC, db, pagination, availability contract',
    'horizonvigil-cost': 'Cost analytics, recommendations, anomalies',
    'horizonvigil-security': 'Cloud security / posture APIs, V2 entitlement gate',
    'horizonvigil-resources': 'Inventory, ownership, explorer aggregates',
    'horizonvigil-reports': 'Reports, exports, overview, dashboards',
    'horizonvigil-observability': 'Alerts, alert rules, monitoring',
    'horizonvigil-admin': 'Users, orgs, settings',
    'horizonvigil-billing': 'Subscription, usage metering',
    'horizonvigil-automation': 'Runbooks, webhooks, scheduled jobs',
    'horizonvigil-platform-admin': 'Internal platform administration',
    'horizonvigil-platform-health': 'Platform health checks',
    'horizonvigil-incidents': 'Incidents (V2 / decommissioned)',
    'horizonvigil-ai-gateway': 'AI gateway',
    'horizonvigil-llm': 'LLM service',
    'horizonvigil-trivy': 'Trivy scanner service (V2)',
    'horizonvigil-roadmap': 'Specs, audits, certification records',
    'supabase': 'Postgres migrations — the schema of record',
}
listings = {}
for r in repos:
    files = tracked(r)
    listings[r] = files
    total += len(files)
    w(f'| `{r}` | {len(files)} | {ROLE.get(r, "scanner microservice (V2)")} |')
w(f'| **total** | **{total}** | |')
w('')
w('---')
w('')

for r in repos:
    files = listings[r]
    w(f'## `{r}` — {len(files)} files')
    w('')
    if not files:
        w('_(no tracked files)_')
        w('')
        continue
    w('```')
    w(f'{r}/')
    for line in tree(files):
        w('  ' + line)
    w('```')
    w('')

io.open(OUT, 'w', encoding='utf-8').write('\n'.join(buf) + '\n')
print('wrote', OUT)
print('repos:', len(repos), 'files:', total, 'lines:', len(buf))
