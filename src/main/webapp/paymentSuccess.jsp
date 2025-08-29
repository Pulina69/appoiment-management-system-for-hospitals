<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Success - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/payment.css">
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
            <div class="success-container">
                <div class="success-icon">
                    <svg width="100" height="100" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="50" cy="50" r="45" fill="#4CAF50" />
                        <path d="M30 50L45 65L70 35" stroke="white" stroke-width="6" stroke-linecap="round" stroke-linejoin="round" />
                    </svg>
                </div>
                
                <h2>Payment Successful!</h2>
                
                <div class="payment-details">
                    <p>Your payment has been processed successfully.</p>
                    <p>Transaction ID: <strong>${param.transactionId}</strong></p>
                    <p>Amount Paid: <strong>$<fmt:formatNumber value="${param.amount}" pattern="#,##0.00"/></strong></p>
                    <p>Date: <strong>${param.paymentDate}</strong></p>
                    <p>Payment Method: <strong>${param.paymentMethod}</strong></p>
                </div>
                
                <div class="actions">
                    <a href="appointments.jsp" class="btn btn-primary">Back to Appointments</a>
                    <a href="payment.jsp" class="btn btn-secondary">View All Payments</a>
                </div>
            </div>
        </main>
        
        <footer>
            <p>&copy; 2025 Medical Appointment System</p>
        </footer>
    </div>
    
    <style>
        .success-container {
            max-width: 600px;
            margin: 50px auto;
            padding: 30px;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        
        .success-icon {
            margin: 20px auto;
        }
        
        .payment-details {
            margin: 30px auto;
            padding: 20px;
            background-color: #f9f9f9;
            border-radius: 6px;
            text-align: left;
        }
        
        .actions {
            margin-top: 30px;
        }
        
        .actions a {
            margin: 0 10px;
        }
        
        h2 {
            color: #4CAF50;
        }
    </style>
</body>
</html>