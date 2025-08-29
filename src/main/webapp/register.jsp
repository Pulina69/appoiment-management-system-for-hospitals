<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/auth.css">
    <link rel="stylesheet" href="styles/forms.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>Medical Appointment System</h1>
        </header>
        
        <main>
            <div class="auth-card">
                <h2>Register</h2>
                
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

                <form action="register" method="POST" onsubmit="return validateForm()">
                    <div class="form-group">
                        <label for="username">Username:</label>
                        <input type="text" id="username" name="username" value="${param.username}" required>
                    </div>

                    <div class="form-group">
                        <label for="fullName">Full Name:</label>
                        <input type="text" id="fullName" name="fullName" value="${param.fullName}" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email" value="${param.email}" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="phone">Phone Number:</label>
                        <input type="tel" id="phone" name="phone" value="${param.phone}" required pattern="[0-9]{10}">
                    </div>
                    
                    <div class="form-group">
                        <label for="role">Role:</label>
                        <select id="role" name="role" required>
                            <option value="">Select Role</option>
                            <option value="PATIENT" <c:if test="${param.role == 'PATIENT'}">selected</c:if>>Patient</option>
                            <option value="DOCTOR" <c:if test="${param.role == 'DOCTOR'}">selected</c:if>>Doctor</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="password">Password:</label>
                        <div style="position:relative;width:100%;max-width:400px;">
                            <input type="password" id="password" name="password" required style="width:100%;padding-right:38px;">
                            <button type="button" class="show-password-btn" onclick="togglePassword('password', this)" style="position:absolute;right:6px;top:50%;transform:translateY(-50%);padding:2px 8px;font-size:16px;cursor:pointer;background:none;border:none;outline:none;">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                        <small>Password must be at least 8 characters long and include a mix of letters, numbers, and symbols.</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="confirmPassword">Confirm Password:</label>
                        <div style="position:relative;width:100%;max-width:400px;">
                            <input type="password" id="confirmPassword" name="confirmPassword" required style="width:100%;padding-right:38px;">
                            <button type="button" class="show-password-btn" onclick="togglePassword('confirmPassword', this)" style="position:absolute;right:6px;top:50%;transform:translateY(-50%);padding:2px 8px;font-size:16px;cursor:pointer;background:none;border:none;outline:none;">
                                <i class="bi bi-eye"></i>
                            </button>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Register</button>
                    </div>
                    
                    <div class="auth-links">
                        <a href="login.jsp">Already have an account? Login</a>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <script>
        function validateForm() {
            var password = document.getElementById("password").value;
            var confirmPassword = document.getElementById("confirmPassword").value;
            var username = document.getElementById("username").value;
            var email = document.getElementById("email").value;
            var phone = document.getElementById("phone").value;
            var role = document.getElementById("role").value;

            // Check if passwords match
            if (password !== confirmPassword) {
                alert("Passwords do not match!");
                return false;
            }
            
            // Check password strength
            if (password.length < 8) {
                alert("Password must be at least 8 characters long!");
                return false;
            }

            // Check if all fields are filled
            if (!username || !email || !phone || !role) {
                alert("All fields are required!");
                return false;
            }

            // Email validation
            var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                alert("Please enter a valid email address!");
                return false;
            }

            // Phone validation
            var phoneRegex = /^\d{10}$/;
            if (!phoneRegex.test(phone)) {
                alert("Please enter a valid 10-digit phone number!");
                return false;
            }

            return true;
        }

        function togglePassword(fieldId, btn) {
            var input = document.getElementById(fieldId);
            var icon = btn.querySelector('i');
            if (input.type === "password") {
                input.type = "text";
                icon.classList.remove('bi-eye');
                icon.classList.add('bi-eye-slash');
            } else {
                input.type = "password";
                icon.classList.remove('bi-eye-slash');
                icon.classList.add('bi-eye');
            }
        }
    </script>
</body>
</html>
