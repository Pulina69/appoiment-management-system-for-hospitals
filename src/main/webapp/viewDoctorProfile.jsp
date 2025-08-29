<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Information - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/profile.css">
</head>
<body>
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
            <div class="profile-card">
                <h2>Profile Information</h2>
                <c:choose>
                    <c:when test="${not empty user}">
                        <div class="profile-info">
                            <div><strong>Username:</strong> ${user.username}</div>
                            <div><strong>Full Name:</strong> ${user.fullName}</div>
                            <div><strong>Email:</strong> ${user.email}</div>
                            <div><strong>Phone:</strong> ${user.phone}</div>
                            <div><strong>Role:</strong> ${user.role}</div>
                            <div><strong>Status:</strong> ${user.status != null ? user.status : ''}</div>
                        </div>
                        <div class="profile-actions" style="margin-top: 16px;">
                            <a href="editDoctor.jsp" class="btn btn-primary">Edit Profile</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p>No user is logged in.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>
</body>
</html>
