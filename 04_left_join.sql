-- =====================================================
-- 2026-11-05 — LEFT JOIN, DISTINCT, HAVING
-- =====================================================

-- 1. Communes sans aucune adresse dans la BAN (contrôle de complétude)
-- JOIN ne peut pas répondre : il écarte les lignes sans correspondance.
-- LEFT JOIN garde toutes les lignes de gauche ; les colonnes de droite
-- valent NULL quand il n'y a pas de correspondance — c'est ce NULL
-- qui isole les orphelins.
-- Nullité : IS NULL, jamais = NULL.
SELECT c."NOM"
FROM raw.commune c
LEFT JOIN raw.adresses a ON a.code_insee = c."INSEE_COM"
WHERE a.code_insee IS NULL
  AND c."INSEE_DEP" = '31'
ORDER BY c."NOM";
-- Résultat : 0 ligne → couverture BAN complète sur la Haute-Garonne.

-- 2. Validation du contrôle précédent
-- Un résultat vide ne vaut que si la requête sait renvoyer quelque chose.
-- Sans le filtre départemental, les autres départements remontent
-- (seules les adresses du 31 ont été importées).
SELECT c."INSEE_DEP", count(*) AS nb_communes_sans_adresse
FROM raw.commune c
LEFT JOIN raw.adresses a ON a.code_insee = c."INSEE_COM"
WHERE a.code_insee IS NULL
GROUP BY c."INSEE_DEP"
ORDER BY nb_communes_sans_adresse DESC
LIMIT 10;

-- 3. Adresses et voies distinctes par commune
-- count(*) compte les lignes ; count(DISTINCT x) ne compte chaque
-- valeur qu'une fois. Une rue de 200 numéros = 200 adresses, 1 voie.
-- Le rapport entre les deux décrit la forme urbaine.
SELECT c."INSEE_DEP",
       c."NOM",
       count(*) AS nb_adresses,
       count(DISTINCT a.nom_voie) AS nb_voies
FROM raw.commune c
JOIN raw.adresses a ON a.code_insee = c."INSEE_COM"
WHERE c."INSEE_DEP" = '31'
GROUP BY c."INSEE_DEP", c."NOM"
ORDER BY nb_adresses DESC;

-- 4. Communes comptant plus d'adresses que d'habitants
-- La condition contient un count() → HAVING, et on y réécrit le calcul.
-- POPULATION doit être dans le GROUP BY pour être utilisable ici.
SELECT c."NOM", count(*) AS nb_adresses, c."POPULATION"
FROM raw.commune c
JOIN raw.adresses a ON a.code_insee = c."INSEE_COM"
GROUP BY c."NOM", c."POPULATION"
HAVING count(*) > c."POPULATION"
ORDER BY nb_adresses DESC;

-- À retenir
-- ORDRE D'EXÉCUTION :
--   FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
-- Tout en découle :
--   • WHERE passe avant GROUP BY : les agrégats n'existent pas encore.
--   • Les alias naissent au SELECT : inutilisables dans WHERE et HAVING,
--     utilisables dans ORDER BY seulement.
-- ORDRE D'ÉCRITURE : HAVING s'écrit APRÈS GROUP BY (on ne filtre pas
--   des groupes qui n'existent pas).
-- Réflexe : condition avec count/sum/avg → HAVING ; sinon → WHERE.
-- LEFT JOIN + IS NULL = recherche d'orphelins, base du contrôle qualité.
