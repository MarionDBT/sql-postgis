-- =====================================================
-- 2026-10-15 — Fonctions de fenêtrage (OVER)
-- =====================================================

-- L'idée : OVER calcule sur un groupe de lignes SANS les fusionner.
--   GROUP BY → moins de lignes en sortie (une par groupe)
--   OVER     → autant de lignes, avec une colonne calculée en plus
-- Question à se poser : est-ce que je veux moins de lignes,
-- ou autant de lignes avec une colonne de plus ?

-- 1. Population du département répétée sur chaque commune
-- Aucun GROUP BY : les 588 communes restent affichées.
SELECT "NOM",
       "INSEE_DEP",
       "POPULATION",
       sum("POPULATION") OVER (PARTITION BY "INSEE_DEP") AS pop_departement
FROM raw.commune
WHERE "INSEE_DEP" = '31'
ORDER BY "POPULATION" DESC;

-- 2. Part de chaque commune dans la population de son département
-- Impossible avec GROUP BY : le numérateur (population communale)
-- aurait disparu à l'agrégation.
-- L'alias pop_departement n'est pas réutilisable → on réécrit la fenêtre.
-- Calcul complet d'abord, arrondi en dernier.
SELECT "NOM",
       "POPULATION",
       round("POPULATION" / sum("POPULATION") OVER (PARTITION BY "INSEE_DEP")::numeric * 100, 2) AS pourcentage_pop
FROM raw.commune
WHERE "INSEE_DEP" = '31'
ORDER BY "POPULATION" DESC;

-- 3. Classement des communes à l'intérieur de chaque département
-- ORDER BY À L'INTÉRIEUR du OVER : il dit dans quel ordre numéroter.
-- Le compteur repart à 1 à chaque partition.
-- Cas d'usage classique en entretien : « les 3 plus gros clients par région »,
-- « la dernière commande de chaque utilisateur ».
SELECT "NOM",
       "INSEE_DEP",
       "POPULATION",
       row_number() OVER (PARTITION BY "INSEE_DEP" ORDER BY "POPULATION" DESC) AS rang
FROM raw.commune
WHERE "INSEE_DEP" IN ('31', '09', '32')
ORDER BY "INSEE_DEP", rang;

-- À retenir
-- • PARTITION BY définit le découpage ; omis, la fenêtre couvre toute la table.
-- • Toutes les fonctions d'agrégation s'utilisent avec OVER (sum, count, avg…),
--   plus les fonctions de classement (row_number, rank) qui n'existent que là.
-- • IN ('31','09','32') : raccourci pour plusieurs valeurs possibles.

-- 4. rank() vs row_number() — différence sur les ex æquo
--   row_number : 1, 2, 3, 4 (départage arbitrairement)
--   rank       : 1, 2, 2, 4 (même rang, saute le suivant)
--   dense_rank : 1, 2, 2, 3 (même rang, ne saute pas)

-- 5. lag() — valeur de la ligne précédente
-- L'outil des séries temporelles : comparer une mesure à la précédente.
-- Exemple (table de relevés de capteurs) :
--   SELECT capteur, horodatage, temperature,
--          temperature - lag(temperature)
--            OVER (PARTITION BY capteur ORDER BY horodatage) AS variation
--   FROM releves;
-- PARTITION BY capteur : sinon on compare deux capteurs différents.
-- ORDER BY horodatage  : définit ce que « précédent » signifie.
-- La 1re ligne de chaque partition vaut NULL (pas de prédécesseur).
-- Usages : détection d'anomalies, croissance mensuelle, délai entre
-- deux événements, trous dans une série. Central en maintenance prédictive.
-- lead() fait l'inverse : la ligne suivante.
