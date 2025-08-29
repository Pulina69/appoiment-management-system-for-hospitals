<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/profile.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>Medical Appointment System</h1>
            <nav>
                <ul>
                    <li><a href="appointments.jsp">Appointments</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                    <li><a href="payment.jsp">payment</a></li>
                    <li><a href="login.jsp">Logout</a></li>
                </ul>
            </nav>
        </header>

        <main>
            <div class="profile-card">
                <h2>Profile Information</h2>
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

                <div class="profile-info">
                    <div class="info-group">
                        <label>Username:</label>
                        <span>${sessionScope.user.username}</span>
                    </div>
                    <div class="info-group">
                        <label>Full Name:</label>
                        <span>${sessionScope.user.fullName}</span>
                    </div>
                    <div class="info-group">
                        <label>Email:</label>
                        <span>${sessionScope.user.email}</span>
                    </div>
                    <div class="info-group">
                        <label>Phone:</label>
                        <span>${sessionScope.user.phone}</span>
                    </div>
                    <div class="info-group">
                        <label>Role:</label>
                        <span>${sessionScope.user.role}</span>
                    </div>
                    <div class="info-group">
                        <label>Status:</label>
                        <span class="status ${sessionScope.user.status != null ? sessionScope.user.status.toLowerCase() : ''}">
                            ${sessionScope.user.status != null ? sessionScope.user.status : ''}
                        </span>
                    </div>
                </div>

                <div class="profile-actions">
                    <a href="editProfile" class="btn btn-primary">Edit Profile</a>
                    <a href="changePassword" class="btn btn-secondary">Change Password</a>
                </div>
            </div>
        </main>
        
    </div>
</body>
</html>
