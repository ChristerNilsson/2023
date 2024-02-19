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

Here are some alternatives using directoru Information.
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

* You can inspect the markdown file by clicking **markdown** in the right lower corner.
The file name and location can be found by looking at the url in the browser.

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

* The hidden directory "files" can be used for storing files.

* Latest news are stored in the files/news directory
    * The number of shown items is set in settings.latestNews.
