
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.io.*, java.util.*, java.text.SimpleDateFormat, java.text.DecimalFormat, com.google.gson.Gson, com.google.gson.reflect.TypeToken" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/dashboard.css">
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

        // Load user data from JSON
        String usersJsonPath = application.getRealPath("/WEB-INF/classes/users.json");
        String appointmentsJsonPath = application.getRealPath("/WEB-INF/classes/appointments.json");
        String paymentsJsonPath = application.getRealPath("/WEB-INF/classes/payment.json");
        
        Gson gson = new Gson();
        List<Map<String, Object>> users = new ArrayList<>();
        List<Map<String, Object>> appointments = new ArrayList<>();
        List<Map<String, Object>> payments = new ArrayList<>();
        
        // Current user info
        Map<String, Object> currentUser = null;
        String userFullName = "User";
        
        // Statistics variables
        int totalUsers = 0;
        int totalDoctors = 0;
        int appointmentsThisWeek = 0;
        double totalPaymentsThisMonth = 0;
        
        // Set up date formats
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        DecimalFormat df = new DecimalFormat("#,##0.00");
        
        // Get current date and calculate dates for this week/month
        Date currentDate = new Date();
        Calendar cal = Calendar.getInstance();
        cal.setTime(currentDate);
        cal.add(Calendar.DAY_OF_YEAR, -7);
        Date oneWeekAgo = cal.getTime();
        
        cal.setTime(currentDate);
        cal.set(Calendar.DAY_OF_MONTH, 1);
        Date startOfMonth = cal.getTime();
        
        try {
            // Read users data
            try (FileReader reader = new FileReader(usersJsonPath)) {
                users = gson.fromJson(reader, new TypeToken<List<Map<String, Object>>>(){}.getType());
                
                // Find current user and count total users/doctors
                for (Map<String, Object> user : users) {
                    String username = (String) user.get("username");
                    String role = (String) user.get("role");
                    
                    if (username.equals(loggedInUsername)) {
                        currentUser = user;
                        userFullName = (String) user.get("fullName");
                    }
                    
                    if ("DOCTOR".equals(role)) {
                        totalDoctors++;
                    }
                }
                
                totalUsers = users.size();
            }
            
            // Read appointments data
            try (FileReader reader = new FileReader(appointmentsJsonPath)) {
                appointments = gson.fromJson(reader, new TypeToken<List<Map<String, Object>>>(){}.getType());
                
                // Count appointments this week
                for (Map<String, Object> appointment : appointments) {
                    String dateStr = (String) appointment.get("date");
                    try {
                        Date appointmentDate = sdf.parse(dateStr);
                        if (appointmentDate.after(oneWeekAgo)) {
                            appointmentsThisWeek++;
                        }
                    } catch (Exception e) {
                        // Skip invalid dates
                    }
                }
            }
            
            // Read payments data
            try (FileReader reader = new FileReader(paymentsJsonPath)) {
                payments = gson.fromJson(reader, new TypeToken<List<Map<String, Object>>>(){}.getType());
                
                // Calculate payments this month
                for (Map<String, Object> payment : payments) {
                    String dateStr = (String) payment.get("paymentDate");
                    double amount = 0;
                    
                    // Get the amount - handle both Double and String cases
                    Object amountObj = payment.get("amount");
                    if (amountObj instanceof Double) {
                        amount = (Double) amountObj;
                    } else if (amountObj instanceof String) {
                        try {
                            amount = Double.parseDouble((String) amountObj);
                        } catch (Exception e) {
                            // Invalid amount format
                        }
                    }
                    
                    // Add to monthly total if within this month
                    try {
                        if (dateStr != null) {
                            Date paymentDate = sdf.parse(dateStr);
                            if (paymentDate.after(startOfMonth)) {
                                totalPaymentsThisMonth += amount;
                            }
                        }
                    } catch (Exception e) {
                        // Skip invalid dates
                    }
                }
            }
            
            // Get recent records
            List<Map<String, Object>> recentAppointments = getRecentRecords(appointments, 4);
            List<Map<String, Object>> recentUsers = getRecentRecords(users, 4);
            
            // Set data for the JSP
            request.setAttribute("userFullName", userFullName);
            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalDoctors", totalDoctors);
            request.setAttribute("appointmentsThisWeek", appointmentsThisWeek);
            request.setAttribute("totalPaymentsThisMonth", totalPaymentsThisMonth);
            request.setAttribute("recentAppointments", recentAppointments);
            request.setAttribute("recentUsers", recentUsers);
            
        } catch (Exception e) {
            request.setAttribute("error", "Error loading data: " + e.getMessage());
        }
    %>
    
    <%!
        // Helper method to get the most recent records
        private List<Map<String, Object>> getRecentRecords(List<Map<String, Object>> records, int count) {
            // Sort by ID in descending order (assuming higher IDs are more recent)
            Collections.sort(records, new Comparator<Map<String, Object>>() {
                @Override
                public int compare(Map<String, Object> o1, Map<String, Object> o2) {
                    String id1 = o1.get("id").toString();
                    String id2 = o2.get("id").toString();
                    return id2.compareTo(id1);
                }
            });
            
            // Return the top 'count' records or all if fewer
            return records.subList(0, Math.min(count, records.size()));
        }
    %>

    <div class="container">
        <header>
            <h1>Medical Appointment System</h1>
            <nav>
                <ul>
                    <li><a href="dashboard.jsp">Dashboard</a></li>
                    <li><a href="userList">Users</a></li>
                    <li><a href="doctorList">Doctors</a></li>
                    <li><a href="login.jsp">Logout</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <div class="page-header">
                <h2>Dashboard</h2>
                <div class="user-welcome">
                    <p>Welcome, <strong>${userFullName}</strong>!</p>
                </div>
            </div>
            
            <div class="dashboard-stats">
                <div class="stat-card">
                    <h3>Users</h3>
                    <p class="stat-number">${totalUsers}</p>
                    <p class="stat-label">Registered</p>
                </div>
                <div class="stat-card">
                    <h3>Doctors</h3>
                    <p class="stat-number">${totalDoctors}</p>
                    <p class="stat-label">Available</p>
                </div>
                <div class="stat-card">
                    <h3>Appointments</h3>
                    <p class="stat-number">${appointmentsThisWeek}</p>
                    <p class="stat-label">This Week</p>
                </div>
                <div class="stat-card">
                    <h3>Payments</h3>
                    <p class="stat-number">$<fmt:formatNumber value="${totalPaymentsThisMonth}" pattern="#,##0.00"/></p>
                    <p class="stat-label">This Month</p>
                </div>
            </div>
            
            <div class="dashboard-sections">
                <div class="dashboard-section">
                    <h3>Recent Appointments</h3>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">
                            <c:out value="${error}"/>
                        </div>
                    </c:if>
                    <table>
                        <thead>
                            <tr>
                                <th>Patient</th>
                                <th>Doctor</th>
                                <th>Date</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:if test="${empty recentAppointments}">
                                <tr>
                                    <td colspan="4">No appointments found.</td>
                                </tr>
                            </c:if>
                            <c:forEach items="${recentAppointments}" var="appointment">
                                <tr>
                                    <td><c:out value="${appointment.patientName}"/></td>
                                    <td><c:out value="${appointment.doctorName}"/></td>
                                    <td><c:out value="${appointment.date}"/></td>
                                    <td><span class="status ${appointment.status.toLowerCase()}"><c:out value="${appointment.status}"/></span></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                
                <div class="dashboard-section">
                    <h3>Recent Users</h3>
                    <table>
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Joined</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:if test="${empty recentUsers}">
                                <tr>
                                    <td colspan="4">No users found.</td>
                                </tr>
                            </c:if>
                            <c:forEach items="${recentUsers}" var="user">
                                <tr>
                                    <td><c:out value="${user.fullName}"/></td>
                                    <td><c:out value="${user.email}"/></td>
                                    <td><c:out value="${user.role}"/></td>
                                    <td><c:out value="${user.registrationDate != null ? user.registrationDate : 'N/A'}"/></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Add any JavaScript functionality here if needed
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Dashboard loaded successfully');
            
            // Example: Update the current time periodically
            function updateTime() {
                const now = new Date();
                const formattedTime = now.toLocaleTimeString();
                // For future use if needed
            }
            
            // Update time every minute
            setInterval(updateTime, 60000);
            updateTime();
        });
    </script>
</body>
</html>
