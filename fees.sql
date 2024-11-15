CREATE TABLE Student (
    regno VARCHAR2(10) PRIMARY KEY,
    name VARCHAR2(50) NOT NULL,
    class VARCHAR2(10) NOT NULL,
    fee NUMBER(10, 2) NOT NULL
);

CREATE TABLE S5_CSE(
  regno VARCHAR(10) PRIMARY KEY,
  Sub1 Number(3) CHECK (Sub1 BETWEEN 0 and 150),
  Sub2 Number(3) CHECK (Sub2 BETWEEN 0 and 150),
  Sub3 Number(3) CHECK (Sub3 BETWEEN 0 and 150),
  Sub4 Number(3) CHECK (Sub4 BETWEEN 0 and 150),
  Sub5 Number(3) CHECK (Sub5 BETWEEN 0 and 150),
  Sub6 Number(3) CHECK (Sub6 BETWEEN 0 and 150),
  Sub7 Number(3) CHECK (Sub7 BETWEEN 0 and 150),
  Sub8 Number(3) CHECK (Sub8 BETWEEN 0 and 150),
  totalmarks Number(4),
  FOREIGN KEY (regno) references Student(regno)
);

INSERT INTO Student (regno, name, class, fee) VALUES ('S101', 'Alice', 'CSE', 10000);
INSERT INTO Student (regno, name, class, fee) VALUES ('S102', 'Bob', 'CSE', 20000);
INSERT INTO Student (regno, name, class, fee) VALUES ('S103', 'Charlie', 'CSE', 30000);
INSERT INTO Student (regno, name, class, fee) VALUES ('S104', 'David', 'CSE', 40000);
INSERT INTO Student (regno, name, class, fee) VALUES ('S105', 'Eve', 'CSE', 50000);
INSERT INTO Student (regno, name, class, fee) VALUES ('S106', 'Frank', 'CSE', 60000);

INSERT INTO S5_CSE (regno, Sub1, Sub2, Sub3, Sub4, Sub5, Sub6, Sub7, Sub8) VALUES ('S101', 130, 145, 140, 135, 120, 125, 140, 130);
INSERT INTO S5_CSE (regno, Sub1, Sub2, Sub3, Sub4, Sub5, Sub6, Sub7, Sub8) VALUES ('S102', 150, 145, 135, 140, 130, 125, 135, 140);
INSERT INTO S5_CSE (regno, Sub1, Sub2, Sub3, Sub4, Sub5, Sub6, Sub7, Sub8) VALUES ('S103', 140, 130, 120, 125, 135, 140, 145, 150);
INSERT INTO S5_CSE (regno, Sub1, Sub2, Sub3, Sub4, Sub5, Sub6, Sub7, Sub8) VALUES ('S104', 145, 140, 150, 135, 130, 120, 125, 140);
INSERT INTO S5_CSE (regno, Sub1, Sub2, Sub3, Sub4, Sub5, Sub6, Sub7, Sub8) VALUES ('S105', 120, 125, 135, 140, 150, 145, 140, 130);
INSERT INTO S5_CSE (regno, Sub1, Sub2, Sub3, Sub4, Sub5, Sub6, Sub7, Sub8) VALUES ('S106', 130, 135, 120, 125, 140, 145, 130, 135);

DECLARE
  CURSOR top_student IS 
    SELECT s.regno,s.fee
    FROM Student s 
    JOIN  S5_CSE sc  on s.regno=sc.regno
    WHERE sc.totalmarks>1000 
    ORDER BY sc.totalmarks desc
    FETCH FIRST 5 ROWS ONLY;
  v_total_marks NUMBER;
  
BEGIN
  FOR student IN (SELECT regno,Sub1,Sub2,Sub3,Sub4,Sub5,Sub6,Sub7,Sub8 FROM S5_CSE) LOOP
    v_total_marks := student.Sub1+student.Sub2+student.Sub3+student.Sub4+student.Sub5+student.Sub6+student.Sub7+student.Sub8;
    
    update S5_CSE
    SET totalmarks = v_total_marks
    where regno = student.regno;
  END LOOP;
  
  FOR student IN top_student LOOP
   update Student
   SET fee = fee*0.9
   WHERE regno = student.regno;
   
   DBMS_OUTPUT.PUT_LINE('Reg No : ' || student.regno || ' - NEW FEE : ' || student.fee);
  END LOOP;
  
  
    FOR student IN (SELECT regno, totalmarks FROM S5_CSE) LOOP
        DBMS_OUTPUT.PUT_LINE('Regno: ' || student.regno || ' - Total Marks: ' || student.totalmarks);
    END LOOP;
    
    COMMIT;
    END;
    /
  
  