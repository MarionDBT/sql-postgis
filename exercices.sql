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


