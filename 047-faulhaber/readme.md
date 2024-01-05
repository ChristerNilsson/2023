# Faulhaber

[Try it!](https://christernilsson.github.io/2023/047-Faulhaber)

Faulhaber was a German mathematician that in 1631 found formulas for generating the first 23 sums.  
See https://mathworld.wolfram.com/FaulhabersFormula.html

* Have a look at the formulas using HP Prime Virtual Calculator (84 MB)
 * https://www.hpcalc.org/details/8939

 * 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 = 55
 * sum(i,i) = i/2 + i²/2
 * sum(i,i,1,10) = 55

 * 1 + 4 + 9 + 16 + 25 + 36 + 49 + 64 + 81 + 100 = 385
 * sum(i²,i) = (i + 3i² + 2i³) / 6
 * sum(i²,i,1,10) = 385

# Background 
https://www.whitman.edu/documents/academics/majors/mathematics/2019/Larson-Balof.pdf  
https://enigmaticcode.wordpress.com/tag/bernoulli-numbers/  

The program Ada Lovelace constructed finds the first Bernoulli numbers B1, B3, B5 och B7.  
With these you can find the sums of squares, cubes and so on.
```

287-212 BC Arkimedes found formula for sum(i²)
	476 Aryabhata found sum(i³)
		1019 Al-Karaji found up to sum(i^10)
		965-1039 Hayatham found sum(i^4)
				1560-1621 Harriot
				1580-1635 Faulhaber found formulas up to sum(i^23)
					1601-1665 Fermat found own formula for sim(i^4)
					1623-1662 Pascal found Arithmetical Triangle
					1642-1708 Takakaza discovered Bernoulli numbers
					1655-1705 Bernoulli found formula for Bernoulli Numbers
						1707-1783 Leonard Euler defined Bernoulli Numbers using the exponential function
							1842 Ada Lovelace made a Bernouilli program for Analytical Engine
```

The coefficients can also be found solving equation systems.

### Example 1: Find the formula for sum(i)
```
Find a and b using an + bn²

n=1 =>  a +  b = 1
n=2 => 2a + 4b = 1 + 2 = 3

Solving you will find a = 1/2 and b = 1/2
```

### Example 2: Find the formula for sum(i²)
```
Find a, b and c using an + bn² + cn³

n=1 =>   a +   b     c = 1*1 = 1
n=2 =>  2a +  4b +  8c = 1*1 + 2*2 = 5
n=3 =>  3a +  9b + 27c = 1*1 + 2*2 + 3*3 = 14

You will find a = 1/6, b = 1/2 and c = 1/3
```
### Exercise: Find the formula for sum(i³)
