
# def sup(s): return f"<sup>{s}</sup>"

def sup(s,r,cp): return f"<div class={cp}>{s}</div><div class=rfrresult>{r}</div>"

def a(title,url): return title if url == "" else f"[{title}]({url})"

def trn2md(filename):
    state = 0
    players = {}
    names = []
    n = 0  # players
    rounds = 0
    rond = 0
    matrix = []
    index = 0
    with open(filename, encoding="utf-8") as f:
        lines = f.readlines()
        for line in lines:
            line = line.strip()
            arr = line.split("|")
            if state == 0:
                n = int(line)
                state += 1
            elif state == 1:
                if line == "":
                    if n != len(players):
                        print('Error in',filename,'Wrong number of players')
                    else:
                        if n%2 == 1:
                            print('Error in', filename, 'Number of players must be even.')
                    state += 1
                else:
                    if len(arr[0]) != 2:
                        print('Error in', filename, 'Signature must have length 2',arr[0])
                        return
                    signatur = line[:2]
                    name = line[3:]
                    players[signatur] = [index,name]
                    names.append(name)
                    index += 1
            elif state == 2:
                rounds = int(line)
                matrix = [["" for i in range(rounds)] for j in range(n)]
                state += 1
            elif state == 3:
                if line[0] == 'R':
                    rond = int(line[1:]) - 1
                else:
                    if len(arr[0]) != 4:
                        print('Error in', filename, 'Signature pairs must have length 4',arr[0])
                        return
                    signW = arr[0][:2]
                    signB = arr[0][2:4]
                    if signW not in players:
                        print('Error in',filename,'Missing signature',signW)
                        return
                    if signB not in players:
                        print('Error in',filename,'Missing signature',signB)
                        return
                    indexW = players[signW][0]
                    indexB = players[signB][0]
                    if len(arr) > 1:
                        if arr[1] not in "0-0 0-1 1-0 ½-½".split(" "):
                            print('Error in',filename,'Illegal result',arr[1])
                            return
                        resultW = arr[1][0]
                        resultB = arr[1][2]
                        url = arr[2] if len(arr) > 2 else ""
                        matrix[indexW][rond] = sup(indexB+1,a(resultW,url),'CP_White')
                        matrix[indexB][rond] = sup(indexW+1,a(resultB,url),'CP_Black')
                    else:
                        matrix[indexW][rond] = ""
                        matrix[indexB][rond] = ""

    md = [str(j+1) + "|" + names[j] + "|" + "|".join([matrix[j][i] for i in range(rounds)]) for j in range(n)]
    with open(filename.replace('.trn','.md'), "w", encoding="utf-8") as g:
        s = "Nr|Namn"
        t = ":-:|-"
        for i in range(rounds):
            s += "|" + str(i+1)
            t += '|-'
        g.write(s+"\n")
        g.write(t+"\n")
        for line in md:
            g.write(line + "\n")
