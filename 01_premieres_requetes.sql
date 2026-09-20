-- =====================================================
-- Premières requêtes — Admin Express COG Carto (IGN)
-- Table : raw.commune (SRID 2154, Lambert 93)
-- =====================================================

-- 1. Inventaire
SELECT count(*) FROM raw.commune;
SELECT * FROM raw.commune LIMIT 5;

-- 2. Filtrer : communes de Haute-Garonne
SELECT "NOM", "POPULATION"
FROM raw.commune
WHERE "INSEE_DEP" = '31'
ORDER BY "POPULATION" DESC
LIMIT 20;

-- 3. Densité par commune
-- Pas d'agrégation : chaque ligne contient déjà sa population et sa géométrie.
SELECT "NOM",
       "POPULATION",
       round((ST_Area(geom) / 1000000)::numeric, 2) AS surface_km2,
       round(("POPULATION" / (ST_Area(geom) / 1000000))::numeric, 2) AS densite_pop
FROM raw.commune
ORDER BY densite_pop DESC
LIMIT 5;

-- 4. Agrégation par département
-- On somme populations ET surfaces avant de diviser.
-- avg() des densités communales donnerait un résultat faux.
SELECT "INSEE_DEP",
       count(*) AS nb_communes,
       sum("POPULATION") AS population_totale,
       round((sum("POPULATION") / (sum(ST_Area(geom)) / 1000000))::numeric, 2) AS densite_pop
FROM raw.commune
GROUP BY "INSEE_DEP"
ORDER BY densite_pop DESC;

-- 5. Même calcul avec une CTE (plus lisible)
-- Un alias du SELECT n'est pas réutilisable dans le même SELECT :
-- la CTE crée une étape intermédiaire nommée.
WITH surfaces AS (
    SELECT "NOM", "POPULATION", ST_Area(geom) / 1000000 AS surface_km2
    FROM raw.commune
)
SELECT "NOM",
       round(surface_km2::numeric, 2) AS surface_km2,
       round(("POPULATION" / surface_km2)::numeric, 2) AS densite_pop
FROM surfaces
ORDER BY densite_pop DESC
LIMIT 5;
