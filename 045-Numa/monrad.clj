(+ 2 4)

(*)
(+)
(- 1)
(/ 2)

(range 10)

(defn my-count [coll]
	(reduce (fn [n _] (inc n)) 0 coll))

(my-count [1 2 3 4 "x"])
