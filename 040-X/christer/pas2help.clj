(ns user (:require [clojure.string :as str]))

(defn ass [a,b]
  (if (not= a b)
    (str "assert failure: " a " is not " b)
    "ok"))

(def text (slurp "C:/github/2023/040-X/xal.pas"))

(count text)

;;;;;;;;;;;;;;;;;;;;;;;;;;;

(def any ".+?") ;; # zero or one character, lazy
(def DOTALL "(?s)")

(defn brackets [s] (str "<" s ">"))
(ass "<x>" (brackets "x"))

(defn opt [s] (str s "?"))
(ass "x?" (opt "x"))

(defn group [s] (str "(" s ")"))
(ass "(x)" (group "x"))

(defn q [s] (str/join "" (map #(str "\\" %) s)))
(ass "\\(\\*" (q "(*"))

(def nl (q "n"))
(ass "\\n" nl)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defn pascalComment [s] (str (q "(*") s (q "*)")))
(ass "\\(\\*x\\*\\)" (pascalComment "x"))

(def group1 (group (str " " (brackets any) (opt "*") ":")))
(ass "( <.+?>*?:)" group1)

(def group2 (group any))
(ass "(.+?)" group2)

;; (def rex (str DOTALL nl (pascalComment (str group1 (opt nl) group2 nl)))) 
(def rx #"(?s)\n\(\*( <.+?>*?:)\n?(.+?)\n\*\)")

(def rex 
  (str DOTALL nl 
       (pascalComment 
        (str 
         (group 
          (str " " 
               (brackets any) 
               (opt "*")
               ":")) 
         (opt nl) 
         (group any) 
         nl)))) 

(ass "(?s)\\n\\(\\*( <.+?>*?:)\\n?(.+?)\\n\\*\\)" rex)

(ass #"yxa" #"yxa")

;; (ass "\\n\\(\\*( <.+?>*?:)\\n?(.+?)\\n\\*\\)" rex)
;; (ass (re-pattern "\\n\\(\\*( <.+?>*?:)\\n?(.+?)\\n\\*\\)") (re-pattern rex))
;; "\\n\\(\\*( <.+?>*?:)\\n?(.+?)\\n\\*\\)"
;; "\\n\\(\\*( <.+?>*?:)\\n?(.+?)\\n\\*\\)"

;; nl + pascalComment(group1 + opt(nl) + group2 + nl)
;; ass(r'\n\(\*( <.+?>*?:)\n?(.+?)\n\*\)', rex)

;; (re-matches #"abc(.*)" "abcxyz")

;; (re-matches #"sd" "sdsdf<sdfsdf>sdfsdf")

;; (def regex           #"\n\(\*( <.+?>*?:)\n?(.+?)\n\*\)")

;; (def matches (re-seq #"\n\(\*( <.+?>*?:)\n?(.+?)\n\*\)" text))

(def matches (re-seq (re-pattern rex) text))
(count matches)
(defn third [lst] (nth lst 2))

(def bodies
  (->> matches
       (map third)))

bodies
(first bodies)

(clojure-version)
(System/getProperty "java.version")

