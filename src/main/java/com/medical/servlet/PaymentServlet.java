package com.medical.servlet;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medical.model.Payment;
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

@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {
    private String getPaymentsFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/payment.json");
    }

    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }

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
        ObjectMapper mapper = new ObjectMapper();
        List<Payment> payments = new ArrayList<>();
        List<com.medical.model.User> users = new ArrayList<>();
        List<com.medical.model.Appointment> appointments = new ArrayList<>();
        File paymentFile = new File(getPaymentsFilePath());
        File userFile = new File(getUsersFilePath());
        File appointmentFile = new File(getAppointmentsFilePath());
        if (paymentFile.exists()) {
            payments = mapper.readValue(paymentFile, new TypeReference<List<Payment>>() {});
        }
        if (userFile.exists()) {
            users = mapper.readValue(userFile, new TypeReference<List<com.medical.model.User>>() {});
        }
        if (appointmentFile.exists()) {
            appointments = mapper.readValue(appointmentFile, new TypeReference<List<com.medical.model.Appointment>>() {});
        }
        // Enrich payment data
        for (Payment payment : payments) {
            com.medical.model.User patient = users.stream().filter(u -> u.getId().equals(payment.getPatientId())).findFirst().orElse(null);
            com.medical.model.User doctor = users.stream().filter(u -> u.getId().equals(payment.getDoctorId())).findFirst().orElse(null);
            com.medical.model.Appointment appt = appointments.stream().filter(a -> a.getId().equals(payment.getAppointmentId())).findFirst().orElse(null);
            if (patient != null) {
                payment.setPatientName(patient.getFullName());
                payment.setPatientEmail(patient.getEmail());
                payment.setPatientPhone(patient.getPhone());
                payment.setPatientAddress(patient.getAddress());
            }
            if (doctor != null) {
                payment.setDoctorName(doctor.getFullName());
                payment.setDoctorSpecialization(doctor.getSpecialization());
            }
            if (appt != null) {
                payment.setAppointmentDate(appt.getDate());
                payment.setAppointmentTime(appt.getTime());
            }
            payment.setInvoiceNumber("INV-" + payment.getId());
        }
        request.setAttribute("payments", payments);
        double totalPaid = payments.stream().filter(p -> "PAID".equalsIgnoreCase(p.getStatus())).mapToDouble(Payment::getAmount).sum();
        double pendingAmount = payments.stream().filter(p -> "PENDING".equalsIgnoreCase(p.getStatus())).mapToDouble(Payment::getAmount).sum();
        request.setAttribute("totalPaid", totalPaid);
        request.setAttribute("pendingAmount", pendingAmount);
        // Optionally set last payment info
        payments.stream().filter(p -> p.getPaymentDate() != null).max((a, b) -> a.getPaymentDate().compareTo(b.getPaymentDate())).ifPresent(last -> {
            request.setAttribute("lastPaymentDate", last.getPaymentDate());
            request.setAttribute("lastPaymentAmount", last.getAmount());
        });
        request.getRequestDispatcher("payment.jsp").forward(request, response);
    }
}
