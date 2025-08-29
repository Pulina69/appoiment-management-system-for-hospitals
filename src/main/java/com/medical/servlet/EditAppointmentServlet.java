package com.medical.servlet;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medical.model.User;
import com.medical.model.Appointment;
import com.medical.dsa.Search;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/editAppointment")
public class EditAppointmentServlet extends HttpServlet {
    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }
    private String getAppointmentsFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/appointments.json");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        ObjectMapper mapper = new ObjectMapper();
        File appFile = new File(getAppointmentsFilePath());
        List<Appointment> appointments = new ArrayList<>();
        if (appFile.exists()) {
            appointments = mapper.readValue(appFile, new TypeReference<List<Appointment>>() {});
        }
        Appointment appointment = appointments.stream().filter(a -> a.getId().equals(id)).findFirst().orElse(null);        if (appointment == null) {
            request.setAttribute("error", "Appointment not found.");
            response.sendRedirect("appointments.jsp");
            return;
        }
        // Load doctors for dropdown
        File userFile = new File(getUsersFilePath());
        List<User> users = new ArrayList<>();
        if (userFile.exists()) {
            users = mapper.readValue(userFile, new TypeReference<List<User>>() {});
        }
        List<User> doctors = users.stream().filter(u -> "DOCTOR".equalsIgnoreCase(u.getRole())).collect(Collectors.toList());
        request.setAttribute("doctors", doctors);
        // Set available times (example)
        List<String> availableTimes = List.of("09:00", "10:00", "11:00", "14:00", "15:00", "16:00");
        request.setAttribute("availableTimes", availableTimes);
        java.time.LocalDate today = java.time.LocalDate.now();
        request.setAttribute("minDate", today.toString());
        request.setAttribute("maxDate", today.plusDays(30).toString());
        request.setAttribute("appointment", appointment);
        request.getRequestDispatcher("editAppointment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        String doctorId = request.getParameter("doctorId");
        String date = request.getParameter("date");
        String time = request.getParameter("time");
        String reason = request.getParameter("reason");
        ObjectMapper mapper = new ObjectMapper();
        File appFile = new File(getAppointmentsFilePath());
        List<Appointment> appointments = new ArrayList<>();
        if (appFile.exists()) {
            appointments = mapper.readValue(appFile, new TypeReference<List<Appointment>>() {});
        }
        Appointment appointment = appointments.stream().filter(a -> a.getId().equals(id)).findFirst().orElse(null);
        if (appointment == null) {
            request.setAttribute("error", "Appointment not found.");
            doGet(request, response);
            return;
        }
        // Check for time conflict
        boolean conflict = appointments.stream().anyMatch(a -> !a.getId().equals(id) && a.getDoctorId().equals(doctorId) && a.getDate().toString().equals(date) && a.getTime().toString().equals(time) && "SCHEDULED".equals(a.getStatus()));
        if (conflict) {
            request.setAttribute("error", "Selected time is not available for this doctor.");
            doGet(request, response);
            return;
        }
        appointment.setDoctorId(doctorId);
        appointment.setDate(date); // Use the string value directly        appointment.setTime(time); // Use the string value directly
        appointment.setReason(reason);
        mapper.writerWithDefaultPrettyPrinter().writeValue(appFile, appointments);
        response.sendRedirect("appointments.jsp");
    }
}
