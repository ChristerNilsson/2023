# Knuth's Five Guess Algorithm Implementation 

## 5040

[Try it!](https://christernilsson.github.io/2023/037-knuth-mastermind_5040/)

This repository contains a python implementation of Knuth's Five Guess algorithm for the board game Mastermind.  
This program uses a version of Mastermind that has 4 symbols, 10 colors, and with no repetition.  
The program solves all 5040 codes, and has a worst-case of 5 guesses and average-case of 4.227 guesses.  
The answer contains zero to four distances between 0 and 3.  

Keys ABCDEFGHIJ + Backspace works

```
secret = EFGH
guess  = HFEG
answer = 0123
```

* antal kombinationer
* uttryck
* n
* max antal drag
* medeltal drag
```
  24 = 4*3*2*1   4 3 2.458  
 120 = 5*4*3*2   5 3 2.750
 360 = 6*5*4*3   6 4 2.997
 840 = 7*6*5*4   7 4 3.371
1680 = 8*7*6*5   8 5 3.698
3024 = 9*8*7*6   9 5 3.953
5040 = 10*9*8*7 10 5 4.227
```
