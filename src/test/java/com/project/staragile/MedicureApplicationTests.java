package com.project.staragile;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
class MedicureApplicationTests {

    @Autowired
    private DataSource dataSource;

    @Test
    void contextLoads() {
        // This test will pass if the application context loads successfully
    }

    @Test
    void testDoctorTableExists() throws SQLException, InterruptedException {
        Thread.sleep(1000); // Wait for Hibernate to create tables

        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData metaData = connection.getMetaData();
            ResultSet resultSet = metaData.getTables(null, null, "DOCTOR", null); // Uppercase table name
            assertTrue(resultSet.next(), "Table 'doctor' should exist in the database");
        }
    }
}

