


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

INSERT INTO stock_prices VALUES (1, DATE '2010-01-04', 'AAPL', 213.43, 214.50, 212.38, 214.01, 123432400);
INSERT INTO stock_prices VALUES (2, DATE '2010-01-05', 'AAPL', 214.60, 215.59, 213.25, 214.38, 150476200);
INSERT INTO stock_prices VALUES (3, DATE '2010-01-06', 'AAPL', 214.38, 215.23, 210.75, 210.97, 138040000);
INSERT INTO stock_prices VALUES (4, DATE '2010-01-07', 'AAPL', 211.75, 212.00, 209.05, 210.58, 119282800);
INSERT INTO stock_prices VALUES (5, DATE '2010-01-08', 'AAPL', 210.30, 212.00, 209.06, 211.98, 111902700);
INSERT INTO stock_prices VALUES (6, DATE '2010-11-11', 'MSFT', 26.68, 26.72, 26.28, 26.68, 62073100);
INSERT INTO stock_prices VALUES (7, DATE '2010-11-12', 'MSFT', 26.47, 26.52, 26.10, 26.27, 64962200);
INSERT INTO stock_prices VALUES (8, DATE '2010-11-15', 'MSFT', 26.33, 26.50, 26.17, 26.20, 51794600);
INSERT INTO stock_prices VALUES (9, DATE '2010-11-16', 'MSFT', 26.04, 26.04, 25.65, 25.81, 65339200);
INSERT INTO stock_prices VALUES (10, DATE '2010-11-17', 'MSFT', 25.90, 25.91, 25.55, 25.57, 58299700);
INSERT INTO stock_prices VALUES (11, DATE '2012-11-12', 'GOOGL', 663.75, 669.80, 660.87, 665.90, 2808900);
INSERT INTO stock_prices VALUES (12, DATE '2012-11-13', 'GOOGL', 663.00, 667.60, 658.23, 659.05, 3185200);
INSERT INTO stock_prices VALUES (13, DATE '2012-11-14', 'GOOGL', 660.66, 662.18, 650.50, 652.55, 3333400);
INSERT INTO stock_prices VALUES (14, DATE '2012-11-15', 'GOOGL', 650.00, 660.00, 643.90, 647.26, 3694100);
INSERT INTO stock_prices VALUES (15, DATE '2012-11-16', 'GOOGL', 645.99, 653.02, 636.00, 647.18, 6869500);
INSERT INTO stock_prices VALUES (16, DATE '2014-04-16', 'AMZN', 321.17, 324.00, 314.71, 323.68, 4284900);
INSERT INTO stock_prices VALUES (17, DATE '2014-04-17', 'AMZN', 319.76, 328.66, 319.76, 324.91, 4299200);
INSERT INTO stock_prices VALUES (18, DATE '2014-04-21', 'AMZN', 323.97, 331.15, 322.31, 330.87, 2999400);
INSERT INTO stock_prices VALUES (19, DATE '2014-04-22', 'AMZN', 332.00, 337.50, 328.94, 329.32, 3711600);
INSERT INTO stock_prices VALUES (20, DATE '2014-04-23', 'AMZN', 333.06, 333.13, 323.39, 324.58, 3604600);
INSERT INTO stock_prices VALUES (21, DATE '2016-12-19', 'BCR', 220.45, 222.17, 219.55, 220.33, 414300);
INSERT INTO stock_prices VALUES (22, DATE '2016-12-20', 'BCR', 219.45, 220.81, 219.18, 220.47, 376900);
INSERT INTO stock_prices VALUES (23, DATE '2016-12-21', 'BCR', 221.01, 221.59, 219.51, 219.66, 483300);
INSERT INTO stock_prices VALUES (24, DATE '2016-12-22', 'BCR', 218.77, 221.67, 218.72, 220.68, 431200);
INSERT INTO stock_prices VALUES (25, DATE '2016-12-23', 'BCR', 220.84, 224.06, 220.84, 223.10, 318800);

COMMIT;

SET LINESIZE 150
SET PAGESIZE 50

-- Q1
SELECT trade_date, company_name, open_price, close_price, high_price, low_price
FROM   stock_prices
ORDER  BY company_name, trade_date;

-- Q2
SELECT trade_date, company_name, open_price, close_price,
       ROUND(close_price - open_price, 2) AS daily_change
FROM   stock_prices
ORDER  BY company_name, trade_date;

-- Q3
SELECT company_name, ROUND(AVG(close_price), 2) AS avg_close_price
FROM   stock_prices
GROUP  BY company_name
ORDER  BY avg_close_price DESC;

-- Q4
SELECT stock_id, trade_date, company_name, volume
FROM   stock_prices
ORDER  BY volume DESC
FETCH FIRST 5 ROWS ONLY;

-- Q5
SELECT trade_date, company_name, open_price, close_price
FROM   stock_prices
WHERE  close_price > open_price
ORDER  BY trade_date, company_name;

-- PL/SQL 1: FUNCTION
CREATE OR REPLACE FUNCTION fn_price_change_pct (p_stock_id IN NUMBER)
RETURN NUMBER
IS
    v_open   stock_prices.open_price%TYPE;
    v_close  stock_prices.close_price%TYPE;
BEGIN
    IF p_stock_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Stock ID cannot be NULL.');
    END IF;

    SELECT open_price, close_price
    INTO   v_open, v_close
    FROM   stock_prices
    WHERE  stock_id = p_stock_id;

    RETURN ROUND(((v_close - v_open) / v_open) * 100, 2);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No record found for stock ID ' || p_stock_id);
END fn_price_change_pct;
/

-- PL/SQL 2: PROCEDURE
CREATE OR REPLACE PROCEDURE sp_get_history (p_company IN VARCHAR2)
IS
    v_count NUMBER := 0;
BEGIN
    IF p_company IS NULL OR TRIM(p_company) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, 'Company name cannot be empty.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Price history for: ' || UPPER(p_company));
    DBMS_OUTPUT.PUT_LINE(RPAD('DATE', 14) || RPAD('OPEN', 10) || RPAD('HIGH', 10) ||
                         RPAD('LOW', 10) || RPAD('CLOSE', 10) || 'VOLUME');

    FOR r IN (SELECT trade_date, open_price, high_price, low_price, close_price, volume
              FROM   stock_prices
              WHERE  UPPER(company_name) = UPPER(TRIM(p_company))
              ORDER  BY trade_date)
    LOOP
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE(RPAD(TO_CHAR(r.trade_date, 'DD-MON-YYYY'), 14) ||
                             RPAD(r.open_price, 10) || RPAD(r.high_price, 10) ||
                             RPAD(r.low_price, 10)  || RPAD(r.close_price, 10) ||
                             r.volume);
    END LOOP;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'No records found for company: ' || p_company);
    END IF;
END sp_get_history;
/

-- PL/SQL 3: PROCEDURE
CREATE OR REPLACE PROCEDURE sp_company_report
IS
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('COMPANY-WISE PRICE AND VOLUME REPORT');
    DBMS_OUTPUT.PUT_LINE(RPAD('COMPANY', 10) || RPAD('DAYS', 6) || RPAD('AVG CLOSE', 12) ||
                         RPAD('MAX HIGH', 12) || RPAD('MIN LOW', 12) || 'TOTAL VOLUME');

    FOR r IN (SELECT company_name,
                     COUNT(*)                   AS days,
                     ROUND(AVG(close_price), 2) AS avg_close,
                     MAX(high_price)            AS max_high,
                     MIN(low_price)             AS min_low,
                     SUM(volume)                AS total_vol
              FROM   stock_prices
              GROUP  BY company_name
              ORDER  BY company_name)
    LOOP
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE(RPAD(r.company_name, 10) || RPAD(r.days, 6) ||
                             RPAD(r.avg_close, 12) || RPAD(r.max_high, 12) ||
                             RPAD(r.min_low, 12) || r.total_vol);
    END LOOP;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'No data available to generate report.');
    END IF;
END sp_company_report;
/

-- TEST CASES
SELECT stock_id, company_name, fn_price_change_pct(stock_id) AS change_pct
FROM   stock_prices
WHERE  stock_id IN (1, 6, 11, 16, 21);

BEGIN
    DBMS_OUTPUT.PUT_LINE('Result: ' || fn_price_change_pct(999));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test 2 Error caught: ' || SQLERRM);
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Result: ' || fn_price_change_pct(NULL));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test 3 Error caught: ' || SQLERRM);
END;
/

BEGIN
    sp_get_history('AAPL');
END;
/

BEGIN
    sp_get_history('XYZ');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test 5 Error caught: ' || SQLERRM);
END;
/

BEGIN
    sp_get_history('');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test 6 Error caught: ' || SQLERRM);
END;
/

BEGIN
    sp_company_report;
END;
/

BEGIN
    INSERT INTO stock_prices VALUES (1, DATE '2013-03-01', 'AAPL', 60, 61, 59, 60.5, 1000);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Test 8 Error caught: Duplicate stock_id not allowed.');
END;
/
