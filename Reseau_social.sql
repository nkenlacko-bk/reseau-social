 CREATE DATABASE RESEAU_SOCIAL;

 USE RESEAU_SOCIAL;

CREATE TABLE utilisateurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100)
);

insert into utilisateurs(nom) values('olivia' ),('leslie'),('maeva'),('mael'),('lauriane'),('flora'),('prince'),('alexia');

CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id INT REFERENCES utilisateurs(id),
    contenu TEXT,
    date DATE
);
insert into posts( utilisateur_id,contenu,date) values( 2,'image','2026-12-02'),(6,'video','2026-05-03'),(8,'image','2026-05-03'),(7,'audio','2026-05-03'),(2,'video','2026-05-03'),(7,'video','2026-05-03'),(3,'audio','2026-05-03'),(1,'image','2026-05-03');


CREATE TABLE commentaires (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT REFERENCES posts(id),
    utilisateur_id INT REFERENCES utilisateurs(id),
    contenu TEXT,
    date DATE
);
insert into commentaires(post_id,utilisateur_id,contenu,date) values(3,2,'image','2026-12-02'),(3,8,'video','2026-05-03'),(4,5,'image','2026-05-03'),(5,7,'audio','2026-05-03'),(6,7,'video','2026-05-03'),(3,4,'video','2026-05-03'),(7,6,'audio','2026-05-03'),(8,5,'image','2026-05-03');




CREATE TABLE likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT REFERENCES posts(id),
    utilisateur_id INT REFERENCES utilisateurs(id),
    date DATE
);
insert into likes(post_id,utilisateur_id,date) values(1,2,'2026-12-02'),(4,7,'2026-05-03'),(5,2,'2026-05-03'),(1,8,'2026-05-03'),(2,3,'2026-05-03'),(4,7,'2026-05-03'),(8,2,'2026-05-03'),(7,6,'2026-05-03');


DELIMITER &&
CREATE FUNCTION fn_nb_likes(p_post_id INT)
RETURNS INT 
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*)
    INTO total
    FROM likes
    WHERE post_id = p_post_id;
    RETURN total;
END &&
DELIMITER &&;



CREATE VIEW vue_1_top_3_posts_likes AS
(SELECT p.id,
       p.contenu,
       COUNT(l.id) AS nombre_likes
FROM posts p
LEFT JOIN likes l ON p.id = l.post_id
GROUP BY p.id, p.contenu
ORDER BY nombre_likes DESC
LIMIT 3);



CREATE VIEW vue_2_utilisateur_plus_commentaires AS
(SELECT u.id,
       u.nom,
       COUNT(c.id) AS nb_commentaires
FROM utilisateurs u
JOIN commentaires c ON u.id = c.utilisateur_id
GROUP BY u.id, u.nom
ORDER BY nb_commentaires DESC
LIMIT 1);



CREATE VIEW vue_3_moyenne_likes_post AS
(SELECT AVG(nb_likes) AS moyenne_likes
FROM (
    SELECT p.id,
           COUNT(l.id) AS nb_likes
    FROM posts p
    LEFT JOIN likes l ON p.id = l.post_id
    GROUP BY p.id
) t);



CREATE VIEW vue_4_posts_par_utilisateur AS
(SELECT u.id,
       u.nom,
       COUNT(p.id) AS nombre_posts
FROM utilisateurs u
LEFT JOIN posts p ON u.id = p.utilisateur_id
GROUP BY u.id, u.nom);



CREATE VIEW vue_5_moyenne_commentaires_post AS
(SELECT AVG(nb_commentaires) AS moyenne_commentaires
FROM (
    SELECT p.id,
           COUNT(c.id) AS nb_commentaires
    FROM posts p
    LEFT JOIN commentaires c ON p.id = c.post_id
    GROUP BY p.id
) t);



CREATE VIEW vue_6_post_plus_commente AS
(SELECT p.id,
       p.contenu,
       COUNT(c.id) AS nb_commentaires
FROM posts p
LEFT JOIN commentaires c ON p.id = c.post_id
GROUP BY p.id, p.contenu
ORDER BY nb_commentaires DESC
LIMIT 1);



CREATE VIEW vue_7_likes_par_mois AS
(SELECT EXTRACT(MONTH FROM date) AS mois,
       COUNT(*) AS nombre_likes
FROM likes
GROUP BY mois
ORDER BY mois);



CREATE VIEW vue_8_utilisateur_plus_actif AS
(SELECT u.id,
       u.nom,
       (
           COUNT(DISTINCT p.id) +
           COUNT(DISTINCT c.id)
       ) AS activite_totale
FROM utilisateurs u
LEFT JOIN posts p ON u.id = p.utilisateur_id
LEFT JOIN commentaires c ON u.id = c.utilisateur_id
GROUP BY u.id, u.nom
ORDER BY activite_totale DESC
LIMIT 1);



CREATE VIEW vue_9_moyenne_posts_jour AS
(SELECT AVG(nb_posts) AS moyenne_posts_jour
FROM (
    SELECT date,
           COUNT(*) AS nb_posts
    FROM posts
    GROUP BY date
) t);



CREATE VIEW vue_10_distribution_likes_utilisateur AS
(SELECT u.id,
       u.nom,
       COUNT(l.id) AS nombre_likes
FROM utilisateurs u
LEFT JOIN likes l ON u.id = l.utilisateur_id
GROUP BY u.id, u.nom
ORDER BY nombre_likes DESC);



CREATE VIEW vue_11_croissance_posts_mois AS
(SELECT EXTRACT(MONTH FROM date) AS mois,
       COUNT(*) AS nombre_posts
FROM posts
GROUP BY mois
ORDER BY mois);



CREATE VIEW vue_12_posts_sans_commentaire AS
(SELECT COUNT(*) AS nombre_posts_sans_commentaire
FROM posts p
LEFT JOIN commentaires c ON p.id = c.post_id
WHERE c.id IS NULL);



CREATE VIEW vue_13_moyenne_likes_utilisateur AS
(SELECT AVG(nb_likes) AS moyenne_likes_utilisateur
FROM (
    SELECT utilisateur_id,
           COUNT(*) AS nb_likes
    FROM likes
    GROUP BY utilisateur_id
) t);



CREATE VIEW vue_14_post_plus_reactions AS
(SELECT p.id,
       p.contenu,
       (
           COUNT(DISTINCT l.id) +
           COUNT(DISTINCT c.id)
       ) AS total_reactions
FROM posts p
LEFT JOIN likes l ON p.id = l.post_id
LEFT JOIN commentaires c ON p.id = c.post_id
GROUP BY p.id, p.contenu
ORDER BY total_reactions DESC
LIMIT 1);



CREATE VIEW vue_15_posts_par_annee AS
(SELECT EXTRACT(YEAR FROM date) AS annee,
       COUNT(*) AS nombre_posts
FROM posts
GROUP BY annee
ORDER BY annee);