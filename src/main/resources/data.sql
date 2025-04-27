DROP TABLE IF EXISTS doctor;

CREATE TABLE doctor (
    doctor_reg_no BIGINT PRIMARY KEY,
    doctor_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    specialization VARCHAR(255)
);

-- You can also add some insert statements if needed
INSERT INTO doctor (doctor_reg_no, doctor_name, phone_number, specialization) 
VALUES (1, 'Dr. John Doe', '1234567890', 'Cardiology');

