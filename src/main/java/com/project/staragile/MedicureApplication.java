package com.project.staragile;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class MedicureApplication {

    public static void main(String[] args) {
        SpringApplication.run(MedicureApplication.class, args);
    }

    @Bean
    CommandLineRunner runner(MedicureRepository medicureRepository) {
        return args -> {
            // Preloading some doctors
            medicureRepository.save(new Doctor(1001L, "Dr. John Smith", "Cardiology", "9998887770"));
            medicureRepository.save(new Doctor(1002L, "Dr. Emily Rose", "Neurology", "9998887771"));
            medicureRepository.save(new Doctor(1003L, "Dr. Sam Wilson", "Orthopedics", "9998887772"));
        };
    }
}

