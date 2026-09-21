-- 2026-09-21
SELECT "INSEE_DEP",
count("NOM") AS nb_communes,
sum("POPULATION") AS pop_totale,
round(AVG("POPULATION")::numeric,0) as moyenne_population
FROM raw.commune 
GROUP BY "INSEE_DEP" 
ORDER BY "INSEE_DEP" ;
