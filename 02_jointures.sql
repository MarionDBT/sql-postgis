-- =====================================================
-- 2026-10-08 — Jointures attributaires et spatiales
-- Tables : raw.commune (polygones, 35 000 lignes)
--          raw.adresses (points BAN Haute-Garonne, ~500 000 lignes)
-- =====================================================

-- 0. Import de la BAN et création de la géométrie
-- Le CSV ne contient que des colonnes lon/lat : PostGIS ne sait pas
-- encore que ce sont des coordonnées. On fabrique le point, on déclare
-- son système (4326 = WGS84), puis on reprojette en Lambert 93 pour
-- que les deux tables partagent le même SRID — condition indispensable
-- à toute jointure spatiale.
ALTER TABLE raw.adresses ADD COLUMN geom geometry(Point, 2154);

UPDATE raw.adresses
SET geom = ST_Transform(ST_SetSRID(ST_MakePoint(lon, lat), 4326), 2154);
-- Attention : ST_MakePoint(lon, lat) — x puis y, l'inverse de l'usage GPS.

-- 1. Index spatiaux (GIST, et non BTREE qui est le défaut)
-- Sans eux, chaque point est testé contre chaque polygone.
CREATE INDEX idx_adresses_geom ON raw.adresses USING GIST (geom);
CREATE INDEX idx_commune_geom  ON raw.commune  USING GIST (geom);

-- 2. Jointure ATTRIBUTAIRE — sur la clé commune
-- Temps mesuré : < 1 s
SELECT c."NOM",
       count(a.id) AS nb_adresses
FROM raw.commune c
JOIN raw.adresses a ON a.code_insee = c."INSEE_COM"
GROUP BY c."NOM"
ORDER BY nb_adresses DESC
LIMIT 20;

-- 3. Jointure SPATIALE — sans clé, sur la position
-- Temps mesuré : 15 s sur les 35 000 communes de France
SELECT c."NOM",
       count(a.id) AS nb_adresses
FROM raw.commune c
JOIN raw.adresses a ON ST_Contains(c.geom, a.geom)
GROUP BY c."NOM"
ORDER BY nb_adresses DESC
LIMIT 20;

-- 4. Même jointure spatiale, filtrée avant le JOIN
-- Temps mesuré : 3 s — facteur 5 gagné par une seule ligne.
SELECT c."NOM",
       count(a.id) AS nb_adresses
FROM raw.commune c
JOIN raw.adresses a ON ST_Contains(c.geom, a.geom)
WHERE c."INSEE_DEP" = '31'
GROUP BY c."NOM"
ORDER BY nb_adresses DESC
LIMIT 20;

-- À retenir
-- • JOIN n'est ni attributaire ni spatial : c'est la condition du ON qui décide.
-- • Les alias de table (c, a) sont déclarés dans le FROM/JOIN et n'existent
--   que le temps de la requête. Obligatoires dès que deux tables ont des
--   colonnes homonymes (geom ici).
-- • Un JOIN produit d'abord une table intermédiaire combinée ; le GROUP BY
--   l'écrase ensuite. C'est l'opération la plus coûteuse d'une requête.
-- • Filtrer AVANT de joindre : 15 s → 3 s.
-- • Quand une clé commune existe, la jointure attributaire l'emporte toujours.
--   La jointure spatiale sert quand il n'y a pas de clé (points GPS bruts).
