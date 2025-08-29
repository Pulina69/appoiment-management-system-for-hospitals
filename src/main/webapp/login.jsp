<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/auth.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>Medical Appointment System</h1>
        </header>
        
        <main>
            <div class="auth-card">
                <h2>Login</h2>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <c:out value="${error}"/>
                    </div>
                </c:if>
                <c:if test="${param.registered == 'true'}">
                    <div class="alert alert-success">
                        Registration successful! Please login with your credentials.
                    </div>
                </c:if>
                <form action="login" method="POST" onsubmit="return validateForm()">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" value="${param.username}" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password" id="password" name="password" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="role">Login As</label>
                        <select id="role" name="role" required>
                            <option value="">Select Role</option>
                            <option value="PATIENT" ${param.role == 'PATIENT' ? 'selected' : ''}>Patient</option>
                            <option value="DOCTOR" ${param.role == 'DOCTOR' ? 'selected' : ''}>Doctor</option>
                            <option value="ADMIN" ${param.role == 'ADMIN' ? 'selected' : ''}>Admin</option>
                        </select>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Login</button>
                    </div>
                    
                    <div class="auth-links">
                        <a href="forgotPassword.jsp" class="forgot-password">Forgot Password?</a>
                        <a href="register.jsp" class="register-link">New User? Register</a>
                    </div>
                </form>
            </div>
        </main>
        
    </div>

    <script>
        function validateForm() {
            var username = document.getElementById("username").value;
            var password = document.getElementById("password").value;
            var role = document.getElementById("role").value;

            if (!username || !password || !role) {
                alert("Please fill in all fields!");
                return false;
            }

            return true;
        }
    </script>
</body>
</html>
 