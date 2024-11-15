-- Create BookDetails Table
CREATE TABLE BookDetails (
    Book_No VARCHAR2(10) PRIMARY KEY,
    category VARCHAR2(20) CHECK (category IN ('Educational', 'Fiction', 'Autobiography', 'Novel')),
    book_name VARCHAR2(100),
    author VARCHAR2(100),
    issued_status CHAR(1) CHECK (issued_status IN ('y', 'n'))
);

-- Create StudentDetails Table
CREATE TABLE StudentDetails (
    std_id VARCHAR2(10) PRIMARY KEY,
    book_No VARCHAR2(10),
    std_name VARCHAR2(100),
    Dept VARCHAR2(50),
    Total_fine NUMBER(10, 2) DEFAULT 0,
    FOREIGN KEY (book_No) REFERENCES BookDetails(Book_No)
);

-- Create Book_issued Table
CREATE TABLE Book_issued (
    issueid NUMBER PRIMARY KEY,
    std_id VARCHAR2(10),
    Book_No VARCHAR2(10),
    issued_date DATE,
    return_date DATE,
    FOREIGN KEY (std_id) REFERENCES StudentDetails(std_id),
    FOREIGN KEY (Book_No) REFERENCES BookDetails(Book_No)
);

-- Insert data into BookDetails
INSERT INTO BookDetails (Book_No, category, book_name, author, issued_status)
VALUES ('B101', 'Educational', 'Introduction to PL/SQL', 'John Doe', 'n');
INSERT INTO BookDetails (Book_No, category, book_name, author, issued_status)
VALUES ('B102', 'Novel', 'The Great Adventure', 'Jane Smith', 'y');
INSERT INTO BookDetails (Book_No, category, book_name, author, issued_status)
VALUES ('B103', 'Fiction', 'The Lost World', 'Michael Johnson', 'n');
INSERT INTO BookDetails (Book_No, category, book_name, author, issued_status)
VALUES ('B104', 'Autobiography', 'My Life in Stories', 'Alice Williams', 'y');
INSERT INTO BookDetails (Book_No, category, book_name, author, issued_status)
VALUES ('B105', 'Educational', 'Advanced SQL Queries', 'Emily Davis', 'n');

-- Insert data into StudentDetails
INSERT INTO StudentDetails (std_id, book_No, std_name, Dept, Total_fine)
VALUES ('S001', 'B102', 'Alice Brown', 'Computer Science', 0);
INSERT INTO StudentDetails (std_id, book_No, std_name, Dept, Total_fine)
VALUES ('S002', 'B101', 'Bob Green', 'Electrical Engineering', 0);
INSERT INTO StudentDetails (std_id, book_No, std_name, Dept, Total_fine)
VALUES ('S003', 'B103', 'Charlie White', 'Mechanical Engineering', 0);
INSERT INTO StudentDetails (std_id, book_No, std_name, Dept, Total_fine)
VALUES ('S004', 'B104', 'David Black', 'Civil Engineering', 0);
INSERT INTO StudentDetails (std_id, book_No, std_name, Dept, Total_fine)
VALUES ('S005', 'B105', 'Eva Blue', 'Computer Science', 0);

-- Insert data into Book_issued
INSERT INTO Book_issued (issueid, std_id, Book_No, issued_date, return_date)
VALUES (1, 'S001', 'B102', TO_DATE('2024-11-01', 'YYYY-MM-DD'), NULL);
INSERT INTO Book_issued (issueid, std_id, Book_No, issued_date, return_date)
VALUES (2, 'S002', 'B101', TO_DATE('2024-11-05', 'YYYY-MM-DD'), NULL);
INSERT INTO Book_issued (issueid, std_id, Book_No, issued_date, return_date)
VALUES (3, 'S003', 'B103', TO_DATE('2024-11-10', 'YYYY-MM-DD'), NULL);
INSERT INTO Book_issued (issueid, std_id, Book_No, issued_date, return_date)
VALUES (4, 'S004', 'B104', TO_DATE('2024-10-25', 'YYYY-MM-DD'), NULL);
INSERT INTO Book_issued (issueid, std_id, Book_No, issued_date, return_date)
VALUES (5, 'S005', 'B105', TO_DATE('2024-11-07', 'YYYY-MM-DD'), NULL);

-- Create or replace return_book procedure
CREATE OR REPLACE PROCEDURE return_book(
  p_std_id IN StudentDetails.std_id%TYPE,
  p_book_no IN BookDetails.Book_No%TYPE
) IS
  v_return_date DATE;
  v_issued_date DATE;
  v_fine NUMBER(10,2) := 0;
  v_total_fine NUMBER(10,2);
  v_days_overdue NUMBER;
BEGIN
  -- Get issued date for the book
  SELECT bi.issued_date INTO v_issued_date
  FROM Book_issued bi
  JOIN BookDetails bd ON bi.Book_No = bd.Book_No
  WHERE bi.std_id = p_std_id
    AND bi.Book_No = p_book_no
    AND bi.return_date IS NULL;
  
  -- If the book was issued, calculate the fine if it's overdue
  IF v_issued_date IS NOT NULL THEN
    v_return_date := SYSDATE;
    v_days_overdue := v_return_date - v_issued_date;
    
    -- If the book is overdue for more than 15 days, calculate the fine
    IF v_days_overdue > 15 THEN
      -- Rs2 per day fine
      v_fine := v_days_overdue * 2;
    END IF;
  END IF;

  -- Step 3: Update the Book_issued table with the return date
  UPDATE Book_issued
  SET return_date = SYSDATE
  WHERE std_id = p_std_id
    AND Book_No = p_book_no
    AND return_date IS NULL;

  -- Step 4: Update StudentDetails with the fine
  SELECT Total_fine INTO v_total_fine
  FROM StudentDetails
  WHERE std_id = p_std_id;
  
  -- Add the calculated fine to the student's total fine
  v_total_fine := v_total_fine + v_fine;
  
  UPDATE StudentDetails
  SET Total_fine = v_total_fine
  WHERE std_id = p_std_id;

  -- Commit the changes to the database
  COMMIT;

  -- Output the result
  DBMS_OUTPUT.PUT_LINE('Book returned successfully.');
  IF v_fine > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Fine to pay: Rs ' || v_fine);
  ELSE
    DBMS_OUTPUT.PUT_LINE('No fine. Book returned on time.');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No such book issued to this student or book already returned.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END return_book;
/

-- Call the procedure to return a book and calculate fine (for example, S001 returning 'B102')
EXEC return_book('S001', 'B102');

-- Query to display the updated student details
SELECT std_id, std_name, Total_fine FROM StudentDetails;

-- Query to display the book issued details after return
SELECT * FROM Book_issued;
