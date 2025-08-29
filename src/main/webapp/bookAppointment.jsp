<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
    <title>Book Appointment - Medical Appointment System</title>
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
                    <li><a href="appointments">Appointments</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                    <li><a href="payment.jsp">payment</a></li>
                    <li><a href="login.jsp">Logout</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <%
                // Get the logged in user
                String username = (String) session.getAttribute("username");
                String userRole = (String) session.getAttribute("role");
                Map<String, Object> currentUser = null;
                List<Map<String, Object>> doctors = new ArrayList<>();
                String error = null;
                
                if (username == null) {
                    response.sendRedirect("login.jsp");
                    return;
                }
                
                // Path to JSON files
                String usersJsonPath = application.getRealPath("/WEB-INF/classes/users.json");
                String appointmentsJsonPath = application.getRealPath("/WEB-INF/classes/appointments.json");
                
                try {
                    // Read users.json to get doctor list and current user info
                    File usersFile = new File(usersJsonPath);
                    if (usersFile.exists()) {
                        try (FileReader reader = new FileReader(usersFile)) {
                            Gson gson = new Gson();
                            Type userListType = new TypeToken<ArrayList<Map<String, Object>>>(){}.getType();
                            List<Map<String, Object>> users = gson.fromJson(reader, userListType);
                            
                            // Filter doctor users and get current user info
                            for (Map<String, Object> user : users) {
                                if (user.containsKey("role") && "DOCTOR".equals(user.get("role"))) {
                                    doctors.add(user);
                                }
                                
                                if (user.containsKey("username") && username.equals(user.get("username"))) {
                                    currentUser = user;
                                    session.setAttribute("tempUser", currentUser);
                                }
                            }
                        }
                    } else {
                        error = "Users data file not found";
                    }
                    
                    // Handle form submission
                    if ("POST".equalsIgnoreCase(request.getMethod())) {
                        // Get form data
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
                            // Find doctor name from the doctor list
                            String doctorName = "";
                            String doctorUsername = "";
                            for (Map<String, Object> doctor : doctors) {
                                if (doctor.get("id").toString().equals(doctorId)) {
                                    doctorName = doctor.get("fullName").toString();
                                    doctorUsername = doctor.get("username").toString();
                                    break;
                                }
                            }
                            
                            // Read existing appointments
                            List<Map<String, Object>> appointments = new ArrayList<>();
                            File appointmentsFile = new File(appointmentsJsonPath);
                            if (appointmentsFile.exists()) {
                                try (FileReader reader = new FileReader(appointmentsFile)) {
                                    Gson gson = new Gson();
                                    Type appointmentListType = new TypeToken<ArrayList<Map<String, Object>>>(){}.getType();
                                    appointments = gson.fromJson(reader, appointmentListType);
                                }
                            }
                            
                            // Generate unique ID for the new appointment
                            String newAppointmentId = "APP" + (appointments.size() + 1);
                            
                            // Create new appointment
                            Map<String, Object> newAppointment = new HashMap<>();
                            newAppointment.put("id", newAppointmentId);
                            newAppointment.put("patientId", currentUser.get("id"));
                            newAppointment.put("patientUsername", username);
                            newAppointment.put("patientName", currentUser.get("fullName"));
                            newAppointment.put("patientEmail", currentUser.get("email"));
                            newAppointment.put("patientPhone", currentUser.get("phone"));
                            newAppointment.put("doctorId", doctorId);
                            newAppointment.put("doctorUsername", doctorUsername);
                            newAppointment.put("doctorName", doctorName);
                            newAppointment.put("date", date);
                            newAppointment.put("time", appointmentTime);
                            newAppointment.put("reason", reason);
                            newAppointment.put("status", "SCHEDULED");
                            newAppointment.put("notes", "");
                            newAppointment.put("createdAt", LocalDateTime.now().toString());
                            
                            // Add new appointment to the list
                            appointments.add(newAppointment);
                            
                            // Write updated appointments back to file
                            try (FileWriter writer = new FileWriter(appointmentsFile)) {
                                Gson gson = new GsonBuilder().setPrettyPrinting().create();
                                gson.toJson(appointments, writer);
                            }
                            
                            // Create payment record for this appointment
                            String paymentJsonPath = application.getRealPath("/WEB-INF/classes/payment.json");
                            List<Map<String, Object>> payments = new ArrayList<>();
                            File paymentFile = new File(paymentJsonPath);
                            
                            if (paymentFile.exists()) {
                                try (FileReader reader = new FileReader(paymentFile)) {
                                    Gson gson = new Gson();
                                    Type paymentListType = new TypeToken<ArrayList<Map<String, Object>>>(){}.getType();
                                    payments = gson.fromJson(reader, paymentListType);
                                }
                            }
                            
                            // Generate unique payment ID
                            String paymentId = "PAY" + String.format("%03d", payments.size() + 1);
                            
                            // Create payment record
                            Map<String, Object> payment = new HashMap<>();
                            payment.put("id", paymentId);
                            payment.put("appointmentId", newAppointmentId);
                            payment.put("patientId", currentUser.get("id"));
                            payment.put("patientUsername", username);
                            payment.put("doctorId", doctorId);
                            payment.put("doctorUsername", doctorUsername);
                            payment.put("amount", 75.00); // Standard consultation fee
                            payment.put("status", "PENDING");
                            payment.put("paymentMethod", null);
                            payment.put("paymentDate", null);
                            payment.put("description", reason);
                            
                            // Add new payment to list
                            payments.add(payment);
                            
                            // Write updated payments back to file
                            try (FileWriter writer = new FileWriter(paymentFile)) {
                                Gson gson = new GsonBuilder().setPrettyPrinting().create();
                                gson.toJson(payments, writer);
                            }
                            
                            // Redirect to appointments page
                            response.sendRedirect("appointments.jsp?success=Appointment booked successfully!");
                            return;
                        }
                    }
                } catch (Exception e) {
                    error = "Error processing appointment: " + e.getMessage();
                }
                
                // Calculate min and max dates for date picker (today to 30 days from now)
                LocalDate today = LocalDate.now();
                LocalDate maxDate = today.plusDays(30);
                
                pageContext.setAttribute("doctors", doctors);
                pageContext.setAttribute("error", error);
                pageContext.setAttribute("minDate", today.toString());
                pageContext.setAttribute("maxDate", maxDate.toString());
                pageContext.setAttribute("currentUser", currentUser);
            %>
            
            <div class="appointment-form-container">
                <h2>Book New Appointment</h2>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <c:out value="${error}"/>
                    </div>
                </c:if>
                
                <form action="bookAppointment.jsp" method="POST" onsubmit="return validateForm()">
                    <div class="form-group">
                        <label for="doctorId">Select Doctor</label>
                        <select id="doctorId" name="doctorId" required>
                            <option value="">Select a Doctor</option>
                            <c:forEach var="doctor" items="${doctors}">
                                <option value="${doctor.id}" ${param.doctorId == doctor.id ? 'selected' : ''}>
                                    Dr. ${doctor.fullName} (${doctor.username})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <!-- Hidden fields are handled in the JSP logic now -->
                    <input type="hidden" name="patientId" value="${currentUser.id}" />
                    <div class="form-group">
                        <label for="date">Appointment Date</label>
                        <input type="date" id="date" name="date" value="${param.date}" required 
                               min="${minDate}" max="${maxDate}">
                        <small>Please select a date between ${minDate} and ${maxDate}</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="time">Appointment Time</label>
                        <input type="text" id="time" name="time" value="${param.time}" required placeholder="e.g. 10:30 AM">
                    </div>
                    
                    <div class="form-group">
                        <label for="reason">Reason for Visit</label>
                        <textarea id="reason" name="reason" rows="4" required 
                                  placeholder="Please describe your reason for the appointment">${param.reason}</textarea>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Book Appointment</button>
                        <a href="appointments" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </main>
        
        <!-- Footer removed -->
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
                alert('Please enter an appointment time');
                return false;
            }
            
            // Basic time format validation (hh:mm AM/PM)
            const timeRegex = /^(0?[1-9]|1[0-2]):[0-5][0-9]\s?(AM|PM|am|pm)$/;
            if (!timeRegex.test(time)) {
                alert('Please enter a valid time format (e.g. 10:30 AM)');
                return false;
            }
            
            if (!reason || reason.trim() === '') {
                alert('Please enter a reason for the appointment');
                return false;
            }
            
            return true;
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
