with open("klubben.htm",encoding="utf8") as f:
    lines = f.readlines()

index = 0
pointCounter = -1

for line in lines:
    line = line.replace("&nbsp;","").replace('target = "_blank"',"")
    low = line.lower()

    for i in range(1,7):
        if f"<h{i}>" in low:
            p0 = low.find(f"<h{i}>")
            p1 = low.find(f"</h{i}>",p0+1)
            title = line[p0+4:p1]
            if title[-1] == '.': title = title[:-1]
            print("#"*i + " " + title)

    # if "<h3>" in low:
    #     p0 = low.find("<h3>")
    #     p1 = low.find("</h3>",p0+1)
    #     title = line[p0+4:p1]
    #     if title[-1] == '.': title = title[:-1]
    #     print("### " + title)

    if '<ol>' in low: pointCounter = 1
    if '</ol>' in low: pointCounter = -1
    if "<a " in low:
        p0 = low.find("<a")
        p1 = low.find("href",p0+1)
        p2 = low.find('"',p1+1)
        p3 = low.find('"',p2+1)
        p4 = low.find('>',p3+1)
        p5 = low.find('</a>',p4+1)
        # print(p0, p1, p2, p3, p4, p5)
        if p0 <= p1 <= p2 <= p3 <= p4 <= p5:
            href = line[p2+1:p3]
            title = line[p4+1:p5].strip()
            if title[-1] == '.': title = title[:-1]
            if href.startswith('http'):
                prefix = ""
            else:
                prefix = "SENIOR/htmfiler/"
            print("")
            if pointCounter != -1:
                print(str(pointCounter) + '.','[' + title + '](' + prefix + href + ')')
                # pointCounter += 1
            else:
                print('[' + title + '](' + prefix + href + ')')
        else:
            print('Missing > in a', index)
            print(p0, p1, p2, p3, p4, p5)

        index += 1

    if '<table ' in low:
        print("")
        print("Kategori|Kronor")
        print("---|---")

    # line = line.replace('<b>',' **').replace('</b>','** ')
    low = line.lower()
    if '<td' in low:
        p0 = low.find("<td")
        p1 = low.find(">",p0+1)
        p2 = low.find('</td>',p1+1)

        p3 = low.find("<td",p2)
        p4 = low.find(">",p3+1)
        p5 = low.find('</td>',p4+1)

        # print(line[p1+1:p2].replace('<b>',' **').replace('</b>','** ') + '|' + line[p4+1:p5].replace('<b>',' **').replace('</b>','** '))
        print(line[p1 + 1:p2] + '|' + line[p4 + 1:p5])
    if '</table>' in low:
        print("")
        print("## Dokument")
