<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="com.google.gson.reflect.TypeToken" %>
<%@ page import="java.lang.reflect.Type" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payments - Medical Appointment System</title>
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
                    <li><a href="payment.jsp">payment</a></li>
                    <li><a href="login.jsp">Logout</a></li>
                </ul>
            </nav>
        </header>
        
        <main>
            <%
                // Get the logged in user
                String username = (String) session.getAttribute("username");
                if (username == null) {
                    response.sendRedirect("login.jsp");
                    return;
                }
                
                // Path to the payment.json file
                String paymentJsonPath = application.getRealPath("/WEB-INF/classes/payment.json");
                
                // Initialize variables
                List<Map<String, Object>> payments = new ArrayList<>();
                double totalPaid = 0.0;
                double pendingAmount = 0.0;
                Date lastPaymentDate = null;
                double lastPaymentAmount = 0.0;
                String errorMsg = null;
                
                try {
                    // Read the payment.json file
                    File paymentFile = new File(paymentJsonPath);
                    if (paymentFile.exists()) {
                        try (FileReader reader = new FileReader(paymentFile)) {
                            Gson gson = new Gson();
                            Type paymentListType = new TypeToken<ArrayList<Map<String, Object>>>(){}.getType();
                            payments = gson.fromJson(reader, paymentListType);
                            
                            // Filter payments for the current user
                            List<Map<String, Object>> userPayments = new ArrayList<>();
                            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
                            
                            for (Map<String, Object> payment : payments) {
                                if (payment.containsKey("patientUsername") && 
                                    payment.get("patientUsername").toString().equals(username)) {
                                    
                                    // Format date for display
                                    if (payment.containsKey("paymentDate") && payment.get("paymentDate") != null) {
                                        String dateStr = payment.get("paymentDate").toString();
                                        try {
                                            Date paymentDate = sdf.parse(dateStr);
                                            payment.put("date", paymentDate);
                                        } catch (ParseException e) {
                                            payment.put("date", new Date());
                                        }
                                    } else {
                                        payment.put("date", new Date());
                                    }
                                    
                                    // Calculate totals
                                    if (payment.containsKey("amount")) {
                                        double amount = 0.0;
                                        try {
                                            amount = Double.parseDouble(payment.get("amount").toString());
                                        } catch (NumberFormatException e) {
                                            continue;
                                        }
                                        
                                        if (payment.containsKey("status")) {
                                            String status = payment.get("status").toString();
                                            if ("PAID".equals(status)) {
                                                totalPaid += amount;
                                                
                                                // Check for last payment date
                                                Date paymentDate = (Date) payment.get("date");
                                                if (lastPaymentDate == null || paymentDate.after(lastPaymentDate)) {
                                                    lastPaymentDate = paymentDate;
                                                    lastPaymentAmount = amount;
                                                }
                                            } else if ("PENDING".equals(status)) {
                                                pendingAmount += amount;
                                            }
                                        }
                                    }
                                    
                                    userPayments.add(payment);
                                }
                            }
                            
                            // Sort payments by date (newest first)
                            Collections.sort(userPayments, new Comparator<Map<String, Object>>() {
                                @Override
                                public int compare(Map<String, Object> p1, Map<String, Object> p2) {
                                    Date date1 = (Date) p1.get("date");
                                    Date date2 = (Date) p2.get("date");
                                    return date2.compareTo(date1);
                                }
                            });
                            
                            payments = userPayments;
                        }
                    } else {
                        errorMsg = "Payment data file not found";
                    }
                } catch (Exception e) {
                    errorMsg = "Error loading payment data: " + e.getMessage();
                }
                
                // Set up pagination
                int pageSize = 10; 
                int totalRecords = payments.size();
                int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
                
                int currentPage = 1;
                String pageParam = request.getParameter("page");
                if (pageParam != null && !pageParam.isEmpty()) {
                    try {
                        currentPage = Integer.parseInt(pageParam);
                        if (currentPage < 1) currentPage = 1;
                        if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
                    } catch (NumberFormatException e) {
                        // Default to page 1
                    }
                }
                
                // Set variables for use in JSP
                pageContext.setAttribute("payments", payments);
                pageContext.setAttribute("totalPaid", totalPaid);
                pageContext.setAttribute("pendingAmount", pendingAmount);
                pageContext.setAttribute("lastPaymentDate", lastPaymentDate);
                pageContext.setAttribute("lastPaymentAmount", lastPaymentAmount);
                pageContext.setAttribute("error", errorMsg);
                pageContext.setAttribute("currentPage", currentPage);
                pageContext.setAttribute("totalPages", totalPages);
            %>
            
            <div class="payment-container">
                <div class="payment-header">
                    <h2>Payment History</h2>
                </div>

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

                <div class="payment-summary">
                    <div class="summary-card">
                        <h3>Total Paid</h3>
                        <p class="amount">$<fmt:formatNumber value="${totalPaid}" pattern="#,##0.00"/></p>
                    </div>
                    <div class="summary-card">
                        <h3>Pending Payments</h3>
                        <p class="amount">$<fmt:formatNumber value="${pendingAmount}" pattern="#,##0.00"/></p>
                    </div>
                    <div class="summary-card">
                        <h3>Last Payment</h3>
                        <p class="date"><fmt:formatDate value="${lastPaymentDate}" pattern="MMMM dd, yyyy"/></p>
                        <p class="amount">$<fmt:formatNumber value="${lastPaymentAmount}" pattern="#,##0.00"/></p>
                    </div>
            </div>
            
                <div class="payment-list">
                    <h3>Recent Payments</h3>
                    <c:if test="${empty payments}">
                        <p class="no-payments">No payment history found.</p>
                    </c:if>
                    <c:if test="${not empty payments}">
                        <div class="payment-table">
                <table>
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Invoice #</th>
                            <th>Description</th>
                            <th>Amount</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%-- Calculate start and end index for pagination --%>
                        <c:set var="pageSize" value="10" />
                        <c:set var="startIndex" value="${(currentPage-1) * pageSize}" />
                        <c:set var="endIndex" value="${startIndex + pageSize - 1}" />
                        <c:if test="${endIndex >= payments.size()}">
                            <c:set var="endIndex" value="${payments.size() - 1}" />
                        </c:if>
                        
                        <c:forEach items="${payments}" var="payment" begin="${startIndex}" end="${endIndex}">
                            <tr>
                                <td><fmt:formatDate value="${payment.date}" pattern="MMM dd, yyyy"/></td>
                                <td>${payment.invoiceNumber}</td>
                                <td>${payment.description}</td>
                                <td>$<fmt:formatNumber value="${payment.amount}" pattern="#,##0.00"/></td>
                                <td>
                                    <span class="status ${payment.status.toLowerCase()}">
                                        ${payment.status}
                                    </span>
                                </td>
                                <td>
                                    <div class="payment-actions">
                                        <c:if test="${payment.status eq 'PENDING'}">
                                            <a href="payNow.jsp?id=${payment.id}&amount=${payment.amount}&description=${payment.description}" class="btn btn-small btn-primary">Pay Now</a>
                                        </c:if>
                                        <c:if test="${payment.status eq 'PAID'}">
                                            <a href="paymentSuccess.jsp?transactionId=${payment.id}&paymentDate=<fmt:formatDate value="${payment.date}" pattern="MMMM dd, yyyy"/>&paymentMethod=${payment.paymentMethod}&amount=${payment.amount}" class="btn btn-small btn-secondary">View Receipt</a>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                        </div>

                        <c:if test="${totalPages > 1}">
                            <div class="pagination">
                                <c:if test="${currentPage > 1}">
                                    <a href="payment.jsp?page=${currentPage - 1}" class="btn btn-secondary">&laquo; Previous</a>
                                </c:if>

                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <a href="payment.jsp?page=${i}"
                                       class="btn ${currentPage == i ? 'btn-primary' : 'btn-secondary'}">${i}</a>
                                </c:forEach>

                                <c:if test="${currentPage < totalPages}">
                                    <a href="payment.jsp?page=${currentPage + 1}" class="btn btn-secondary">Next &raquo;</a>
                                </c:if>
                            </div>
                        </c:if>
                    </c:if>
                </div>
            </div>
        </main>

    </div>
</body>
</html>
