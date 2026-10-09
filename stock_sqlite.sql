

SET SERVEROUTPUT ON;

-- ---------------------------------------------------------------------
-- 1. TABLE CREATION
-- ---------------------------------------------------------------------
DROP TABLE stock_prices PURGE;

CREATE TABLE stock_prices (
    stock_id      NUMBER(5)      PRIMARY KEY,
    trade_date    DATE           NOT NULL,
    company_name  VARCHAR2(20)   NOT NULL,
    open_price    NUMBER(10,2)   NOT NULL,
    high_price    NUMBER(10,2)   NOT NULL,
    low_price     NUMBER(10,2)   NOT NULL,
    close_price   NUMBER(10,2)   NOT NULL,
    volume        NUMBER(12)     NOT NULL,
    CONSTRAINT chk_open_pos   CHECK (open_price  > 0),
    CONSTRAINT chk_close_pos  CHECK (close_price > 0),
    CONSTRAINT chk_vol_pos    CHECK (volume >= 0),
    CONSTRAINT chk_high_low   CHECK (high_price >= low_price),
    CONSTRAINT uq_comp_date   UNIQUE (company_name, trade_date)
);

-- ---------------------------------------------------------------------
-- 2. DATA INSERTION (25 records: 5 companies x 5 trading days)
-- ---------------------------------------------------------------------
-- AAPL
INSERT INTO stock_prices VALUES (1,  DATE '2013-02-08', 'AAPL', 67.71, 68.40, 66.89, 67.85, 15816800);
INSERT INTO stock_prices VALUES (2,  DATE '2013-02-11', 'AAPL', 68.07, 69.28, 67.60, 68.91, 12950200);
INSERT INTO stock_prices VALUES (3,  DATE '2013-02-12', 'AAPL', 68.50, 68.88, 67.20, 67.54, 14320100);
INSERT INTO stock_prices VALUES (4,  DATE '2013-02-13', 'AAPL', 67.60, 68.10, 66.95, 67.30, 11875400);
INSERT INTO stock_prices VALUES (5,  DATE '2013-02-14', 'AAPL', 67.10, 67.95, 66.40, 67.82, 13540000);
-- MSFT
INSERT INTO stock_prices VALUES (6,  DATE '2013-02-08', 'MSFT', 27.35, 27.50, 27.16, 27.43, 33318300);
INSERT INTO stock_prices VALUES (7,  DATE '2013-02-11', 'MSFT', 27.50, 27.80, 27.35, 27.70, 28100500);
INSERT INTO stock_prices VALUES (8,  DATE '2013-02-12', 'MSFT', 27.65, 27.72, 27.30, 27.38, 31220400);
INSERT INTO stock_prices VALUES (9,  DATE '2013-02-13', 'MSFT', 27.40, 27.58, 27.10, 27.52, 29875000);
INSERT INTO stock_prices VALUES (10, DATE '2013-02-14', 'MSFT', 27.45, 27.62, 27.18, 27.25, 30410200);
-- GOOGL
INSERT INTO stock_prices VALUES (11, DATE '2013-02-08', 'GOOGL', 39.00, 39.45, 38.70, 39.28, 21450300);
INSERT INTO stock_prices VALUES (12, DATE '2013-02-11', 'GOOGL', 39.35, 39.90, 39.20, 39.74, 19870500);
INSERT INTO stock_prices VALUES (13, DATE '2013-02-12', 'GOOGL', 39.80, 39.95, 39.10, 39.22, 23100800);
INSERT INTO stock_prices VALUES (14, DATE '2013-02-13', 'GOOGL', 39.20, 39.60, 38.85, 39.50, 20560400);
INSERT INTO stock_prices VALUES (15, DATE '2013-02-14', 'GOOGL', 39.55, 39.70, 38.90, 39.05, 22745600);
-- AMZN
INSERT INTO stock_prices VALUES (16, DATE '2013-02-08', 'AMZN', 261.00, 263.50, 258.90, 262.10, 3500200);
INSERT INTO stock_prices VALUES (17, DATE '2013-02-11', 'AMZN', 262.50, 265.40, 261.80, 264.90, 3120400);
INSERT INTO stock_prices VALUES (18, DATE '2013-02-12', 'AMZN', 264.70, 265.10, 260.20, 261.35, 4010800);
INSERT INTO stock_prices VALUES (19, DATE '2013-02-13', 'AMZN', 261.50, 263.00, 259.60, 262.45, 3345900);
INSERT INTO stock_prices VALUES (20, DATE '2013-02-14', 'AMZN', 262.60, 262.95, 258.40, 259.15, 3890100);
-- TSLA
INSERT INTO stock_prices VALUES (21, DATE '2013-02-08', 'TSLA', 34.20, 34.95, 33.80, 34.60, 6500400);
INSERT INTO stock_prices VALUES (22, DATE '2013-02-11', 'TSLA', 34.70, 35.40, 34.40, 35.15, 5980200);
INSERT INTO stock_prices VALUES (23, DATE '2013-02-12', 'TSLA', 35.10, 35.30, 33.90, 34.05, 7120900);
INSERT INTO stock_prices VALUES (24, DATE '2013-02-13', 'TSLA', 34.00, 34.50, 33.60, 34.25, 6240300);
INSERT INTO stock_prices VALUES (25, DATE '2013-02-14', 'TSLA', 34.30, 34.45, 33.20, 33.55, 6890700);

COMMIT;

-- ---------------------------------------------------------------------
-- 3. SQL QUERIES
-- ---------------------------------------------------------------------
SET LINESIZE 150
SET PAGESIZE 50

-- Q1. Daily stock records with open, close, high and low prices
SELECT trade_date, company_name, open_price, close_price, high_price, low_price
FROM   stock_prices
ORDER  BY company_name, trade_date;

-- Q2. Daily price change (close - open) for each stock
SELECT trade_date, company_name, open_price, close_price,
       ROUND(close_price - open_price, 2) AS daily_change
FROM   stock_prices
ORDER  BY company_name, trade_date;

-- Q3. Average closing price for each company
SELECT company_name, ROUND(AVG(close_price), 2) AS avg_close_price
FROM   stock_prices
GROUP  BY company_name
ORDER  BY avg_close_price DESC;

-- Q4. Five records with the highest trading volume
--     (FETCH FIRST works in Oracle 12c and above)
SELECT stock_id, trade_date, company_name, volume
FROM   stock_prices
ORDER  BY volume DESC
FETCH FIRST 5 ROWS ONLY;
-- For Oracle 11g use:
-- SELECT * FROM (SELECT stock_id, trade_date, company_name, volume
--                FROM stock_prices ORDER BY volume DESC)
-- WHERE ROWNUM <= 5;

-- Q5. Trading days when the closing price exceeded the opening price
SELECT trade_date, company_name, open_price, close_price
FROM   stock_prices
WHERE  close_price > open_price
ORDER  BY trade_date, company_name;
END;
/
