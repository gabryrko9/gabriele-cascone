import sys,pathlib
d=pathlib.Path(sys.argv[1]); s=(d/'page.html').read_text()
i=s.index('<header>')
head,body=s[:i],s[i:]
out=f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'><circle cx='32' cy='32' r='30' fill='%2309110E' stroke='%23D3AE66' stroke-width='3'/><text x='32' y='40' font-family='monospace' font-size='22' font-weight='700' fill='%23D3AE66' text-anchor='middle'>GC</text></svg>">
<meta property="og:title" content="Gabriele Cascone · Business & marketing growth with AI">
<meta property="og:description" content="More revenue, more visibility, a sharper business plan. The first proposal is free.">
<meta property="og:image" content="assets/gabriele.jpg">
{head.replace('<meta name="claude:viewport-fit-sides" content="cover">\n','')}</head>
<body>
{body}</body>
</html>
'''
(d/'index.html').write_text(out)
