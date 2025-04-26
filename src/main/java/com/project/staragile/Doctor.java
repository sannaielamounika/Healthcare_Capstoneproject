package com.project.staragile;

import javax.persistence.Entity;
import javax.persistence.Id;

@Entity
public class Doctor {

    @Id
    private Long doctorRegNo;
    private String doctorName;
    private String specialization;
    private String phoneNumber;

    // 🛠 Default constructor (required for JPA)
    public Doctor() {
    }

    // 🛠 Parameterized constructor (required for your object creation)
    public Doctor(Long doctorRegNo, String doctorName, String specialization, String phoneNumber) {
        this.doctorRegNo = doctorRegNo;
        this.doctorName = doctorName;
        this.specialization = specialization;
        this.phoneNumber = phoneNumber;
    }

    // Getters and Setters
    public Long getDoctorRegNo() {
        return doctorRegNo;
    }

    public void setDoctorRegNo(Long doctorRegNo) {
        this.doctorRegNo = doctorRegNo;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
}

