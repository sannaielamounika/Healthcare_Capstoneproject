package com.project.staragile;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class MedicureController {

    @Autowired
    private MedicureService medicureService;

    @PostMapping("/registerDoctor")
    public Doctor registerDoctor(@RequestBody Doctor doctor) {
        return medicureService.registerDoctor(doctor);
    }

    @PutMapping("/updateDoctor/{doctorRegNo}")
    public Doctor updateDoctor(@PathVariable Long doctorRegNo, @RequestBody Doctor doctor) {
        return medicureService.updateDoctor(doctorRegNo, doctor);
    }

    @GetMapping("/searchDoctor/{doctorName}")
    public Doctor searchDoctor(@PathVariable String doctorName) {
        return medicureService.searchDoctor(doctorName);
    }

    @DeleteMapping("/deleteDoctor/{doctorRegNo}")
    public String deleteDoctor(@PathVariable Long doctorRegNo) {
        medicureService.deleteDoctor(doctorRegNo);
        return "Doctor deleted successfully.";
    }
}
