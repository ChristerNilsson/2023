(ns user (:require [clojure.string :as str]))

(defn ass [a,b] (if (= a b) "ok" (str "Assert failure: " a " != " b)))

;;;;;;;;;;;;;;;;;; general

(def any ".+?") ;; zero or one character, lazy
(ass ".+?" any)

(defn brackets [& s] (str "<" (str/join s) ">"))
(ass "<x>" (brackets "x"))

(defn opt [s] (str s "?"))
(ass "x?" (opt "x"))

(defn group [& s] (str "(" (str/join s) ")"))
(ass "(x)" (group "x"))

(defn q [s] (str/join "" (map #(str "\\" %) s)))
(ass "\\(\\*" (q "(*"))

(def nl (q "n"))
(ass "\\n" nl)

;;;;;;;;;;;;;;;;;;;;;;; application specific

(defn pascalComment [& s] (str nl (q "(*") (str/join s) (q "*)")))
(ass "\\n\\(\\*x\\*\\)"  (pascalComment "x"))

;; Man redigerar trädet på vänster sida
;; Högra sidan skapas automatiskt (Är den öht intressant utom för debug?)

(pascalComment      ;; \\n\\(\\*\\n(<.+?*?>):\\n?(.+?)\\n\\*\\)
 (group             ;;             (<.+?*?>)
  (brackets         ;;              <.+?*?>
   any              ;;               .+?
   (opt "*"))       ;;                  *?
  ":"               ;;                      :
  (opt nl)          ;;                       \\n?
  (group            ;;                           (.+?)
   any)             ;;                            .+?
  nl))              ;;                                \\n


