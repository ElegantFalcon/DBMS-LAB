-- Creating the Item table
CREATE TABLE Item (
    itemid INT PRIMARY KEY,
    itname VARCHAR2(100),
    unitprice DECIMAL(10, 2)
);

-- Creating the Stock table
CREATE TABLE Stock (
    st_no INT PRIMARY KEY,
    itemid INT,
    no_of_pieces INT,
    FOREIGN KEY (itemid) REFERENCES Item(itemid)
);

-- Creating the Transaction table
CREATE TABLE Transaction (
    tr_id INT PRIMARY KEY,
    type VARCHAR2(10), -- 'Purchase' or 'Sales'
    tr_date DATE,
    itemid INT,
    no_of_pieces INT,
    FOREIGN KEY (itemid) REFERENCES Item(itemid)
);

-- Inserting data into the Item table
INSERT INTO Item (itemid, itname, unitprice) VALUES (1, 'Laptop', 50000.00);
INSERT INTO Item (itemid, itname, unitprice) VALUES (2, 'Mobile', 20000.00);
INSERT INTO Item (itemid, itname, unitprice) VALUES (3, 'Tablet', 15000.00);

-- Inserting data into the Stock table
INSERT INTO Stock (st_no, itemid, no_of_pieces) VALUES (1, 1, 50);
INSERT INTO Stock (st_no, itemid, no_of_pieces) VALUES (2, 2, 100);
INSERT INTO Stock (st_no, itemid, no_of_pieces) VALUES (3, 3, 200);

-- Inserting data into the Transaction table
INSERT INTO Transaction (tr_id, type, tr_date, itemid, no_of_pieces) VALUES (1, 'Sales', TO_DATE('2023-02-15', 'YYYY-MM-DD'), 1, 10);
INSERT INTO Transaction (tr_id, type, tr_date, itemid, no_of_pieces) VALUES (2, 'Sales', TO_DATE('2023-02-15', 'YYYY-MM-DD'), 2, 15);
INSERT INTO Transaction (tr_id, type, tr_date, itemid, no_of_pieces) VALUES (3, 'Purchase', TO_DATE('2023-02-10', 'YYYY-MM-DD'), 1, 20);
INSERT INTO Transaction (tr_id, type, tr_date, itemid, no_of_pieces) VALUES (4, 'Sales', TO_DATE('2023-02-16', 'YYYY-MM-DD'), 3, 30);

CREATE OR REPLACE PROCEDURE Handle_Transaction AS
    v_current_stock INT;
BEGIN
    -- Loop through each transaction
    FOR txn IN (SELECT tr_id, type, tr_date, itemid, no_of_pieces FROM Transaction) LOOP

        -- Check current stock for the item
        SELECT no_of_pieces INTO v_current_stock FROM Stock WHERE itemid = txn.itemid;

        -- Handle Purchase transaction: Increase stock
        IF txn.type = 'Purchase' THEN
            UPDATE Stock
            SET no_of_pieces = v_current_stock + txn.no_of_pieces
            WHERE itemid = txn.itemid;
        
        -- Handle Sales transaction: Decrease stock (only if stock is sufficient)
        ELSIF txn.type = 'Sales' THEN
            IF v_current_stock >= txn.no_of_pieces THEN
                UPDATE Stock
                SET no_of_pieces = v_current_stock - txn.no_of_pieces
                WHERE itemid = txn.itemid;
            ELSE
                DBMS_OUTPUT.PUT_LINE('Not enough stock for item ID: ' || txn.itemid);
            END IF;
        END IF;
    END LOOP;
    
    COMMIT;
END Handle_Transaction;
/
EXEC Handle_Transaction;
SELECT t.tr_id, i.itname, t.no_of_pieces, t.tr_date
FROM Transaction t
JOIN Item i ON t.itemid = i.itemid
WHERE t.type = 'Sales' 
  AND t.tr_date = TO_DATE('2023-02-15', 'YYYY-MM-DD');
