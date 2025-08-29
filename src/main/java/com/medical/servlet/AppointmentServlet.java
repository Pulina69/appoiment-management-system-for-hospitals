package com.medical.servlet;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medical.dsa.Search;
import com.medical.model.Appointment;
import com.medical.model.User;
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

@WebServlet("/appointments")
public class AppointmentServlet extends HttpServlet {
    private String getAppointmentsFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/appointments.json");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");
        String role = user.getRole();
        ObjectMapper mapper = new ObjectMapper();
        File file = new File(getAppointmentsFilePath());
        List<Appointment> allAppointments = new ArrayList<>();
        if (file.exists()) {
            allAppointments = mapper.readValue(file, new TypeReference<List<Appointment>>() {});
        }
        List<Appointment> appointments;
        Object tempUserObj = session.getAttribute("tempUser");
        if ("DOCTOR".equalsIgnoreCase(role)) {
            String doctorUsername = (tempUserObj != null)
                ? ((com.medical.model.TempUser) tempUserObj).getUsername()
                : user.getUsername();
            appointments = allAppointments.stream()
                .filter(a -> a.getDoctorUsername().equalsIgnoreCase(doctorUsername))
                .collect(Collectors.toList());
        } else if ("PATIENT".equalsIgnoreCase(role)) {
            appointments = allAppointments.stream()
                .filter(a -> a.getPatientUsername().equalsIgnoreCase(user.getUsername()))
                .collect(Collectors.toList());
            request.setAttribute("patientAppointments", appointments); // for appointments.jsp
        } else {
            appointments = allAppointments;
        }
        request.setAttribute("appointments", appointments);
        if ("DOCTOR".equalsIgnoreCase(role)) {
            request.getRequestDispatcher("doctorAppointment.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("appointments.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Handle cancel action
        String action = request.getParameter("action");
        if ("cancel".equals(action)) {
            String appointmentId = request.getParameter("appointmentId");
            ObjectMapper mapper = new ObjectMapper();
            File file = new File(getAppointmentsFilePath());
            List<Appointment> appointments = new ArrayList<>();
            if (file.exists()) {
                appointments = mapper.readValue(file, new TypeReference<List<Appointment>>() {});
            }
            for (Appointment a : appointments) {
                if (a.getId().equals(appointmentId)) {
                    a.setStatus("CANCELLED");
                    a.setNotes("Cancelled by user");
                }
            }
            mapper.writerWithDefaultPrettyPrinter().writeValue(file, appointments);
            request.setAttribute("success", "Appointment cancelled successfully.");
        }
        doGet(request, response);
    }
}