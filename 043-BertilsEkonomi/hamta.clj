(require '[clojure.data.csv :as csv])
(require '[clojure.java.io :as io])
(require '[dk.ative.docjure :as docjure])

;;    <hamta typ,[frånkatalog],[namnmönster],[månad]>
;;    Exempel: 
;;    <hamta kontoutdrag,C:\Users\Bertil\Downloads,transaktioner*2023-11*.csv',2310'>
;;    <hamta utbetalningar',C:\Users\Bertil\Downloads',Sok_utbetalning 2023-11*.txt',2310'> 
;;    <hamta inbetalningar,C:\Users\Bertil\Downloads,-
;;       Bg5139-8659_Insättningsuppgifter_202310*Belopp.xlsx,2310> 
   
;;    $1 = Typ av fil - kontoutdrag, utbetalningar eller inbetalningar
;;    $2 = sökväg till nerladdningskatalog.
;;    $3 = mönster för filnamn.
;;    $4 = år pch månad, t ex "2309".

;;    Hitta fil nerladdad från SHB, byt namn på filen och flytta den till aktuell
;;    mapp (bokföringskatalogen).
;;    För inbetalningar, öppna i Excel och omvandla från .xlsx till .csv.

(defn csv-data->maps [csv-data]
  (map zipmap
       (->> (first csv-data) ;; First row is the header
            (map keyword) ;; Drop if you want string keys instead
            repeat)
       (rest csv-data)))

(defn read-csv [filename]
	(with-open [reader (io/reader filename)]
		(doall
			(csv-data->maps (csv/read-csv reader {:separator \;})))
		)

;; (with-open [writer (io/writer "out-file.csv")]
;;   (csv/write-csv writer
;;                  [["abc" "def"]
;;                   ["ghi" "jkl"]]))
)

(read-csv "data/Transaktioner_213339668_2023-11-12_1659.csv")


;; (defn hamta [frånmapp pattern nyttnamn tillmapp]
;; 	;; (def frånmapp (ifis 2 2 C:\Users\Bertil\Downloads))
;; 	;; (def tillMapp (cd))
;; 	(def årmånadTransaktioner (ifis 4 4 prevShortYearMonth)) ;; Example: 2310 
;; 	(def årmånadNerladdning ;; Nuvarande månad  Exempel: 2311 
;; 		(case (date) (format dd)(format dd)-(format dd)-(format dd) (xp 2)(xp 3))
;; 		)
;; 	(def pattern (ifis 3 3 
;; 			(case 1
				
;; 				 Kontoutdrag 
;; 				;; Exempel: transaktioner*2023-11*.csv 
;; 				transaktioner*(case årmånadNerladdning (format dd)(format dd) 20(xp 1)-(xp 2))*.csv
				
;; 				 Utbetalningar 
;; 				;; Exempel: Sok_utbetalning 2023-11*.txt 
;; 				Sok_utbetalning (case årmånadNerladdning (format dd)(format dd) 20(xp 1)-(xp 2))*.txt
				
;; 				 Inbetalningar 
;; 				;; Exempel: Bg5139-8659_Insättningsuppgifter_202310*Belopp.xlsx 
;; 				Bg5139-8659_Insättningsuppgifter_20årmånadTransaktioner*Belopp.xlsx
;; 				)))
;; 	(def nyttnamn (str (makeinterval årmånadTransaktioner) ".txt")
	
;; 	(c hamtafil frånmapp pattern nyttnamn tillmapp)
;; 	 1 4)
