


(defn pair [persons pairing=[]]
	(if (< (length pairing) N)
		(let [i 0]
			(while (< i (length persons))
				(let [j 0]
					(while (< j (length persons))
				)
	)
)

	if pairing.length == N then return pairing
	for a in persons
		for b in persons
			if a == b then continue # man kan inte möta sig själv
			if getMet a,b then continue # a och b får ej ha mötts tidigare
			mandatory = a.mandatory + b.mandatory
			if 2 == Math.abs mandatory then continue # Spelarna kan inte ha samma färg.
			newPersons = (p for p in persons when p not in [a,b])
			newPairing = pairing.concat [a,b]
			result = pair newPersons,newPairing
			if result.length == N then return result
	return []
