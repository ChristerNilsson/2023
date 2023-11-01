(ns user)

(defn fib [n] (if (< n 2) 1 (+ (fib (- n 1)) (fib (- n 2)))))

(print (time (fib 25)))

