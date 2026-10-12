-- =====================================================
-- 2026-09-21 — GROUP BY, puis WHERE
-- =====================================================

-- Squelette : ordre fixe des clauses
-- SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT

-- 1. GROUP BY : une ligne par département, plusieurs agrégations
-- La colonne de regroupement doit apparaître dans le SELECT,
-- sinon on ne sait pas à quel département correspond chaque ligne.
SELECT "INSEE_DEP",
       count("NOM") AS nb_communes,
       sum("POPULATION") AS pop_totale,
       round(avg("POPULATION")::numeric, 0) AS moyenne_population
FROM raw.commune
GROUP BY "INSEE_DEP"
ORDER BY "INSEE_DEP";

-- 2. WHERE sans GROUP BY : une ligne par commune
-- Communes de plus de 10 000 habitants, rangées par département,
-- puis par population décroissante dans chaque département.
-- DESC ne s'applique qu'à la colonne juste devant lui.
SELECT "INSEE_DEP",
       "NOM",
       "POPULATION"
FROM raw.commune
WHERE "POPULATION" > 10000
ORDER BY "INSEE_DEP", "POPULATION" DESC;

-- À retenir
-- • FROM vient toujours avant GROUP BY.
-- • Une colonne calculée prend un alias (AS ...), sinon elle s'appelle "count" ou "round".
-- • round() à deux arguments exige ::numeric.
-- • Question à se poser : combien de lignes je veux en sortie ?
--   Une par commune → pas de GROUP BY. Une par département → GROUP BY.

-- À faire mercredi
-- • Nombre de communes de plus de 10 000 habitants par département (WHERE + GROUP BY).
-- • Communes de Haute-Garonne de moins de 500 habitants.
-- • Communes dont le nom commence par « Saint » (trouver l'opérateur).

-- =====================================================
-- 2026-09-23 — WHERE + GROUP BY, AND, LIKE
-- =====================================================

-- 1. Nombre de communes de plus de 10 000 habitants par département
SELECT "INSEE_DEP",
       count("NOM") AS nb_communes
FROM raw.commune
WHERE "POPULATION" > 10000
GROUP BY "INSEE_DEP"
ORDER BY "INSEE_DEP";

-- 2. Communes de Haute-Garonne de moins de 500 habitants
-- Deux conditions combinées avec AND. Pas de regroupement : une ligne par commune.
SELECT "NOM", "POPULATION"
FROM raw.commune
WHERE "INSEE_DEP" = '31' AND "POPULATION" < 500
ORDER BY "POPULATION";

-- 3. Communes dont le nom commence par « Saint »
-- LIKE cherche un motif ; % remplace n'importe quelle suite de caractères.
-- LIKE est sensible à la casse ; ILIKE (PostgreSQL) ne l'est pas.
SELECT "NOM", "INSEE_DEP"
FROM raw.commune
WHERE "NOM" LIKE 'Saint%'
ORDER BY "INSEE_DEP";

-- À retenir
-- • FROM avant WHERE : on ouvre le carton avant de trier.
-- • HAVING seulement pour filtrer sur une agrégation (count, sum, avg).
--   Un filtre sur une colonne simple va dans WHERE.

-- 2026-10-05 — SQLZoo : SELECT basics (QCM, rien à copier)

--Modify it to show the population of Germany
SELECT population FROM world 
  WHERE name = 'Germany'

-- Show the name and the population for 'Sweden', 'Norway' and 'Denmark'.
SELECT name, population FROM world
  WHERE name IN ('Sweden', 'Norway', 'Denmark');

--Modify it to show the country and the area for countries with an area between 200,000 and 250,000.
SELECT name, area FROM world
WHERE area BETWEEN 200000 AND 250000

--1. Select the code which produces this table
-- name	population
-- Bahrain	1234571
-- Swaziland	1220000
-- Timor-Leste 1066409

SELECT name, population
  FROM world
 WHERE population BETWEEN 1000000 AND 1250000

--2. Pick the result you would obtain from this code:

 SELECT name, population
      FROM world
      WHERE name LIKE "Al%"

--Table-E
--Albania	3200000
--Algeria	32900000

--3. Select the code which shows the countries that end in A or L

SELECT name FROM world
 WHERE name LIKE '%a' OR name LIKE '%l'

--4. Pick the result from the query
SELECT name,length(name)
FROM world
WHERE length(name)=5 and region='Europe'

--name	length(name)
--Italy	5
--Malta	5
--Spain	5

--5. Here are the first few rows of the world table:
--name	region	area	population	gdp
--Afghanistan	South Asia	652225	26000000	
--Albania	Europe	28728	3200000	6656000000
--Algeria	Middle East	2400000	32900000	75012000000
--Andorra	Europe	468	64000	

--Pick the result you would obtain from this code:
--SELECT name, area*2 FROM world WHERE population = 64000
Andorra	936

--6. Select the code that would show the countries with an area larger than 50000 and a population smaller than 10000000
SELECT name, area, population
  FROM world
 WHERE area > 50000 AND population < 10000000

--7. Select the code that shows the population density of China, Australia, Nigeria and France

SELECT name, population/area
  FROM world
 WHERE name IN ('China', 'Nigeria', 'France', 'Australia')

-- 2026-10-07 — SQLZoo : SELECT basics (QCM, rien à copier)

--Division calcul du PIB- le nom et le pib par habitant pour les pays ayant une population supérieure ou égale à 200 millions.
SELECT name, GDP/population as GDP 
FROM world
WHERE population >= 200000000

--le nom et la population en millions pour les pays d'Amérique du sud
SELECT name, population/1000000 as population
from world
Where continent like 'South America'

--le nom et la population pour la France, l'Allemagne et l'Italie
SELECT name, population
FROM world
where name IN ('France', 'Germany', 'Italy')

--le nom des pays contenant 'United'
SELECT name
FROM world 
where name like '%United%'

--les pays dont l'aire est supérieure à 3m et la population est supérieure à 250m
SELECT name, population, area
FROM world
where area > 3000000 OR population > 250000000

--Les pays dont l'aire est supérieur à 3m OU la population est sup à 250m mais pas les deux.
SELECT name, population, area 
FROM world
where (population>250000000) XOR (area>3000000)

-- =====================================================
-- 2026-10-12 — Révision des jointures
-- Réécriture à froid, 4 jours après la séance du 08/10
-- =====================================================

-- 1. Nombre d'adresses par commune (jointure attributaire)
SELECT c."NOM",
       count(a.id) AS nb_adresses
FROM raw.commune c
JOIN raw.adresses a ON c."INSEE_COM" = a.code_insee
GROUP BY c."NOM"
ORDER BY nb_adresses DESC
LIMIT 20;

-- 2. Nombre d'adresses dans une commune donnée
-- count() compte, il ne filtre pas : le filtre va dans le WHERE, une seule fois.
SELECT c."NOM",
       count(a.id) AS nb_adresses
FROM raw.commune c
JOIN raw.adresses a ON c."INSEE_COM" = a.code_insee
WHERE c."NOM" = 'Pibrac'
GROUP BY c."NOM";

-- 3. Adresses et population par commune de Haute-Garonne
-- POPULATION doit être dans le GROUP BY : toute colonne du SELECT qui n'est
-- pas agrégée doit y figurer.
SELECT c."NOM",
       c."POPULATION",
       count(a.id) AS nb_adresses
FROM raw.commune c
JOIN raw.adresses a ON c."INSEE_COM" = a.code_insee
WHERE c."INSEE_DEP" = '31'
GROUP BY c."NOM", c."POPULATION"
ORDER BY nb_adresses DESC;

-- 4. Communes de plus de 1 000 adresses et moins de 5 000 habitants
-- Deux conditions, deux emplacements différents :
--   population      → colonne simple, pas d'agrégation → WHERE
--   nombre d'adresses → produit par count()            → HAVING
SELECT c."NOM",
       c."POPULATION",
       count(a.id) AS nb_adresses
FROM raw.commune c
JOIN raw.adresses a ON c."INSEE_COM" = a.code_insee
WHERE c."POPULATION" < 5000
GROUP BY c."NOM", c."POPULATION"
HAVING count(a.id) > 1000
ORDER BY nb_adresses DESC;

-- À retenir
-- • Ordre RÉEL d'exécution : FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
--   Le SELECT arrive en avant-dernier, donc un alias est utilisable dans
--   ORDER BY mais jamais dans WHERE ni HAVING. Dans le HAVING, on réécrit
--   count(a.id) en entier.
-- • Guillemets doubles pour les identifiants ("INSEE_COM"), apostrophes
--   simples pour les valeurs ('31').
-- • LIKE sans % équivaut à = : réserver LIKE aux motifs.
-- • Regrouper sur l'identifiant (INSEE_COM) plutôt que sur le libellé :
--   deux communes peuvent porter le même nom.
-- • Erreur « entrée manquante de la clause FROM pour la table a » :
--   l'alias n'est pas déclaré, ou seule une partie de la requête est
--   sélectionnée dans l'éditeur.






