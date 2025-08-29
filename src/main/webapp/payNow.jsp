<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.io.*, java.util.*, java.text.SimpleDateFormat, com.google.gson.Gson, com.google.gson.reflect.TypeToken" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pay Now - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/payment.css">
    <link rel="stylesheet" href="styles/forms.css">
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
        
        // Get parameters
        String appointmentId = request.getParameter("appointmentId");
        String paymentId = request.getParameter("id");
        
        // Variables for payment details
        Map<String, Object> paymentDetails = new HashMap<>();
        Map<String, Object> appointmentDetails = new HashMap<>();
        double amount = 0.0;
        String description = "";
        String invoiceNumber = "";
        Date paymentDate = new Date();
        
        try {
            if (appointmentId != null && !appointmentId.isEmpty()) {
                // Get appointment details from JSON
                String appointmentsJsonPath = application.getRealPath("/WEB-INF/classes/appointments.json");
                String paymentJsonPath = application.getRealPath("/WEB-INF/classes/payment.json");
                Gson gson = new Gson();
                
                // Read appointments
                try (FileReader reader = new FileReader(appointmentsJsonPath)) {
                    List<Map<String, Object>> appointments = gson.fromJson(reader, 
                        new TypeToken<List<Map<String, Object>>>(){}.getType());
                    
                    // Find the specific appointment
                    for (Map<String, Object> appointment : appointments) {
                        String id = appointment.get("id").toString();
                        if (id.equals(appointmentId)) {
                            appointmentDetails = appointment;
                            
                            // Basic payment details from appointment
                            description = "Payment for appointment with " + appointment.get("doctorName");
                            // Set a default amount based on doctor or service
                            amount = 100.00; // Default amount
                            
                            // Generate a random invoice number if needed
                            invoiceNumber = "INV-" + System.currentTimeMillis();
                            break;
                        }
                    }
                    
                    // If no appointment found
                    if (appointmentDetails.isEmpty()) {
                        request.setAttribute("error", "Appointment not found.");
                    }
                }
                
                // Look for existing payment record for this appointment
                try (FileReader reader = new FileReader(paymentJsonPath)) {
                    List<Map<String, Object>> payments = gson.fromJson(reader, 
                        new TypeToken<List<Map<String, Object>>>(){}.getType());
                    
                    for (Map<String, Object> payment : payments) {
                        if (payment.get("appointmentId") != null && 
                            payment.get("appointmentId").toString().equals(appointmentId)) {
                            paymentDetails = payment;
                            
                            // Override with actual payment details
                            if (payment.get("amount") != null) {
                                if (payment.get("amount") instanceof Double) {
                                    amount = (Double) payment.get("amount");
                                } else {
                                    amount = Double.parseDouble(payment.get("amount").toString());
                                }
                            }
                            
                            description = payment.get("description") != null ? 
                                payment.get("description").toString() : description;
                            
                            invoiceNumber = payment.get("id") != null ? 
                                payment.get("id").toString() : invoiceNumber;
                            
                            if (payment.get("paymentDate") != null) {
                                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                                try {
                                    paymentDate = sdf.parse(payment.get("paymentDate").toString());
                                } catch (Exception e) {
                                    // Use current date if parsing fails
                                }
                            }
                            
                            break;
                        }
                    }
                }
            } else if (paymentId != null && !paymentId.isEmpty()) {
                // Get payment details directly
                String paymentJsonPath = application.getRealPath("/WEB-INF/classes/payment.json");
                Gson gson = new Gson();
                
                try (FileReader reader = new FileReader(paymentJsonPath)) {
                    List<Map<String, Object>> payments = gson.fromJson(reader, 
                        new TypeToken<List<Map<String, Object>>>(){}.getType());
                    
                    for (Map<String, Object> payment : payments) {
                        if (payment.get("id").toString().equals(paymentId)) {
                            paymentDetails = payment;
                            
                            // Get payment details
                            if (payment.get("amount") != null) {
                                if (payment.get("amount") instanceof Double) {
                                    amount = (Double) payment.get("amount");
                                } else {
                                    amount = Double.parseDouble(payment.get("amount").toString());
                                }
                            }
                            
                            description = payment.get("description") != null ? 
                                payment.get("description").toString() : "Medical Service Payment";
                            
                            invoiceNumber = payment.get("id") != null ? 
                                payment.get("id").toString() : paymentId;
                            
                            if (payment.get("appointmentId") != null) {
                                appointmentId = payment.get("appointmentId").toString();
                            }
                            
                            if (payment.get("paymentDate") != null) {
                                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                                try {
                                    paymentDate = sdf.parse(payment.get("paymentDate").toString());
                                } catch (Exception e) {
                                    // Use current date if parsing fails
                                }
                            }
                            
                            break;
                        }
                    }
                    
                    // If no payment found
                    if (paymentDetails.isEmpty()) {
                        request.setAttribute("error", "Payment record not found.");
                    }
                }
            } else {
                // No valid ID provided
                request.setAttribute("error", "No payment or appointment ID provided.");
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error loading payment details: " + e.getMessage());
        }
        
        // Set attributes for JSP
        request.setAttribute("payment", paymentDetails);
        request.setAttribute("appointment", appointmentDetails);
        request.setAttribute("amount", amount);
        request.setAttribute("description", description);
        request.setAttribute("invoiceNumber", invoiceNumber);
        request.setAttribute("paymentDate", paymentDate);
        request.setAttribute("appointmentId", appointmentId);
        request.setAttribute("paymentId", paymentId);
    %>
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
            <div class="payment-form-container">
                <h2>Make Payment</h2>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <c:out value="${error}"/>
                    </div>
                </c:if>
            
                <div class="payment-details">
                    <div class="detail-card">
                        <h3>Payment Details</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <label>Invoice Number</label>
                                <p>${invoiceNumber}</p>
                            </div>
                            <div class="detail-item">
                                <label>Date</label>
                                <p><fmt:formatDate value="${paymentDate}" pattern="MMMM dd, yyyy"/></p>
                            </div>
                            <div class="detail-item">
                                <label>Description</label>
                                <p>${description}</p>
                            </div>
                            <div class="detail-item">
                                <label>Amount</label>
                                <p class="amount">$<fmt:formatNumber value="${amount}" pattern="#,##0.00"/></p>
                            </div>
                            <c:if test="${not empty appointment}">
                                <div class="detail-item">
                                    <label>Doctor</label>
                                    <p>${appointment.doctorName}</p>
                                </div>
                                <div class="detail-item">
                                    <label>Appointment Date</label>
                                    <p>${appointment.date} ${appointment.time}</p>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
                
                <form action="processPayment" method="POST" onsubmit="return validateForm()">
                    <c:if test="${not empty paymentId}">
                        <input type="hidden" name="paymentId" value="${paymentId}">
                    </c:if>
                    <c:if test="${not empty appointmentId}">
                        <input type="hidden" name="appointmentId" value="${appointmentId}">
                    </c:if>
                    <input type="hidden" name="amount" value="${amount}">
                    <input type="hidden" name="invoiceNumber" value="${invoiceNumber}">
                    <input type="hidden" name="description" value="${description}">
                    
                    <div class="form-section">
                        <h3>Payment Method</h3>
                        
                        <div class="payment-methods">
                            <div class="payment-method">
                                <input type="radio" id="creditCard" name="paymentMethod" value="CREDIT_CARD" checked>
                                <label for="creditCard">Credit Card</label>
                            </div>
                            <div class="payment-method">
                                <input type="radio" id="debitCard" name="paymentMethod" value="DEBIT_CARD">
                                <label for="debitCard">Debit Card</label>
                            </div>
                        </div>
                        
                        <div id="cardDetails" class="payment-details-section">
                        <div class="form-group">
                                <label for="cardNumber">Card Number</label>
                                <input type="text" id="cardNumber" name="cardNumber" 
                                       placeholder="Enter card number" maxlength="19">
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group">
                                    <label for="expiryDate">Expiry Date</label>
                                    <input type="text" id="expiryDate" name="expiryDate" 
                                           placeholder="MM/YY" maxlength="5">
                                </div>

                                <div class="form-group">
                                    <label for="cvv">CVV</label>
                                    <input type="password" id="cvv" name="cvv" 
                                           placeholder="CVV" maxlength="4">
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="cardName">Name on Card</label>
                                <input type="text" id="cardName" name="cardName" 
                                       placeholder="Enter name as it appears on card">
                            </div>
                        </div>


                    </div>

                    <div class="form-section">
                        <h3>Billing Address</h3>
                        
                        <div class="form-group">
                            <label for="billingAddress">Address</label>
                            <textarea id="billingAddress" name="billingAddress" rows="3" required
                                      placeholder="Enter billing address">
                                <c:out value="${user.address}"/>
                            </textarea>
                        </div>
                        </div>
                        
                        <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Pay $<fmt:formatNumber value="${amount}" pattern="#,##0.00"/></button>
                        <a href="appointments.jsp" class="btn btn-secondary">Cancel</a>
                        </div>
                    </form>
            </div>
        </main>
        
    </div>

    <script>
        // Initialize with the default payment method
        window.addEventListener('DOMContentLoaded', function() {
            // Credit Card is the default payment option
            document.getElementById('cardDetails').style.display = 'block';
        });

        // Handle payment method selection - only credit/debit cards available
        document.querySelectorAll('input[name="paymentMethod"]').forEach(function(radio) {
            radio.addEventListener('change', function() {
                // Always show card details as it's the only option
                document.getElementById('cardDetails').style.display = 'block';
            });
        });

        // Format card number with spaces
        document.getElementById('cardNumber').addEventListener('input', function(e) {
            var value = e.target.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
            var formattedValue = '';
            for (var i = 0; i < value.length; i++) {
                if (i > 0 && i % 4 === 0) {
                    formattedValue += ' ';
                }
                formattedValue += value[i];
            }
            e.target.value = formattedValue;
        });

        // Format expiry date
        document.getElementById('expiryDate').addEventListener('input', function(e) {
            var value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2);
            }
            e.target.value = value;
        });
        
        // Validate form before submission
        function validateForm() {
            var paymentMethod = document.querySelector('input[name="paymentMethod"]:checked').value;
            var isValid = true;
            var billingAddress = document.getElementById('billingAddress').value;
            
            // Clear previous error messages
            document.querySelectorAll('.error-message').forEach(function(el) {
                el.remove();
            });
            
            // Validate billing address
            if (!billingAddress.trim()) {
                alert('Billing address is required!');
                return false;
            }
            
            // All payment methods are card-based (credit or debit)
            var cardNumber = document.getElementById('cardNumber').value;
            var cardName = document.getElementById('cardName').value;
            var expiryDate = document.getElementById('expiryDate').value;
            var cvv = document.getElementById('cvv').value;
            
            // Validate card number (should be 16-19 digits)
            if (!/^[0-9 ]{15,19}$/.test(cardNumber.replace(/\s/g, ''))) {
                showError('cardNumber', 'Please enter a valid card number');
                isValid = false;
            }
            
            // Validate name (should not be empty)
            if (!cardName.trim()) {
                showError('cardName', 'Please enter the name on card');
                isValid = false;
            }
            
            // Validate expiry date (MM/YY format)
            if (!/^(0[1-9]|1[0-2])\/([0-9]{2})$/.test(expiryDate)) {
                showError('expiryDate', 'Please enter a valid expiry date (MM/YY)');
                isValid = false;
            }
            
            // Validate CVV (3-4 digits)
            if (!/^[0-9]{3,4}$/.test(cvv)) {
                showError('cvv', 'Please enter a valid CVV');
                isValid = false;
            }
            
            return isValid;
        }
        
        function showError(fieldId, message) {
            var field = document.getElementById(fieldId);
            var errorDiv = document.createElement('div');
            errorDiv.className = 'error-message';
            errorDiv.innerHTML = message;
            errorDiv.style.color = 'red';
            errorDiv.style.fontSize = '12px';
            errorDiv.style.marginTop = '5px';
            
            field.parentNode.appendChild(errorDiv);
            field.style.borderColor = 'red';
        }
    </script>
</body>
</html>
