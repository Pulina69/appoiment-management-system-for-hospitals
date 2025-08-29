package com.medical.servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Servlet to process payments
 */
@WebServlet("/processPayment")
public class ProcessPaymentServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get parameters
        String paymentId = request.getParameter("paymentId");
        String appointmentId = request.getParameter("appointmentId");
        String paymentMethod = request.getParameter("paymentMethod");
        String amountStr = request.getParameter("amount");
        String invoiceNumber = request.getParameter("invoiceNumber");
        String description = request.getParameter("description");
        
        double amount = 0;
        try {
            amount = Double.parseDouble(amountStr);
        } catch (Exception e) {
            session.setAttribute("error", "Invalid payment amount");
            response.sendRedirect("payment.jsp");
            return;
        }
        
        // Get paths to JSON files
        String paymentsJsonPath = getServletContext().getRealPath("/WEB-INF/classes/payment.json");
        String appointmentsJsonPath = getServletContext().getRealPath("/WEB-INF/classes/appointments.json");
        
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        boolean isSuccess = false;
        
        try {
            // Process the payment and update records
            if (paymentId != null && !paymentId.isEmpty()) {
                // Update existing payment record
                List<Map<String, Object>> payments = new ArrayList<>();
                
                try (FileReader reader = new FileReader(paymentsJsonPath)) {
                    payments = gson.fromJson(reader, new TypeToken<List<Map<String, Object>>>(){}.getType());
                }
                
                for (Map<String, Object> payment : payments) {
                    if (payment.get("id").toString().equals(paymentId)) {
                        // Update payment record
                        payment.put("status", "PAID");
                        payment.put("paymentMethod", paymentMethod);
                        payment.put("paymentDate", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
                        
                        // Update appointment if needed
                        if (payment.get("appointmentId") != null) {
                            appointmentId = payment.get("appointmentId").toString();
                        }
                        
                        isSuccess = true;
                        break;
                    }
                }
                
                // Write changes back to file
                try (FileWriter writer = new FileWriter(paymentsJsonPath)) {
                    gson.toJson(payments, writer);
                }
            } else if (appointmentId != null && !appointmentId.isEmpty()) {
                // Create new payment record
                List<Map<String, Object>> payments = new ArrayList<>();
                Map<String, Object> appointment = null;
                
                // Find appointment details
                List<Map<String, Object>> appointments = new ArrayList<>();
                try (FileReader reader = new FileReader(appointmentsJsonPath)) {
                    appointments = gson.fromJson(reader, new TypeToken<List<Map<String, Object>>>(){}.getType());
                }
                
                for (Map<String, Object> apt : appointments) {
                    if (apt.get("id").toString().equals(appointmentId)) {
                        appointment = apt;
                        break;
                    }
                }
                
                if (appointment == null) {
                    session.setAttribute("error", "Appointment not found");
                    response.sendRedirect("payment.jsp");
                    return;
                }
                
                // Read existing payments
                try (FileReader reader = new FileReader(paymentsJsonPath)) {
                    payments = gson.fromJson(reader, new TypeToken<List<Map<String, Object>>>(){}.getType());
                }
                
                // Create new payment
                Map<String, Object> newPayment = new HashMap<>();
                newPayment.put("id", "PAY" + System.currentTimeMillis());
                newPayment.put("appointmentId", appointmentId);
                newPayment.put("patientId", appointment.get("patientId"));
                newPayment.put("patientUsername", appointment.get("patientUsername"));
                newPayment.put("doctorId", appointment.get("doctorId"));
                newPayment.put("doctorUsername", appointment.get("doctorUsername"));
                newPayment.put("amount", amount);
                newPayment.put("status", "PAID");
                newPayment.put("paymentMethod", paymentMethod);
                newPayment.put("paymentDate", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
                newPayment.put("description", description);
                
                payments.add(newPayment);
                
                // Update appointment with payment ID
                for (Map<String, Object> apt : appointments) {
                    if (apt.get("id").toString().equals(appointmentId)) {
                        apt.put("paymentId", newPayment.get("id"));
                        break;
                    }
                }
                
                // Write payment changes
                try (FileWriter writer = new FileWriter(paymentsJsonPath)) {
                    gson.toJson(payments, writer);
                }
                
                // Write appointment changes
                try (FileWriter writer = new FileWriter(appointmentsJsonPath)) {
                    gson.toJson(appointments, writer);
                }
                
                isSuccess = true;
            } else {
                session.setAttribute("error", "No payment or appointment ID provided");
                response.sendRedirect("payment.jsp");
                return;
            }
              if (isSuccess) {
                // Generate transaction ID
                String transactionId = "TXN" + System.currentTimeMillis();
                
                // Format current date for display
                String formattedDate = new SimpleDateFormat("MMMM dd, yyyy").format(new Date());
                
                // Redirect to success page with payment details
                response.sendRedirect("paymentSuccess.jsp" + 
                    "?transactionId=" + transactionId +
                    "&paymentDate=" + formattedDate +
                    "&paymentMethod=" + paymentMethod +
                    "&amount=" + amount);
            } else {
                session.setAttribute("error", "Failed to process payment");
                response.sendRedirect("payNow.jsp");
            }
            
        } catch (Exception e) {
            session.setAttribute("error", "Error processing payment: " + e.getMessage());
            response.sendRedirect("payment.jsp");
        }
    }
}
