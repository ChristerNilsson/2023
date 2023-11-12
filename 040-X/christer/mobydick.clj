(ns user (:require [clojure.string :as str]))

(def book (slurp "C:/github/2023/040-X/christer/mobydick.txt"))

(count book)
       
(def words (str/split book #"[^a-zA-Z]+"))

;; (def words (re-seq #"[\w|’]+" book))

(count words)

(take 10 words)

(def common-words #{"for" "all" "by" "not" "from" "on" "this" "at" "his" "s" "is" "was" "the" "of" "and" "a" "to" "in" "that" "his " "it" "with" "i" "as" "he" "but"})

common-words
(count common-words)

(->> words
     (map str/lower-case) 
     (remove common-words)
     (frequencies)
     (sort-by val)
     (reverse)
     (take 20))

(->> words
     (map str/lower-case)
     (distinct) 
     (sort-by count)
     (take-last 20)
     (reverse)
     (group-by count))
     
(defn palindrome? [s]
  (= (seq s) (reverse s)))

(palindrome? "sirap i paris")
(palindrome? "slisk")

(->> words
     (distinct)
     (filter palindrome?)
     (sort-by count)
     (last))


