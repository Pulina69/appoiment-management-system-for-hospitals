package com.medical.servlet;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medical.model.User;
import com.medical.model.Appointment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/viewDoctorProfile")
public class ViewDoctorProfileServlet extends HttpServlet {
    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }
    private String getAppointmentsFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/appointments.json");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String doctorId = request.getParameter("id");
        ObjectMapper mapper = new ObjectMapper();
        File userFile = new File(getUsersFilePath());
        List<User> users = new ArrayList<>();
        if (userFile.exists()) {
            users = mapper.readValue(userFile, new TypeReference<List<User>>() {});
        }
        User doctor = users.stream().filter(u -> u.getId().equals(doctorId)).findFirst().orElse(null);
        request.setAttribute("doctor", doctor);
        // Load doctor's upcoming appointments
        File appFile = new File(getAppointmentsFilePath());
        List<Appointment> appointments = new ArrayList<>();
        if (appFile.exists()) {
            appointments = mapper.readValue(appFile, new TypeReference<List<Appointment>>() {});
        }
        List<Appointment> doctorAppointments = new ArrayList<>();
        for (Appointment a : appointments) {
            if (a.getDoctorId().equals(doctorId) && "SCHEDULED".equals(a.getStatus())) {
                doctorAppointments.add(a);
            }
        }
        request.setAttribute("appointments", doctorAppointments);
        request.getRequestDispatcher("viewDoctorProfile.jsp").forward(request, response);
    }
}
