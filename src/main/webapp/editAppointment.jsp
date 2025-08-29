<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.time.*" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="com.google.gson.reflect.TypeToken" %>
<%@ page import="java.lang.reflect.Type" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Appointment - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/appointments.css">
    <link rel="stylesheet" href="styles/forms.css">
</head>
<body>
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
            <%
                // Get the logged in user
                String username = (String) session.getAttribute("username");
                String userRole = (String) session.getAttribute("role");
                String error = null;
                Map<String, Object> appointmentToEdit = null;
                List<Map<String, Object>> doctors = new ArrayList<>();
                String appointmentId = request.getParameter("id");
                
                if (username == null) {
                    response.sendRedirect("login.jsp");
                    return;
                }
                
                if (appointmentId == null || appointmentId.isEmpty()) {
                    response.sendRedirect("appointments.jsp?error=No appointment specified");
                    return;
                }
                
                // Path to JSON files
                String usersJsonPath = application.getRealPath("/WEB-INF/classes/users.json");
                String appointmentsJsonPath = application.getRealPath("/WEB-INF/classes/appointments.json");
                
                try {
                    // Read users.json to get doctor list
                    File usersFile = new File(usersJsonPath);
                    if (usersFile.exists()) {
                        try (FileReader reader = new FileReader(usersFile)) {
                            Gson gson = new Gson();
                            Type userListType = new TypeToken<ArrayList<Map<String, Object>>>(){}.getType();
                            List<Map<String, Object>> users = gson.fromJson(reader, userListType);
                            
                            // Filter doctor users
                            for (Map<String, Object> user : users) {
                                if (user.containsKey("role") && "DOCTOR".equals(user.get("role"))) {
                                    doctors.add(user);
                                }
                            }
                        }
                    } else {
                        error = "Users data file not found";
                    }
                    
                    // Read appointment data from appointments.json
                    File appointmentsFile = new File(appointmentsJsonPath);
                    List<Map<String, Object>> appointments = new ArrayList<>();
                    
                    if (appointmentsFile.exists()) {
                        try (FileReader reader = new FileReader(appointmentsFile)) {
                            Gson gson = new Gson();
                            Type appointmentListType = new TypeToken<ArrayList<Map<String, Object>>>(){}.getType();
                            appointments = gson.fromJson(reader, appointmentListType);
                            
                            // Find appointment by ID
                            for (Map<String, Object> appointment : appointments) {
                                if (appointment.get("id").toString().equals(appointmentId)) {
                                    appointmentToEdit = appointment;
                                    
                                    // Check if user has permission to edit this appointment
                                    boolean hasPermission = false;
                                    
                                    if ("PATIENT".equals(userRole) && 
                                        username.equals(appointment.get("patientUsername"))) {
                                        hasPermission = true;
                                    } else if ("DOCTOR".equals(userRole) && 
                                               username.equals(appointment.get("doctorUsername"))) {
                                        hasPermission = true;
                                    } else if ("ADMIN".equals(userRole)) {
                                        hasPermission = true;
                                    }
                                    
                                    if (!hasPermission) {
                                        response.sendRedirect("appointments.jsp?error=You do not have permission to edit this appointment");
                                        return;
                                    }
                                    
                                    break;
                                }
                            }
                            
                            if (appointmentToEdit == null) {
                                response.sendRedirect("appointments.jsp?error=Appointment not found");
                                return;
                            }
                            
                            // Handle form submission for updating appointment
                            if ("POST".equalsIgnoreCase(request.getMethod())) {
                                String doctorId = request.getParameter("doctorId");
                                String date = request.getParameter("date");
                                String appointmentTime = request.getParameter("time");
                                String reason = request.getParameter("reason");
                                
                                // Validate required fields
                                if (doctorId == null || doctorId.isEmpty() || 
                                    date == null || date.isEmpty() ||
                                    appointmentTime == null || appointmentTime.isEmpty() ||
                                    reason == null || reason.isEmpty()) {
                                    error = "All fields are required";
                                } else {
                                    // Find doctor name from doctors list
                                    String doctorName = "";
                                    String doctorUsername = "";
                                    for (Map<String, Object> doctor : doctors) {
                                        if (doctor.get("id").toString().equals(doctorId)) {
                                            doctorName = doctor.get("fullName").toString();
                                            doctorUsername = doctor.get("username").toString();
                                            break;
                                        }
                                    }
                                    
                                    // Update appointment details
                                    for (Map<String, Object> appointment : appointments) {
                                        if (appointment.get("id").toString().equals(appointmentId)) {
                                            appointment.put("doctorId", doctorId);
                                            appointment.put("doctorUsername", doctorUsername);
                                            appointment.put("doctorName", doctorName);
                                            appointment.put("date", date);
                                            appointment.put("time", appointmentTime);
                                            appointment.put("reason", reason);
                                            appointment.put("updatedAt", LocalDateTime.now().toString());
                                            appointment.put("status", "RESCHEDULED");
                                            appointment.put("notes", appointment.get("notes") + 
                                                         "\nAppointment rescheduled on " + 
                                                         LocalDateTime.now().toString() +
                                                         " by " + username);
                                            break;
                                        }
                                    }
                                    
                                    // Write updated appointments back to file
                                    try (FileWriter writer = new FileWriter(appointmentsFile)) {
                                        Gson gson = new GsonBuilder().setPrettyPrinting().create();
                                        gson.toJson(appointments, writer);
                                    }
                                    
                                    // Redirect to appointments page
                                    response.sendRedirect("appointments.jsp?success=Appointment updated successfully!");
                                    return;
                                }
                            }
                        }
                    } else {
                        error = "Appointments data file not found";
                    }
                } catch (Exception e) {
                    error = "Error processing appointment: " + e.getMessage();
                }
                
                // Calculate min and max dates for date picker (today to 30 days from now)
                LocalDate today = LocalDate.now();
                LocalDate maxDate = today.plusDays(30);
                
                // Generate available appointment times from 9 AM to 5 PM in 30-minute intervals
                List<String> availableTimes = new ArrayList<>();
                for (int hour = 9; hour <= 17; hour++) {
                    String ampm = hour < 12 ? "AM" : "PM";
                    int displayHour = hour > 12 ? hour - 12 : hour;
                    if (displayHour == 0) displayHour = 12; // Handle midnight/noon
                    
                    availableTimes.add(String.format("%d:00 %s", displayHour, ampm));
                    availableTimes.add(String.format("%d:30 %s", displayHour, ampm));
                }
                
                pageContext.setAttribute("doctors", doctors);
                pageContext.setAttribute("appointment", appointmentToEdit);
                pageContext.setAttribute("availableTimes", availableTimes);
                pageContext.setAttribute("error", error);
                pageContext.setAttribute("minDate", today.toString());
                pageContext.setAttribute("maxDate", maxDate.toString());
            %>
            
            <div class="appointment-form-container">
                <h2>Edit Appointment</h2>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <c:out value="${error}"/>
                    </div>
                </c:if>
                
                <form action="editAppointment.jsp" method="POST" onsubmit="return validateForm()">
                    <input type="hidden" name="id" value="${appointment.id}">
                    
                    <div class="form-group">
                        <label for="doctorId">Doctor</label>
                        <select id="doctorId" name="doctorId" required>
                            <option value="">Select a Doctor</option>
                            <c:forEach items="${doctors}" var="doctor">
                                <option value="${doctor.id}" ${appointment.doctorId == doctor.id ? 'selected' : ''}>
                                    Dr. ${doctor.fullName} - ${doctor.specialization}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="date">Appointment Date</label>
                        <input type="date" id="date" name="date" value="${appointment.date}" required 
                               min="${minDate}" max="${maxDate}">
                        <small>Please select a date between ${minDate} and ${maxDate}</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="time">Appointment Time</label>
                        <select id="time" name="time" required>
                            <option value="">Select a Time</option>
                            <c:forEach items="${availableTimes}" var="timeSlot">
                                <option value="${timeSlot}" ${appointment.time == timeSlot ? 'selected' : ''}>
                                    ${timeSlot}
                                </option>
                            </c:forEach>
                        </select>
                        <small>Please select from available time slots between 9:00 AM and 5:30 PM</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="reason">Reason for Visit</label>
                        <textarea id="reason" name="reason" rows="4" required 
                                  placeholder="Please describe your reason for the appointment">${appointment.reason}</textarea>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Update Appointment</button>
                        <a href="appointments.jsp" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </main>
        
    </div>
    
    <script>
        function validateForm() {
            // Get form values
            const doctorId = document.getElementById('doctorId').value;
            const date = document.getElementById('date').value;
            const time = document.getElementById('time').value;
            const reason = document.getElementById('reason').value;
            
            // Validate all required fields
            if (!doctorId || doctorId === '') {
                alert('Please select a doctor');
                return false;
            }
            
            if (!date) {
                alert('Please select an appointment date');
                return false;
            }
            
            if (!time) {
                alert('Please select an appointment time');
                return false;
            }
            
            if (!reason || reason.trim() === '') {
                alert('Please enter a reason for the appointment');
                return false;
            }
            
            // Add confirmation
            return confirm('Are you sure you want to update this appointment? This will change the appointment status to RESCHEDULED.');
        }
        
        // Set min date to today
        document.addEventListener('DOMContentLoaded', function() {
            const dateInput = document.getElementById('date');
            const today = new Date().toISOString().split('T')[0];
            if (dateInput) {
                dateInput.min = today;
            }
        });
    </script>
</body>
</html>
