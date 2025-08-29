package com.medical.servlet;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medical.model.User;
import com.medical.model.Appointment;
import com.medical.model.Payment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }
    private String getAppointmentsFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/appointments.json");
    }
    private String getPaymentsFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/payment.json");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ObjectMapper mapper = new ObjectMapper();
        // Users
        File userFile = new File(getUsersFilePath());
        List<User> users = new ArrayList<>();
        if (userFile.exists()) {
            users = mapper.readValue(userFile, new TypeReference<List<User>>() {});
        }
        // Doctors
        List<User> doctors = new ArrayList<>();
        for (User u : users) {
            if ("DOCTOR".equalsIgnoreCase(u.getRole())) {
                doctors.add(u);
            }
        }
        // Appointments
        File appFile = new File(getAppointmentsFilePath());
        List<Appointment> appointments = new ArrayList<>();
        if (appFile.exists()) {
            appointments = mapper.readValue(appFile, new TypeReference<List<Appointment>>() {});
        }
        // Payments
        File payFile = new File(getPaymentsFilePath());
        List<Payment> payments = new ArrayList<>();
        if (payFile.exists()) {
            payments = mapper.readValue(payFile, new TypeReference<List<Payment>>() {});
        }
        // Set stats
        request.setAttribute("userCount", users.size());
        request.setAttribute("doctorCount", doctors.size());
        request.setAttribute("appointmentCount", appointments.size());
        request.setAttribute("totalPayments", payments.size());
        // Recent lists (sorted by joinDate/date descending)
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        List<User> recentUsers = users.stream()
            .sorted(Comparator.comparing((User u) -> {
                try {
                    return LocalDate.parse(u.getJoinDate(), dateFormatter);
                } catch (Exception e) {
                    return LocalDate.MIN;
                }
            }).reversed())
            .limit(5)
            .collect(Collectors.toList());
        List<Appointment> recentAppointments = appointments.stream()
            .sorted(Comparator.comparing((Appointment a) -> {
                try {
                    return LocalDate.parse(a.getDate(), dateFormatter);
                } catch (Exception e) {
                    return LocalDate.MIN;
                }
            }).reversed())
            .limit(5)
            .collect(Collectors.toList());
        request.setAttribute("recentUsers", recentUsers);
        request.setAttribute("recentAppointments", recentAppointments);
        // Add full lists for dashboard tables
        request.setAttribute("users", users);
        request.setAttribute("appointments", appointments);
        request.setAttribute("payments", payments);
        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}
