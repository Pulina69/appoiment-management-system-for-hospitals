<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/auth.css">
    <style>
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 4px;
        }
        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        .alert-danger {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        .reset-info {
            margin-top: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 4px;
        }
        #countdown {
            font-weight: bold;
            color: #155724;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Medical Appointment System</h1>
        </header>
        
        <main>
            <div class="auth-card">
                <h2>Forgot Password</h2>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <c:out value="${error}"/>
                    </div>
                </c:if>
                
                <c:if test="${not empty success}">
                    <div class="alert alert-success">
                        <c:out value="${success}"/>
                        <c:if test="${not empty resetPassword}">
                            <div class="form-group" style="margin-top:16px;">
                                <label for="resetPassword">Your Password</label>
                                <div style="position:relative;width:100%;max-width:400px;">
                                    <input type="password" id="resetPassword" value="${resetPassword}" readonly style="width:100%;padding-right:38px;">
                                    <button type="button" class="show-password-btn" onclick="togglePassword('resetPassword', this)" style="position:absolute;right:6px;top:50%;transform:translateY(-50%);padding:2px 8px;font-size:16px;cursor:pointer;background:none;border:none;outline:none;">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                </div>
                                <small>Password will be visible for 5 seconds.</small>
                            </div>
                            <p>Redirecting to login page in <span id="countdown">5</span> seconds...</p>
                        </c:if>
                        <c:if test="${empty resetPassword}">
                            <p>Redirecting to login page in <span id="countdown">10</span> seconds...</p>
                        </c:if>
                    </div>
                </c:if>
                
                <c:if test="${empty success}">
                <form action="forgotPassword" method="POST" onsubmit="return validateForm()">
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" value="${param.email}" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="role">Role</label>
                        <select id="role" name="role" required>
                            <option value="">Select Role</option>
                            <option value="PATIENT" <c:if test="${param.role == 'PATIENT'}">selected</c:if>>Patient</option>
                            <option value="DOCTOR" <c:if test="${param.role == 'DOCTOR'}">selected</c:if>>Doctor</option>
                            <option value="ADMIN" <c:if test="${param.role == 'ADMIN'}">selected</c:if>>Admin</option>
                        </select>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Reset Password</button>
                    </div>
                    
                    <div class="auth-links">
                        <a href="login.jsp">Back to Login</a>
                    </div>
                </form>
                
                <div class="reset-info">
                        <p>Enter your registered email and role to retrieve your password.</p>
                        <p>For security reasons, please change your password after logging in.</p>
                </div>
                </c:if>
            </div>
        </main>
    </div>

    <script>
        function validateForm() {
            var email = document.getElementById("email").value;
            var role = document.getElementById("role").value;

            if (!email || !role) {
                alert("Please fill in all fields!");
                return false;
            }

            // Email validation
            var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                alert("Please enter a valid email address!");
                return false;
            }

            return true;
        }

        // Countdown and redirect
        var resetPassword = "${not empty resetPassword}";
        var success = "${not empty success}";
        if (resetPassword === "true") {
            var countdown = 5;
            var countdownElement = document.getElementById('countdown');
            
            var timer = setInterval(function() {
                countdown--;
                countdownElement.textContent = countdown;
                
                if (countdown <= 0) {
                    clearInterval(timer);
                    window.location.href = 'login.jsp';
                }
            }, 1000);
        } else if (success === "true") {
            var countdown = 10;
            var countdownElement = document.getElementById('countdown');
            
            var timer = setInterval(function() {
                countdown--;
                countdownElement.textContent = countdown;
                
                if (countdown <= 0) {
                    clearInterval(timer);
                    window.location.href = 'login.jsp';
                }
            }, 1000);
        }

        // Show password for only 5 seconds
        function togglePassword(fieldId, btn) {
            var input = document.getElementById(fieldId);
            var icon = btn.querySelector('i');
            if (input.type === "password") {
                input.type = "text";
                icon.classList.remove('bi-eye');
                icon.classList.add('bi-eye-slash');
                btn.disabled = true;
                setTimeout(function() {
                    input.type = "password";
                    icon.classList.remove('bi-eye-slash');
                    icon.classList.add('bi-eye');
                    btn.disabled = false;
                }, 5000);
            }
        }
    </script>
</body>
</html>
