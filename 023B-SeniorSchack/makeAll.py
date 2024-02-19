import os
import time
import markdown
from markdown.extensions.tables import TableExtension

# Innebär att Startbilden påverkas. Kanske behövs ett kommando i .md-filen a la CONTENT. NEWS?
# RSS

file_count = 0
md_bytes = 0
html_bytes = 0

settings = {
	'rootFolder': "Seniorschack_Stockholm",
	'showExt': False,
	'latestNews': 5,
}

def title(s): return s.replace('.md','')

def patch(s): # Reason: To have some whitespace between links (margin-bottom)
	s = s.replace('<p><a href=','<div><a href=')
	s = s.replace('</a></p>','</a></div>')
	s = s.replace('TOUR', 'https://member.schack.se/ShowTournamentServlet?id')
	s = s.replace('SENIOR','https://www.seniorschackstockholm.se')
	return s

def writeHtmlFile(filename, t, level, content=""):
	t = title(t)
	index = 1 + filename.rindex("\\")
	short_md = filename[index:].replace('.html','.md')
	long_md = filename.replace('.html','.md')
	global file_count
	global html_bytes

	res = []
	res.append('<!-- Generated by makeAll.py 1.0 -->')
	res.append('<html>')
	res.append('	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />')
	res.append('	<head>')
	res.append(f'		<title>{t}</title>')
	res.append('		<meta charset = "utf-8"/>')
	res.append('		<link href="' + (level-1) * '../' + 'style.css" rel="stylesheet" type="text/css" >')
	res.append('	</head>')
	res.append('<body>')
	res += [f"<h1>{t}</h1>"]

	res += [content]

	if os.path.exists(long_md):
		res.append(f'<div style=" text-align: right"><a href="{short_md}">markdown</a></div>')

	res.append('</body>')
	res.append('</html>')

	with open(filename, 'w', encoding='utf8') as g:
		s = '\n'.join(res)
		g.write(s)
		html_bytes += len(s)

def noExt(s):
	s = s.replace("_", " ")
	if settings['showExt']: return s
	else: return s.replace(".pdf", "").replace(".md", "").replace(".xls", "")

def getLink(f,level):
	print('\t' * level + f.name)
	with open(f.path,encoding='utf8') as f: return patch(f.read().strip())

def getNews(directory=settings["rootFolder"] + "/files/news"):
	files = os.listdir(directory)
	files = files[: -settings["latestNews"]: -1]
	res = [f"<div><a href='files/news/{f}'>{noExt(f)}</a></div>" for f in files]
	return "\n".join(res)

def transpileDir(directory,level=0):

	if type(directory) is str:
		path = directory
		name = directory
	else:
		path = directory.path
		name = directory.name

	print('\t'*level + name)

	if name == 'files' or name.endswith('.css'): return

	name = name.replace("_", " ")
	res = []

	indexHtml = ""

	for f in os.scandir(path):
		if os.path.isfile(f):
			if f.name.endswith('.html') or f.name.endswith('.css'):
				pass
			elif f.name.endswith('index.md'):
				indexHtml = transpileFile(f.path,f.name,level)
			elif f.name.endswith('.md'):
				filename = f.path.replace('.md', '.html')

				index = 1 + filename.rindex("\\")
				short_md = filename[index:].replace('.html', '.md')
				writeHtmlFile(filename, f.name, level+1, transpileFile(f.path,f.name,level))
				res += [f"<div><a href='{f.name.replace('.md', '.html')}'>{f.name.replace('.md', '')}</a></div>"]
			elif f.name.endswith('.link'):
				res += [f"<div><a href='{getLink(f,level+1)}'>{f.name.replace('.link', '')}</a></div>"]
			else:
				res += [f"<div><a href='{f.name}'>{noExt(f.name)}</a></div>"]
		else:
			if f.name != 'files':
				res += [f"<div><a href='{f.name}\\index.html'>{f.name}</a></div>"]
				transpileDir(f,level+1)

	if indexHtml == "":
		indexHtml = "\n".join(res)
	else:
		indexHtml = indexHtml.replace("CONTENT","\n".join(res))
		indexHtml = indexHtml.replace("NEWS",news)

	writeHtmlFile(path + '\\index.html', name, level+1, indexHtml)

def transpileFile(long,short,level=0):
	global md_bytes
	global file_count

	with open(long,encoding='utf8') as f:
		md = f.read()
		print('\t' * (level + 1) + short, f'({len(md)} bytes) =>', short.replace('.md', '.html'))
		file_count += 1
		md_bytes += len(md)
		html = markdown.markdown(md,extensions=[TableExtension(use_align_attribute=True)])
		html = patch(html)
	return html

start = time.time_ns()
news = getNews()
transpileDir(settings['rootFolder'],0)
print()
print(md_bytes,'=>',html_bytes,'bytes')
print(file_count, 'files took', round((time.time_ns() - start)/10**6),'ms')
