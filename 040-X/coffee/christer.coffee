fib = (n) -> if n < 2 then 1 else fib(n-1) + fib(n-2)

start = new Date() 
console.log fib 25
console.log new Date() - start
