
def sup(s): return f"<sup>{s}</sup>"
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
            if state == 0:
                n = int(line)
                state += 1
            elif state == 1:
                if line == "":
                    state += 1
                else:
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
                    arr = line.split(" ")
                    signW = arr[0][:2]
                    signB = arr[0][2:4]
                    if len(arr) > 1:
                        resultW = arr[1][0]
                        resultB = arr[1][2]
                        indexW = players[signW][0]
                        indexB = players[signB][0]
                        url = arr[2] if len(arr) > 2 else ""
                        matrix[indexW][rond] = a(resultW,url) + sup(indexB+1)
                        matrix[indexB][rond] = sup(indexW+1) + a(resultB,url)

    md = [str(j+1) + "|" + names[j] + "|" + "|".join([matrix[j][i] for i in range(rounds)]) for j in range(n)]
    with open(filename.replace('.trn','.md'), "w", encoding="utf-8") as g:
        s = "Nr|Namn"
        t = ":-:|----"
        for i in range(rounds):
            s += "|" + str(i+1)
            t += '|-'
        g.write(s+"\n")
        g.write(t+"\n")
        for line in md:
            g.write(line + "\n")


trn2md("Seniorschack_Stockholm/Partier/2024/Klass_4.trn")

