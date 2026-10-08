# sql-postgis

Requêtes SQL et PostGIS — apprentissage.
Données : Admin Express COG Carto (IGN) — communes de Haute-Garonne.
Premières requêtes : count, ST_Area, agrégation par département.

## À faire

Fonctions de fenêtrage (ROW_NUMBER, RANK, LAG).
Sous-requêtes et CTE sur des cas plus complexes.

## Notes

Couche COMMUNE importée dans le schéma `raw`, SRID 2154 forcé à l'import
(QGIS proposait un SRID interne non reconnu par PostGIS).

BAN Haute-Garonne importée dans raw.adresses (~500 000 points),
géométrie construite depuis lon/lat puis reprojetée en Lambert 93.
Index GIST sur les deux tables.
