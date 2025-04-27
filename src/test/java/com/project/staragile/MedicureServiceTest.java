package com.project.staragile;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class MedicureServiceTest {

    @Autowired
    private MedicureService medicureService;

    @Test
    public void testRegisterDoctor() {
        Doctor doctor = new Doctor();
        doctor.setDoctorRegNo(1L);
        doctor.setDoctorName("Dr. John");
        doctor.setSpecialization("Cardiologist");
        doctor.setPhoneNumber("9876543210");

        Doctor savedDoctor = medicureService.registerDoctor(doctor);

        assertThat(savedDoctor).isNotNull();
        assertThat(savedDoctor.getDoctorName()).isEqualTo("Dr. John");
    }
}

