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

@WebServlet("/bookAppointment")
public class BookAppointmentServlet extends HttpServlet {

    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }

    private String getAppointmentsFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/appointments.json");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ObjectMapper mapper = new ObjectMapper();
        File userFile = new File(getUsersFilePath());
        List<User> users = new ArrayList<>();
        if (userFile.exists()) {
            users = mapper.readValue(userFile, new TypeReference<List<User>>() {});
        }
        List<User> doctors = users.stream().filter(u -> "DOCTOR".equalsIgnoreCase(u.getRole())).collect(Collectors.toList());
        request.setAttribute("doctors", doctors);
        List<String> availableTimes = List.of("09:00", "10:00", "11:00", "14:00", "15:00", "16:00");
        request.setAttribute("availableTimes", availableTimes);
        java.time.LocalDate today = java.time.LocalDate.now();
        request.setAttribute("minDate", today.toString());
        request.setAttribute("maxDate", today.plusDays(30).toString());
        request.getRequestDispatcher("bookAppointment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || (session.getAttribute("user") == null && session.getAttribute("tempUser") == null)) {
            response.sendRedirect("login.jsp");
            return;
        }
        User user = (User) (session.getAttribute("tempUser") != null ? session.getAttribute("tempUser") : session.getAttribute("user"));
        String doctorId = request.getParameter("doctorId");
        String date = request.getParameter("date");
        String time = request.getParameter("time");
        String reason = request.getParameter("reason");
        ObjectMapper mapper = new ObjectMapper();
        File userFile = new File(getUsersFilePath());
        List<User> users = new ArrayList<>();
        if (userFile.exists()) {
            users = mapper.readValue(userFile, new TypeReference<List<User>>() {});
        }
        User doctor = users.stream().filter(u -> doctorId.equals(u.getId())).findFirst().orElse(null);
        if (doctor == null) {
            request.setAttribute("error", "Selected doctor not found.");
            doGet(request, response);
            return;
        }
        File appFile = new File(getAppointmentsFilePath());
        List<Appointment> appointments = new ArrayList<>();
        if (appFile.exists()) {
            appointments = mapper.readValue(appFile, new TypeReference<List<Appointment>>() {});
        }
        boolean conflict = appointments.stream().anyMatch(a -> a.getDoctorId().equals(doctorId) && a.getDate().equals(date) && a.getTime().equals(time) && "SCHEDULED".equals(a.getStatus()));
        if (conflict) {
            request.setAttribute("error", "Selected time is not available for this doctor.");
            doGet(request, response);
            return;
        }
        Appointment appointment = new Appointment();
        appointment.setId(String.valueOf(System.currentTimeMillis()));
        appointment.setPatientId(user.getId());
        appointment.setPatientUsername(user.getUsername());
        appointment.setPatientName(user.getFullName());
        appointment.setDoctorId(doctor.getId());
        appointment.setDoctorUsername(doctor.getUsername());
        appointment.setDoctorName(doctor.getFullName());
        appointment.setDate(date);
        appointment.setTime(time);
        appointment.setReason(reason);
        appointment.setStatus("SCHEDULED");
        appointments.add(appointment);
        mapper.writerWithDefaultPrettyPrinter().writeValue(appFile, appointments);
        response.sendRedirect("payNow.jsp?appointmentId=" + appointment.getId());
    }
}
