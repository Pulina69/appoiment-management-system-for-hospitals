<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctors - Medical Appointment System</title>
    <link rel="stylesheet" href="styles/main.css">
    <link rel="stylesheet" href="styles/dashboard.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>Medical Appointment System</h1>
            <nav>
                <ul>
                    <li><a href="dashboard.jsp">Dashboard</a></li>
                    <li><a href="userList">Users</a></li>
                    <li><a href="doctorList">Doctors</a></li>
                    <li><a href="login.jsp">Logout</a></li>
                </ul>
            </nav>
        </header>
        <main>
            <div class="page-header">
                <h2>Doctor Management</h2>
                <form method="get" action="doctorList" style="margin-top:16px;">
                    <input type="text" name="search" placeholder="Search by name" value="${param.search}"/>
                    <button type="submit" class="btn btn-primary">Search</button>
                </form>
            </div>
            <div class="doctors-list">
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Join Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="doctor" items="${doctors}">
                            <c:choose>
                                <c:when test="${empty param.search}">
                                    <tr>
                                        <td>${doctor.fullName}</td>
                                        <td>${doctor.email}</td>
                                        <td>${doctor.phone}</td>
                                        <td>${doctor.joinDate}</td>
                                    </tr>
                                </c:when>
                                <c:when test="${fn:containsIgnoreCase(doctor.fullName, param.search)}">
                                    <tr>
                                        <td>${doctor.fullName}</td>
                                        <td>${doctor.email}</td>
                                        <td>${doctor.phone}</td>
                                        <td>${doctor.joinDate}</td>
                                    </tr>
                                </c:when>
                            </c:choose>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>
