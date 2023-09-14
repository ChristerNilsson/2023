# 2023-015-Openings

Databasen innehåller 3.8M partier. Mha dessa konstrueras ett träd.

Pythonprogrammet läser in alla partier som inleds med '1. e4 e5 2. Nf3 Nc6 3. Bc4'
och skapar tree.json

Spelöppningsträdets GUI hanteras av sketch.coffee

Tanken var att hitta något sätt att hantera spelöppningsfällor, men just där tog jag en paus.
Inte helt enkelt att välja bästa drag för vit eller svart.

Troligen bör man välja något av de vanligaste dragen,
men samtidigt vara beredd på att motståndaren gör ett svagare drag
där man måste tänka till för att hitta motgift.
