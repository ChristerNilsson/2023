import os,re,shutil
import pandas as pd

ANY = ".*"

def hamta(typ,directory,yymm, pattern):

	if not os.path.isdir(directory):
		print(f"The directory '{directory}' does not exist.")
		return []

	regex = re.compile(pattern)
	matching_files = [filename for filename in os.listdir(directory) if regex.match(filename)]

	print(typ,':')
	for filename in matching_files:
		print('  ',filename)
		if typ=='Inbetalningar':
			newName = filename.replace('.xlsx','.csv')
			data = pd.read_excel(directory + '/' + filename)
			data.to_csv(directory + '/' + newName, index=False)
			shutil.move(directory + '/' + newName, directory + '/' + str(yymm))
		shutil.move(directory + '/' + filename, directory + '/' + str(yymm))

def hamtaAlla(katalog='C:/github/2023/043-BertilsEkonomi/data', yymm=2310):
	hamta("Kontoutdrag",  katalog, yymm, f"Transaktioner_{ANY}-11-12_{ANY}.csv")
	hamta("Utbetalningar",katalog, yymm, f"Sok_utbetalning 2023-11{ANY}.txt")
	hamta("Inbetalningar",katalog, yymm, f"Bg5139-8659_Insättningsuppgifter_202309{ANY}Belopp.xlsx")

hamtaAlla()
