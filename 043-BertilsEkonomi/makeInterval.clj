(import java.time.LocalDate)

(defn ass [a b] (if (= a b) "ok" (str "Assert failure: " a " != " b)))

(defn makeInterval [date]
	[
		(.withDayOfMonth date 1)
		(-> date
			(.plusMonths 1)
			(.withDayOfMonth 1)
			(.minusDays 1))])

(defn makeInterval_ [date] [ (.withDayOfMonth date 1) (.minusDays (.withDayOfMonth (.plusMonths date 1) 1) 1)])

(ass [(LocalDate/of 2023 10 01) (LocalDate/of 2023 10 31)] (makeInterval (LocalDate/of 2023 10 19)))
(ass [(LocalDate/of 2023 11 01) (LocalDate/of 2023 11 30)] (makeInterval (LocalDate/of 2023 11 15)))
