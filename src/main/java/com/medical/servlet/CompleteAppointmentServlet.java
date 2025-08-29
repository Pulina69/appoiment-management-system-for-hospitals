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
import java.util.*;

/**
 * Servlet to handle appointment completion
 */
@WebServlet("/completeAppointment")
public class CompleteAppointmentServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String appointmentId = request.getParameter("id");
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        
        // Only doctors should be able to complete appointments
        if (username == null || role == null || !role.equals("DOCTOR")) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        if (appointmentId == null || appointmentId.trim().isEmpty()) {
            session.setAttribute("error", "Invalid appointment ID.");
            response.sendRedirect("doctorAppointment.jsp");
            return;
        }
        
        // Get path to the appointments.json file
        String jsonFilePath = getServletContext().getRealPath("/WEB-INF/classes/appointments.json");
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        List<Map<String, Object>> appointments = new ArrayList<>();
        boolean appointmentFound = false;
        boolean authorized = false;
        
        try {
            // Read existing appointments
            try (Reader reader = new FileReader(jsonFilePath)) {
                appointments = gson.fromJson(reader, new TypeToken<List<Map<String, Object>>>(){}.getType());
            }
            
            // Find and update the specific appointment
            for (Map<String, Object> appointment : appointments) {
                String id = appointment.get("id").toString();
                
                if (id.equals(appointmentId)) {
                    appointmentFound = true;
                    
                    // Verify this appointment belongs to the logged-in doctor
                    String doctorUsername = (String) appointment.get("doctorUsername");
                    
                    if (username.equals(doctorUsername)) {
                        authorized = true;
                        
                        // Update appointment status
                        appointment.put("status", "COMPLETED");
                        
                        // Add completion notes
                        String currentNotes = (String) appointment.get("notes");
                        if (currentNotes == null || currentNotes.trim().isEmpty()) {
                            appointment.put("notes", "Completed on " + new Date());
                        } else {
                            appointment.put("notes", currentNotes + " | Completed on " + new Date());
                        }
                        
                        break;
                    }
                }
            }
            
            if (!appointmentFound) {
                session.setAttribute("error", "Appointment not found.");
                response.sendRedirect("doctorAppointment.jsp");
                return;
            }
            
            if (!authorized) {
                session.setAttribute("error", "You are not authorized to complete this appointment.");
                response.sendRedirect("doctorAppointment.jsp");
                return;
            }
            
            // Write updated appointments back to file
            try (Writer writer = new FileWriter(jsonFilePath)) {
                gson.toJson(appointments, writer);
                session.setAttribute("success", "Appointment completed successfully.");
            }
            
        } catch (Exception e) {
            session.setAttribute("error", "Error completing appointment: " + e.getMessage());
        }
        
        response.sendRedirect("doctorAppointment.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
