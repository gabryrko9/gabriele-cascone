import sys,pathlib
d=pathlib.Path(sys.argv[1]); s=(d/'page.html').read_text()
i=s.index('<header')
head,body=s[:i],s[i:]
out=f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'><rect x='6' y='6' width='24' height='24' rx='7' fill='%232445D8'/><circle cx='46' cy='18' r='12' fill='%23E2533A'/><circle cx='18' cy='46' r='12' fill='%2314935F'/><rect x='34' y='34' width='24' height='24' rx='7' fill='%23F0AE14'/></svg>">
<meta property="og:title" content="Gabriele Cascone · Business & marketing growth with AI">
<meta property="og:description" content="More revenue, more visibility, a sharper business plan. The first proposal is free.">
<meta property="og:image" content="assets/gabriele.jpg">
{head.replace('<meta name="claude:viewport-fit-sides" content="cover">\n','')}</head>
<body>
{body}</body>
</html>
'''
(d/'index.html').write_text(out)
