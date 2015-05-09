SELECT "Bereite Datenbank vor....";

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
AS SELECT invoice.invoice_id, invoice.performance_id, price_list.money_value
FROM invoice, price_list
WHERE invoice.performance_id = price_list.performance_id
AND price_list.price_list_id = "mo";


SELECT "#######################################################################";
SELECT "   ZWISCHENSCHRITT: view mo_pricing:";
SELECT "-----------------------------------------------------------------------";

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
SELECT "   ZWISCHENSCHRITT: Überschreiten des Höchstpreis für die Ziffer 8466 ermitteln:";
SELECT "Erwartetes Ergebnis: ?????";
SELECT "-----------------------------------------------------------------------";

SELECT performance_id,
    CASE
        WHEN
            (
                SELECT SUM( money_value )
                FROM mo_pricing
                WHERE invoice_id = "004"
            ) > (SELECT money_value FROM maximum_price WHERE performance_id = mo_pricing.performance_id)
-- Höchstpreis überschritten setze alle Posten auf 0.00
        THEN 0
-- Verwende Normal Preiss
        ELSE mo_pricing.money_value
    END
    FROM mo_pricing
    WHERE invoice_id = "004"
UNION ALL
SELECT DISTINCT performance_id,
    CASE
        WHEN
            (
                SELECT SUM( money_value )
                FROM mo_pricing
                WHERE invoice_id = "004"
                AND performance_id = "8466"
            ) > (SELECT money_value FROM maximum_price WHERE performance_id = mo_pricing.performance_id)
-- Höchstpreis überschritten. Ergänze um Posten Maximalpreis
        THEN (SELECT money_value FROM maximum_price WHERE performance_id = "8466")
    END
    FROM mo_pricing
    WHERE invoice_id = "004";

-- Ergebnis müsste sein 1.05 * 6 = 6.3
-- Höchstwertregel               = 5.34
--                        + 0.22 = 5.56

DROP TABLE price_list;
DROP TABLE maximum_price;
DROP TABLE invoice;

-- Kommando zum ausführen: sqlite3 example.db < ./simple_maximum_price.sql
