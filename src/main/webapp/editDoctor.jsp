<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Change Password - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/profile.css">
    <link rel="stylesheet" href="styles/forms.css">
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
            <h2>Change Password</h2>
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
            <form action="changePassword" method="POST" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="currentPassword">Current Password</label>
                    <input type="password" id="currentPassword" name="currentPassword" required>
                </div>

                <div class="form-group">
                    <label for="newPassword">New Password</label>
                    <input type="password" id="newPassword" name="newPassword" required>
                    <small>Password must be at least 8 characters long and include a mix of letters, numbers, and symbols.</small>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm New Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Change Password</button>
                    <a href="viewDoctorProfile.jsp" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </main>

</div>
</body>
</html>
