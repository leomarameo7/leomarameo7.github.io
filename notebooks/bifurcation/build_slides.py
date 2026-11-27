#!/usr/bin/env python3
"""Builds bifurcation_slides.html (four self-contained reveal.js slides) from the slide deck of the research project.
Usage: python3 build_slides.py <path to presentations/progress_report> ; the notebook bifurcation_diagrams.qmd embeds the result."""
import base64, pathlib, re, shutil, subprocess, sys, tempfile
here = pathlib.Path(__file__).resolve().parent; deck = pathlib.Path(sys.argv[1]).resolve()
t = (deck / 'deck_template.qmd').read_text()
body = t[t.index('## Predict: how a bifurcation diagram is built'):t.index('## Abiotic drivers: time series at three depths')]
body = re.sub(r'::: \{\.notes\}.*?\n:::\n', '', body, flags=re.S).replace('HDR\n', '')
slides = ['## ' + s for s in ('\n' + body).split('\n## ')[1:]]; assert len(slides) == 4, len(slides)
out = []
for n, s in enumerate(slides, 1):
    head, _, rest = s.partition('\n')
    head = re.sub(r'^## ([^<{:]*?):(.*?)(\s*\{[^}]*\})?$', lambda m: f"## <span class='tp'>{m.group(1)}:</span>{m.group(2)}{m.group(3) or ''}", head)
    out.append(f"{head}\n<div class='pg'>{n}/4</div>\n{rest}")
yaml = t[:t.index('---', 3) + 3].replace('include-after-body: network_inc.html', 'include-after-body: bif_inc.html')
yaml = re.sub(r'pagetitle: .*', 'pagetitle: "Bifurcation diagrams"', yaml)
with tempfile.TemporaryDirectory() as tmp:
    tmp = pathlib.Path(tmp)
    for f in ['style.css', 'fonts.css', 'images/plankton/Gr2.png', 'images/figures/zurich_ts_shift.png', 'images/figures/zurich_uncertainty.png']:
        (tmp / f).parent.mkdir(parents=True, exist_ok=True); shutil.copy(deck / f, tmp / f)
    icon = 'data:image/png;base64,' + base64.b64encode((deck / 'images/plankton/Gr2.png').read_bytes()).decode()
    js = '\n'.join([(deck / 'bifplayer.js').read_text(), (deck / 'bifsteps.js').read_text(),
                    'window.BIFZ=' + (deck / 'scripts/bif_zurich.json').read_text() + ';', (deck / 'bifzurich.js').read_text()])
    (tmp / 'bif_inc.html').write_text(f"<script>window.NET_DATA={{icons:{{Gr2:'{icon}'}}}};</script>\n<script>{js}</script>\n")
    (tmp / 'bifurcation_slides.qmd').write_text(yaml + '\n\n' + '\n\n'.join(out) + '\n')
    subprocess.run(['quarto', 'render', 'bifurcation_slides.qmd', '--to', 'revealjs'], cwd=tmp, check=True)
    shutil.copy(tmp / 'bifurcation_slides.html', here / 'bifurcation_slides.html')
print(here / 'bifurcation_slides.html')
