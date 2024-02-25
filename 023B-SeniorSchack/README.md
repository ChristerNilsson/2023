[Try it!](https://christernilsson.github.io/2023/023B-SeniorSchack/Seniorschack_Stockholm)

* This program is used to transpile markdown files to html files.

* The directory structure is used to minimize the amount av markdown needed.
    * You can reorganize your directory tree without changing any code.
    * Move files and directories and rerun makeAll.py to update all .html files
    * Change file and directory names with no code changes

* You have a choice between using directories and files or markdown files or a combination of both
    * markdown files gives you the opportunity to show the alternatives in any order.
    * markdown files are also uses to add text, pictures and more.
    * You can specify a link using a .link file.
        * The name of the file will be displayed to the user.
        * The .link file contains a link or an url.
        * The user will not know which alternative is used of
            * Markdown
            * Directory structure
            * .link file

**The Cauchy-Schwarz Inequality**
$$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$

Here are some alternatives using directory Information.
[] indicates what the browser will display.

```
Info.pdf                                      [Info]

index.md (contains a link to Info.pdf)        [Info]

Info.link (contains a link to Info.pdf)       [Info]

Information                                   [Information]
    Info.pdf                                      [Info]

Information                                   [Information]
    index.md (contains a link to Info.pdf)        [Info]

Information.md (contains a link to Info.pdf)  [Information]
                                                  [Info]

Information                                   [Information]
    Info.link (contains a link to Info.pdf)       [Info]
```

* You can inspect the markdown file by clicking on the main header.
The file name and location can be found by looking at the url in the browser.
If the header is not clickable, then there is no markdown for that page.

* makeAll.py transpiles all .md-files to .html files.
    * No md file is mandatory.
    * You define it when you want to add text or links.
    * In fact, you can use zero md files.

* Deploy by copying the root folder to your server.

* Helpful:
    * VS Code and Run On Save
    * VS Code and Go Live

* [Cheat Sheet](https://commonmark.org/help/)

* Extension: [Tables](https://python-markdown.github.io/extensions/tables/)

* The hidden directory *files* can be used for storing files.

* Latest news are stored in the *files/news* directory
    * The number of shown items is set in settings.latestNews.

## Tournament handling

To make it possible to produce pages with tournament results and links to games, a tournament file format is proposed.

Three segments:
1. Names
2. Games
3. Final Order

This format will be transformed to an .md file by makeAll.py and then transpiled into .html.

Klass 4.trn
```
1 Christer Nilsson
2 Roland Windahl
3 Brita Trybom
4 Kjell Linde

R1 W1 B2 1-0 https://lichess.org/study/pYjvo5dL/yw4fL9Ow
R1 W3 B4 ½-½ https://lichess.org/study/pYjvo5dL/yw4fL9Ow

4 2 3 1
```

Klass 4.md
```
Nr|Namn|1|2|3|4
:-:|----|:--:|:--:|:--:|:--:
1|Christer Nilsson|•|[1](LICHESS/study/pYjvo5dL/yw4fL9Ow)<sup>2</sup>|[1](LICHESS/study/pYjvo5dL/albYqV3T)|[1](LICHESS/study/pYjvo5dL/lggFnOo1)
2|Roland Windahl|<sup>1</sup>[0](LICHESS/study/pYjvo5dL/yw4fL9Ow)|•||
3|Brita Trybom|[0](LICHESS/study/pYjvo5dL/albYqV3T)||•|
4|Kjell Linde|[0](LICHESS/study/pYjvo5dL/lggFnOo1)|||•
```

Klass 4.html
```
<table>
<thead>
<tr>
<th style="text-align:center">Nr</th>
<th>Namn</th>
<th style="text-align:center">1</th>
<th style="text-align:center">2</th>
<th style="text-align:center">3</th>
<th style="text-align:center">4</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:center">1</td>
<td>Christer Nilsson</td>
<td style="text-align:center">•</td>
<td style="text-align:center"><a href="https://lichess.org/study/pYjvo5dL/yw4fL9Ow">1</a><sup>2</sup></td>
<td style="text-align:center"><a href="https://lichess.org/study/pYjvo5dL/albYqV3T">1</a></td>
<td style="text-align:center"><a href="https://lichess.org/study/pYjvo5dL/lggFnOo1">1</a></td>
</tr>
<tr>
<td style="text-align:center">2</td>
<td>Roland Windahl</td>
<td style="text-align:center"><sup>1</sup><a href="https://lichess.org/study/pYjvo5dL/yw4fL9Ow">0</a></td>
<td style="text-align:center">•</td>
<td style="text-align:center"></td>
<td style="text-align:center"></td>
</tr>
<tr>
<td style="text-align:center">3</td>
<td>Brita Trybom</td>
<td style="text-align:center"><a href="https://lichess.org/study/pYjvo5dL/albYqV3T">0</a></td>
<td style="text-align:center"></td>
<td style="text-align:center">•</td>
<td style="text-align:center"></td>
</tr>
<tr>
<td style="text-align:center">4</td>
<td>Kjell Linde</td>
<td style="text-align:center"><a href="https://lichess.org/study/pYjvo5dL/lggFnOo1">0</a></td>
<td style="text-align:center"></td>
<td style="text-align:center"></td>
<td style="text-align:center">•</td>
</tr>
</tbody>
</table>
```