<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="java.io.*, java.util.*, java.text.SimpleDateFormat, com.google.gson.Gson, com.google.gson.reflect.TypeToken" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointments - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/appointments.css">
</head>
<body>
    <%
        // Get the logged-in user's username from the session
        String loggedInUsername = (String) session.getAttribute("username");
        
        if (loggedInUsername == null) {
            // Redirect to login if not logged in
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Initialize variables
        List<Map<String, Object>> userAppointments = new ArrayList<>();
        
        try {
            // Read appointments from JSON file
            String jsonFilePath = application.getRealPath("/WEB-INF/classes/appointments.json");
            Gson gson = new Gson();
            
            try (FileReader reader = new FileReader(jsonFilePath)) {
                // Parse JSON array from file
                List<Map<String, Object>> allAppointments = gson.fromJson(reader, 
                    new TypeToken<List<Map<String, Object>>>(){}.getType());
                
                // Filter appointments for this user
                for (Map<String, Object> appointment : allAppointments) {
                    String patientUsername = (String) appointment.get("patientUsername");
                    
                    if (loggedInUsername.equals(patientUsername)) {
                        // Parse date and time for formatting
                        String dateStr = (String) appointment.get("date");
                        String timeStr = (String) appointment.get("time");
                        
                        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
                        
                        try {
                            appointment.put("dateObj", dateFormat.parse(dateStr));
                            appointment.put("timeObj", timeFormat.parse(timeStr));
                        } catch (Exception e) {
                            // Use current date/time if parsing fails
                            appointment.put("dateObj", new Date());
                            appointment.put("timeObj", new Date());
                        }
                        
                        userAppointments.add(appointment);
                    }
                }
            }
            
            // Set the filtered appointments in the request
            request.setAttribute("appointments", userAppointments);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error loading appointments: " + e.getMessage());
        }
    %>
    
    <div class="container">
        <header>
            <h1>Medical Appointment System</h1>
            <nav>
                <ul>
                    <li><a href="appointments.jsp">Appointments</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                    <li><a href="payment.jsp">Payment</a></li>
                    <li><a href="login.jsp">Logout</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <div class="appointments-container">
                <div class="appointments-header">
                        <a href="bookAppointment.jsp" class="btn btn-primary">Book New Appointment</a>
                </div>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <c:out value="${error}"/>
                    </div>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="alert alert-success">
                        <c:out value="${success}"/>
                    </div>
                </c:if>
                
                <div class="appointments-list">
                    <p>Logged in as: <strong>${sessionScope.username}</strong></p>
                    <p>Appointments count: ${fn:length(appointments)}</p>
                    <c:if test="${empty appointments}">
                        <p class="no-appointments">No appointments found for your account.</p>
                    </c:if>
                    
                    <c:forEach items="${appointments}" var="appointment">
                    <div class="appointment-card">
                        <div class="appointment-header">
                            <h3>Appointment #${appointment.id}</h3>
                            <span class="status ${fn:toLowerCase(appointment.status)}">
                                <c:out value="${appointment.status}"/>
                            </span>
                        </div>
                        
                        <div class="appointment-details">
                            <div class="detail-group">
                                <label>Date:</label>
                                <span><fmt:formatDate value="${appointment.dateObj}" pattern="MMMM dd, yyyy"/></span>
                            </div>
                            
                            <div class="detail-group">
                                <label>Time:</label>
                                <span><fmt:formatDate value="${appointment.timeObj}" pattern="hh:mm a"/></span>
                            </div>
                            
                            <div class="detail-group">
                                <label>Doctor:</label>
                                <span><c:out value="${appointment.doctorName}"/></span>
                            </div>
                            
                            <div class="detail-group">
                                <label>Reason:</label>
                                <span><c:out value="${appointment.reason}"/></span>
                            </div>
                            
                            <c:if test="${not empty appointment.notes}">
                                <div class="detail-group">
                                    <label>Notes:</label>
                                    <span><c:out value="${appointment.notes}"/></span>
                                </div>
                            </c:if>
                        </div>
                                        
                        <div class="appointment-actions">
                            <c:if test="${appointment.status == 'SCHEDULED'}">
                                <a href="editAppointment?id=${appointment.id}" class="btn btn-secondary">Edit</a>
                                <a href="cancelAppointment?id=${appointment.id}" onclick="return confirm('Are you sure you want to cancel this appointment?');" class="btn btn-danger">Cancel</a>
                            </c:if>
                            
                            <c:if test="${appointment.paymentId == null || appointment.paymentId == ''}">
                                <a href="payNow.jsp?appointmentId=${appointment.id}" class="btn btn-primary">Pay Now</a>
                            </c:if>
                            <c:if test="${appointment.paymentId != null && appointment.paymentId != ''}">
                                <span class="payment-status paid">Payment Completed</span>
                            </c:if>
                        </div>
                    </div>
                    </c:forEach>
                </div>
            </div>
        </main>
    </div>
    
    <style>
        .payment-status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 4px;
            font-weight: bold;
        }
        
        .payment-status.paid {
            background-color: #e8f5e9;
            color: #2e7d32;
        }
        
        .status.scheduled {
            background-color: #e3f2fd;
            color: #1976d2;
        }
        
        .status.completed {
            background-color: #e8f5e9;
            color: #2e7d32;
        }
        
        .status.cancelled {
            background-color: #ffebee;
            color: #c62828;
        }
    </style>
</body>
</html>
