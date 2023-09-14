# Knuth's Five Guess Algorithm Implementation 

[Try it!](https://christernilsson.github.io/2023/036-knuth-mastermind_1296/)

## 1296 

This repository contains a python implementation of Knuth's Five Guess algorithm for the board game Mastermind.  
This program uses a version of Mastermind that has 4 symbols, 6 colors, and with repetition.  
The program solves all 1296 codes, and has a worst-case of 5 guesses and average-case of 4.476 guesses.  
The answer contains two digits. The first is exact position, the second is wrong position.  

[Knuths artikel](https://www.cs.uni.edu/~wallingf/teaching/cs3530/resources/knuth-mastermind.pdf)
[Pythonkod](https://github.com/catlzy/knuth-mastermind)

Here are some example answers. There are 15 variants. 00 01 02 03 04 10 11 12 13 20 21 22 30 31 40
The parameters can be swapped. (I think)
```
ass(evaluate('AABB','ABCD'),'11')
ass(evaluate('ABCD','AABB'),'11')
ass(evaluate('5522','1234'),'01')
ass(evaluate('4335','1234'),'11')
ass(evaluate('1415','1234'),'11')
ass(evaluate('3345','1234'),'02')
ass(evaluate('2314','1234'),'13')
ass(evaluate('1234','1234'),'40')
```

Keys ABCDEF + Backspace works
