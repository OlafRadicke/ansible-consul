SELECT "Bereite Datenbank vor....";

-- clean up
DROP TABLE IF EXISTS  price_list;
DROP TABLE IF EXISTS maximum_price;
DROP TABLE IF EXISTS invoice;
DROP VIEW IF EXISTS mo_pricing;
DROP VIEW IF EXISTS max_mo_pricing;

CREATE TABLE price_list (
    pk_categoryid INTEGER primary key autoincrement,
-- Ziffernbezeichner
    performance_id      TEXT,
-- Punktwert
    point_value REAL,
-- Preise in Währungseinheit
    money_value REAL,
-- Welche Währungsart
    currency    TEXT,
-- Zu welcher Preisliste gehört der Preis?
    price_list_id
);


INSERT INTO price_list (performance_id, money_value, price_list_id) VALUES ("300b", 0.04, "mo");
INSERT INTO price_list (performance_id, money_value, price_list_id) VALUES ("5466", 0.22, "mo");
INSERT INTO price_list (performance_id, money_value, price_list_id) VALUES ("1745", 0.34, "mo");
INSERT INTO price_list (performance_id, money_value, price_list_id) VALUES ("8466", 1.05, "mo");
-- Noch ein wenig Hungergrundrauschen...
INSERT INTO price_list (performance_id, money_value, price_list_id) VALUES ("300b", 0.03, "special");



CREATE TABLE maximum_price (
    pk_categoryid INTEGER primary key autoincrement,
-- Ziffernbezeichner
    performance_id      TEXT,
-- Punktwert
    point_value REAL,
-- Preise in Währungseinheit
    money_value REAL,
-- Welche Währungsart
    currency    TEXT,
-- Zu welcher Preisliste gehört der Preis?
    price_list_id
);


INSERT INTO maximum_price (performance_id, money_value, price_list_id) VALUES ("8466", 5.34, "mo");
-- Noch ein wenig Hungergrundrauschen...
INSERT INTO maximum_price (performance_id, money_value, price_list_id) VALUES ("300b", 0.54, "mo");


CREATE TABLE invoice (
    pk_categoryid INTEGER primary key autoincrement,
--  Einsender ID
    submitter_id      TEXT,
-- Ziffernbezeichner
    performance_id    TEXT,
-- (vorläufige/interne) Rechnungsnummer
    invoice_id        TEXT,
-- Kommentartext
    commenttext        TEXT
);

INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "001", "8466", "004");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "001", "8466", "004");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "001", "8466", "004");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "001", "8466", "004");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "001", "8466", "004");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "001", "8466", "004");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "001", "5466", "004");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "001", "5466", "004");
-- Noch ein wenig Hungergrundrauschen...
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "001", "300b", "006");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "001", "1745", "007");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "003", "5466", "009");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "003", "8466", "009");
INSERT INTO invoice (submitter_id, performance_id, invoice_id) VALUES ( "003", "8466", "009");

SELECT ".....Beginne mit Berechnungen!";


SELECT "#######################################################################";
SELECT "   ZWISCHENSCHRITT: Alle Rechnungsposten von Rechnung '004':";
SELECT "-----------------------------------------------------------------------";

SELECT * FROM  invoice WHERE
   invoice.invoice_id = "004" ;


SELECT "#######################################################################";
SELECT "   ZWISCHENSCHRITT: In einem view die Ziffern einer Rechnung der Preisliste 'mo' zuordnen:";
SELECT "-----------------------------------------------------------------------";

CREATE VIEW mo_pricing
AS SELECT
    invoice.submitter_id AS submitter_id,
    invoice.invoice_id AS invoice_id,
    invoice.performance_id,
    price_list.money_value,
    invoice.commenttext
FROM invoice, price_list
WHERE invoice.performance_id = price_list.performance_id
AND price_list.price_list_id = "mo";


SELECT "#######################################################################";
SELECT "   ZWISCHENSCHRITT: view mo_pricing:";
SELECT "-----------------------------------------------------------------------";

PRAGMA table_info(mo_pricing);
SELECT * FROM mo_pricing;


SELECT "#######################################################################";
SELECT "   ZWISCHENSCHRITT: Gesamtpreisst für alle Posten der Rechnung '004' ermitteln (ohne Höchstwert):";
SELECT "Erwartetes Ergebnis: 1.05 * 6 + 0.22 * 2 = 6.74";
SELECT "-----------------------------------------------------------------------";

SELECT SUM( money_value ) FROM mo_pricing WHERE invoice_id = "004";


SELECT "#######################################################################";
SELECT "   ZWISCHENSCHRITT: Zwischensumme für Ziffer 8466 der Rechnung '004' ermitteln (ohne Höchstwert):";
SELECT "Erwartetes Ergebnis: 1.05 * 6 = 6.3";
SELECT "-----------------------------------------------------------------------";

SELECT SUM( money_value )
FROM mo_pricing
WHERE invoice_id = "004"
AND performance_id ="8466";


SELECT "#######################################################################";
SELECT "   ZWISCHENSCHRITT: Höchstpreis für die Ziffer 8466 ermitteln:";
SELECT "Erwartetes Ergebnis: 5.34";
SELECT "-----------------------------------------------------------------------";

SELECT money_value FROM maximum_price WHERE performance_id = "8466";


SELECT "#######################################################################";
SELECT "   ZWISCHENSCHRITT: Überschreiten des Höchstpreis für die Ziffer 8466 ermitteln:";
SELECT "Erwartetes Ergebnis: Höchstpreis überschritten für 8466 und für 5466 nicht";
SELECT "-----------------------------------------------------------------------";

-- SELECT DISTINCT performance_id,
SELECT performance_id,
    CASE
        WHEN
            (
                SELECT SUM( money_value )
                FROM mo_pricing
                WHERE invoice_id = "004"
            ) > (SELECT money_value FROM maximum_price WHERE performance_id = mo_pricing.performance_id)
        THEN "Höchstpreis überschritten"
        ELSE "Höchstpreis nicht überschritten"
    END
    FROM mo_pricing
    WHERE invoice_id = "004";


SELECT "#######################################################################";
SELECT "   ZWISCHENSCHRITT: was ist der Rückgabewert für ein nicht existierenden  Höchstpreis?";
SELECT "-----------------------------------------------------------------------";

SELECT maximum_price.money_value
FROM maximum_price, mo_pricing
WHERE maximum_price.performance_id = "rfggf";

SELECT "#######################################################################";
SELECT "   ZWISCHENSCHRITT: Erstelle Tabelle in der Überschreiten des Höchstpreis ";
SELECT "dazu führt, das alle Einzelposten der Rechnung auf 0.00 gesetzt werden";
SELECT "und ein weitere Posten auf die Rechnung gesetzt wird der den Maximalpreis";
SELECT "enthält.";
SELECT "Erwartetes Ergebnis:";
SELECT "1.) Für Rechnung 004 wird der max.Preis für Posten 8466 erreicht und die Einzelposten";
SELECT "auf 0.00 gesetzt. 2.) Es gibt eine Zusätzliche Zeile mit dem max. Wert.";
SELECT "3.) Der Posten 8466 auf Rechnung 009 erreicht nicht den max. Wert und wird";
SELECT "einzeln abgerechnet. 4.) Der max. wert für Posten 8466 wird mit 0.00 veranschlagt";
SELECT "-----------------------------------------------------------------------";

CREATE VIEW max_mo_pricing AS
SELECT first_round.submitter_id, first_round.invoice_id , first_round.performance_id,
    CASE
        WHEN
-- Wurde die Höchstwertregel überschritten?
            (
                SELECT SUM( mo_pricing.money_value )
                FROM mo_pricing
                WHERE mo_pricing.invoice_id = first_round.invoice_id
                AND mo_pricing.performance_id = first_round.performance_id
            ) > (
                SELECT maximum_price.money_value
                FROM maximum_price
                WHERE maximum_price.performance_id = first_round.performance_id
            )
-- Wenn keine Höchstwertregel gefunden wird, gib Einzelpreis zurück
            AND (
                SELECT maximum_price.money_value
                FROM maximum_price
                WHERE maximum_price.performance_id = first_round.performance_id
            ) IS NOT NULL
-- Höchstpreis überschritten; setze alle Posten auf 0.00
        THEN 0
-- Es greift keine Höchstwertregel; Verwende Normal Preiss
        ELSE first_round.money_value
   END AS price,
-- Kommentarzeile....
   CASE
        WHEN
-- Wurde die Höchstwertregel überschritten?
            (
                SELECT SUM( mo_pricing.money_value )
                FROM mo_pricing
                WHERE mo_pricing.invoice_id = first_round.invoice_id
                AND mo_pricing.performance_id = first_round.performance_id
            ) > (
                SELECT maximum_price.money_value
                FROM maximum_price
                WHERE maximum_price.performance_id = first_round.performance_id
            )
-- Wenn keine Höchstwertregel gefunden wird, gib Einzelpreis zurück
            AND (
                SELECT maximum_price.money_value
                FROM maximum_price
                WHERE maximum_price.performance_id = first_round.performance_id
            ) IS NOT NULL
-- Höchstpreis überschritten. Ergänze um Posten Kommentar.
        THEN "Maximalpreis überschritten"
-- Es greift keine Höchstwertregel; Verwende Normalpreis und setze max. Wert auf 0.00
        ELSE "Höchstwert nicht erreicht"
    END AS comment
-- Erster Durchlauf mit Namen "first_round"
    FROM mo_pricing AS first_round
UNION ALL
SELECT DISTINCT second_round.submitter_id,  second_round.invoice_id, second_round.performance_id,
    CASE
        WHEN
-- Wurde die Höchstwertregel überschritten?
            (
                SELECT SUM( mo_pricing.money_value )
                FROM mo_pricing
                WHERE mo_pricing.invoice_id = second_round.invoice_id
                AND mo_pricing.performance_id = second_round.performance_id
            ) > (
                SELECT maximum_price.money_value
                FROM maximum_price
                WHERE maximum_price.performance_id = second_round.performance_id
            )
-- Wenn keine Höchstwertregel gefunden wird, gib Einzelpreis zurück
            AND (
                SELECT maximum_price.money_value
                FROM maximum_price
                WHERE maximum_price.performance_id = second_round.performance_id
            ) IS NOT NULL
-- Höchstpreis überschritten. Ergänze um Posten Maximalpreis
        THEN (SELECT money_value FROM maximum_price WHERE maximum_price.performance_id = second_round.performance_id)
-- Es greift keine Höchstwertregel; Verwende Normalpreis und setze max. Wert auf 0.00
        ELSE second_round.performance_id = "max preis" AND 0
    END AS price,
-- Kommentarzeile....
    CASE
        WHEN
-- Wurde die Höchstwertregel überschritten?
            (
                SELECT SUM( mo_pricing.money_value )
                FROM mo_pricing
                WHERE mo_pricing.invoice_id = second_round.invoice_id
                AND mo_pricing.performance_id = second_round.performance_id
            ) > (
                SELECT maximum_price.money_value
                FROM maximum_price
                WHERE maximum_price.performance_id = second_round.performance_id
            )
-- Wenn keine Höchstwertregel gefunden wird, gib Einzelpreis zurück
            AND (
                SELECT maximum_price.money_value
                FROM maximum_price
                WHERE maximum_price.performance_id = second_round.performance_id
            ) IS NOT NULL
-- Höchstpreis überschritten. Ergänze um Posten Kommentar.
        THEN "Maximalpreis für Ziffer überschritten"
-- Es greift keine Höchstwertregel; Verwende Normalpreis und setze max. Wert auf 0.00
        ELSE "Maximalpreis für Ziffer nicht erreicht"
    END AS comment
    FROM mo_pricing AS second_round
-- Nur berücksichtigen nur wenn Höchstwert vorhanden
    WHERE performance_id IN (SELECT performance_id FROM maximum_price)
;


SELECT * FROM max_mo_pricing;
-- Ergebnis müsste sein 1.05 * 6 = 6.3
-- Höchstwertregel               = 5.34
--                        + 0.22 = 5.56

-- clean up
DROP TABLE price_list;
DROP TABLE maximum_price;
DROP TABLE invoice;
DROP VIEW mo_pricing;
DROP VIEW IF EXISTS max_mo_pricing;

-- Kommando zum ausführen: sqlite3 example.db < ./simple_maximum_price.sql
