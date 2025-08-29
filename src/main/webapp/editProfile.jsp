<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Profile - Medical Appointment System</title>
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
                    <li><a href="appointments">Appointments</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                    <li><a href="payment.jsp">payment</a></li>
                    <li><a href="login.jsp">Logout</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <div class="profile-card">
                <h2>Edit Profile</h2>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <c:out value="${error}"/>
                    </div>
                </c:if>
                <form action="editProfile" method="POST" onsubmit="return validateForm()">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" value="${sessionScope.user.username}" readonly>
                        <small>Username cannot be changed</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" value="${sessionScope.user.fullName}" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" value="${sessionScope.user.email}" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" value="${sessionScope.user.phone}" required>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                        <a href="profile" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </main>
        
    </div>
</body>
</html>
