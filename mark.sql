CREATE TABLE Stud_session (
    regno INT PRIMARY KEY,
    s_name VARCHAR2(100),
    subjectname VARCHAR2(50),
    ass1 DECIMAL(5, 2),
    ass2 DECIMAL(5, 2),
    mark1 DECIMAL(5, 2),
    mark2 DECIMAL(5, 2),
    atten_percentage DECIMAL(5, 2),
    sessional DECIMAL(5, 2) DEFAULT 0,
    univ_marks DECIMAL(5, 2),
    total_marks DECIMAL(5, 2) DEFAULT 0,
    status VARCHAR2(10) DEFAULT 'Fail'
);


-- Inserting dummy values into the Stud_session table
INSERT INTO Stud_session (regno, s_name, subjectname, ass1, ass2, mark1, mark2, atten_percentage, univ_marks)
VALUES (101, 'Alice', 'DBMS', 12, 13, 10, 11, 85, 20);

INSERT INTO Stud_session (regno, s_name, subjectname, ass1, ass2, mark1, mark2, atten_percentage, univ_marks)
VALUES (102, 'Bob', 'DBMS', 14, 12, 9, 10, 72, 20);

INSERT INTO Stud_session (regno, s_name, subjectname, ass1, ass2, mark1, mark2, atten_percentage, univ_marks)
VALUES (103, 'Charlie', 'DBMS', 10, 9, 8, 7, 68, 18);

CREATE OR REPLACE PROCEDURE Calculate_Sessional_Marks AS
    v_attendance_marks DECIMAL(5, 2);
    v_assignment_avg DECIMAL(5, 2);
    v_total_marks DECIMAL(5, 2);
    v_status VARCHAR2(10);
BEGIN
    -- Loop through all students enrolled in the DBMS subject
    FOR student IN (SELECT regno, ass1, ass2, mark1, mark2, atten_percentage, univ_marks FROM Stud_session WHERE subjectname = 'DBMS') LOOP
        
        -- Calculate Attendance marks
        IF student.atten_percentage >= 80 THEN
            v_attendance_marks := 10;
        ELSIF student.atten_percentage >= 70 THEN
            v_attendance_marks := 8;
        ELSE
            v_attendance_marks := 7;
        END IF;

        -- Ensure attendance percentage is not below 65
        IF student.atten_percentage < 65 THEN
            student.atten_percentage := 65;
        END IF;

        -- Calculate Assignment Average (out of 15)
        v_assignment_avg := (student.ass1 + student.ass2) / 2;

        -- Calculate Total Marks (out of 150)
        v_total_marks := v_assignment_avg + student.mark1 + student.mark2 + v_attendance_marks + student.univ_marks;
        
        -- Calculate Session Marks (out of 25)
        -- Total marks from assignments, mark1, mark2, and attendance will be used for sessional mark calculation
        UPDATE Stud_session
        SET sessional = v_assignment_avg + student.mark1 + student.mark2 + v_attendance_marks
        WHERE regno = student.regno;

        -- Update Total Marks (out of 150)
        UPDATE Stud_session
        SET total_marks = v_total_marks
        WHERE regno = student.regno;

        -- Update the status based on total marks (passing marks = 75)
        IF v_total_marks >= 75 THEN
            v_status := 'Pass';
        ELSE
            v_status := 'Fail';
        END IF;

        UPDATE Stud_session
        SET status = v_status
        WHERE regno = student.regno;
    END LOOP;

    COMMIT;
END Calculate_Sessional_Marks;
/

EXEC Calculate_Sessional_Marks;
SELECT regno, s_name, ass1, ass2, mark1, mark2, atten_percentage, sessional, univ_marks, total_marks, status
FROM Stud_session
WHERE subjectname = 'DBMS';

