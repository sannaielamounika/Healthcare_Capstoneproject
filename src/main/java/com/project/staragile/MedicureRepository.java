package com.project.staragile;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface MedicureRepository extends JpaRepository<Doctor, Long> {
    Optional<Doctor> findByDoctorName(String doctorName);
}
