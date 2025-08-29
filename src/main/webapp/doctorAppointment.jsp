
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.io.*, java.util.*, com.google.gson.Gson, com.google.gson.reflect.TypeToken, java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Appointments - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/profile.css">
    <link rel="stylesheet" href="styles/forms.css">
    <link rel="stylesheet" href="styles/auth.css">
    <link rel="stylesheet" href="styles/dashboard.css">
    <link rel="stylesheet" href="styles/payment.css">
</head>
<body>
    <%
        // Get the logged-in doctor's username from the session
        String loggedInUsername = (String) session.getAttribute("username");
        
        if (loggedInUsername == null) {
            // Redirect to login if not logged in
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Initialize variables
        List<Map<String, Object>> doctorAppointments = new ArrayList<>();
        
        try {
            // Read appointments from JSON file
            String jsonFilePath = application.getRealPath("/WEB-INF/classes/appointments.json");
            Gson gson = new Gson();
            
            try (FileReader reader = new FileReader(jsonFilePath)) {
                // Parse JSON array from file
                List<Map<String, Object>> allAppointments = gson.fromJson(reader, 
                    new TypeToken<List<Map<String, Object>>>(){}.getType());
                
                // Filter appointments for this doctor
                for (Map<String, Object> appointment : allAppointments) {
                    String doctorUsername = (String) appointment.get("doctorUsername");
                    
                    if (loggedInUsername.equals(doctorUsername)) {
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
                        
                        doctorAppointments.add(appointment);
                    }
                }
            }
            
            // Set the filtered appointments in the request
            request.setAttribute("appointments", doctorAppointments);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error loading appointments: " + e.getMessage());
        }
    %>

    <div class="container">
        <header>
            <h1>Medical Appointment System</h1>
            <nav>
                <ul>
                    <li><a href="doctorAppointment.jsp">Appointments</a></li>
                    <li><a href="viewDoctorProfile.jsp">Profile</a></li>
                    <li><a href="login.jsp">Logout</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <div class="appointments-container">
                <div class="appointments-header">
                    <h2>My Schedule</h2>
                    <div class="appointment-filters">
                        <select id="statusFilter" onchange="filterAppointments()">
                            <option value="ALL">All Appointments</option>
                            <option value="SCHEDULED">Scheduled</option>
                            <option value="COMPLETED">Completed</option>
                            <option value="CANCELLED">Cancelled</option>
                        </select>
                    </div>
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
                    <c:if test="${empty appointments}">
                        <p class="no-appointments">No appointments found.</p>
                    </c:if>

                    <c:forEach items="${appointments}" var="appointment">
                        <div class="appointment-card">
                            <div class="appointment-header">
                                <h3>Appointment #${appointment.id}</h3>
                                <span class="status ${appointment.status.toLowerCase()}">
                                    <c:out value="${appointment.status}"/>
                                </span>
                            </div>

                            <div class="appointment-details">
                                <div class="detail-group">
                                    <label>Patient Name:</label>
                                    <span><c:out value="${appointment.patientName}"/></span>
                                </div>                                <div class="detail-group">
                                    <label>Date:</label>
                                    <span><fmt:formatDate value="${appointment.dateObj}" pattern="MMMM dd, yyyy"/></span>
                                </div>

                                <div class="detail-group">
                                    <label>Time:</label>
                                    <span><fmt:formatDate value="${appointment.timeObj}" pattern="hh:mm a"/></span>
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
                                    <button onclick="completeAppointment('${appointment.id}')" class="btn btn-success">Complete</button>
                                    <button onclick="cancelAppointment('${appointment.id}')" class="btn btn-danger">Cancel</button>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </main>
    </div>

    <script>
        function filterAppointments() {
            var status = document.getElementById('statusFilter').value;
            var appointments = document.querySelectorAll('.appointment-card');
            
            appointments.forEach(function(appointment) {
                var appointmentStatus = appointment.querySelector('.status').textContent.trim();
                if (status === 'ALL' || appointmentStatus === status) {
                    appointment.style.display = 'block';
                } else {
                    appointment.style.display = 'none';
                }
            });
        }

        function completeAppointment(appointmentId) {
            if (confirm('Are you sure you want to mark this appointment as completed?')) {
                window.location.href = 'completeAppointment?id=' + appointmentId;
            }
        }

        function cancelAppointment(appointmentId) {
            if (confirm('Are you sure you want to cancel this appointment?')) {
                window.location.href = 'cancelAppointment?id=' + appointmentId;
            }
        }
    </script>
</body>
</html> 