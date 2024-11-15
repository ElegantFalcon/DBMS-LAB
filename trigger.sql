-- Create Passenger Table
CREATE TABLE Passenger (
    Passport_id INTEGER PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Age INTEGER NOT NULL,
    Sex CHAR(1),
    Address VARCHAR(50) NOT NULL
);

-- Insert Trigger
CREATE OR REPLACE TRIGGER after_insert_passenger
AFTER INSERT ON Passenger
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('1 Record is inserted');
END after_insert_passenger;
/

-- Delete Trigger
CREATE OR REPLACE TRIGGER after_delete_passenger
AFTER DELETE ON Passenger
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('1 Record is deleted');
END after_delete_passenger;
/

-- Update Trigger
CREATE OR REPLACE TRIGGER after_update_passenger
AFTER UPDATE ON Passenger
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('1 Record is updated');
END after_update_passenger;
/

-- Test Insertion
INSERT INTO Passenger (Passport_id, Name, Age, Sex, Address) 
VALUES (1, 'Alice', 30, 'F', '123 Main St');
-- Expected Output: "1 Record is inserted"

-- Test Update
UPDATE Passenger 
SET Age = 31 
WHERE Passport_id = 1;
-- Expected Output: "1 Record is updated"

-- Test Deletion
DELETE FROM Passenger 
WHERE Passport_id = 1;
-- Expected Output: "1 Record is deleted"
