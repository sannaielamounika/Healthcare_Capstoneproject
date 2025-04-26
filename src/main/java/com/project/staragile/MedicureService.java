package com.project.staragile;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class MedicureService {

    @Autowired
    private MedicureRepository medicureRepository;

    public Doctor registerDoctor(Doctor doctor) {
        return medicureRepository.save(doctor);
    }

    public Doctor updateDoctor(Long doctorRegNo, Doctor doctorDetails) {
        Doctor doctor = medicureRepository.findById(doctorRegNo)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));
        doctor.setDoctorName(doctorDetails.getDoctorName());
        doctor.setSpecialization(doctorDetails.getSpecialization());
        doctor.setPhoneNumber(doctorDetails.getPhoneNumber());
        return medicureRepository.save(doctor);
    }

    public Doctor searchDoctor(String doctorName) {
        return medicureRepository.findByDoctorName(doctorName)
                .orElseThrow(() -> new RuntimeException("Doctor not found"));
    }

    public void deleteDoctor(Long doctorRegNo) {
        medicureRepository.deleteById(doctorRegNo);
    }
}

