package com.medical.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.*;
import java.time.LocalDate;
import java.util.List;
import java.util.ArrayList;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.medical.model.User;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Get form data
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");

        // Validate input
        if (!validateInput(username, password, confirmPassword, fullName, email, phone, role)) {
            request.setAttribute("error", "Please fill in all fields correctly");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Path to users.json in WEB-INF/classes
        String resourcePath = getUsersFilePath();
        File userFile = new File(resourcePath);
        ObjectMapper mapper = new ObjectMapper();
        List<User> users = new ArrayList<>();
        if (userFile.exists()) {
            try (FileInputStream fis = new FileInputStream(userFile)) {
                users = mapper.readValue(fis, new TypeReference<List<User>>() {});
            }
        } else {
            userFile.createNewFile();
        }

        // Check if user already exists
        for (User u : users) {
            if (u.getUsername().equals(username) || u.getEmail().equals(email)) {
                request.setAttribute("error", "User with this username or email already exists");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
        }

        // Create user object
        User user = new User(username, password, fullName, email, phone, role, LocalDate.now().toString());
        user.setId(String.valueOf(System.currentTimeMillis()));
        user.setDateOfBirth("");
        user.setAddress("");
        users.add(user);

        // Write back to users.json
        try (FileOutputStream fos = new FileOutputStream(userFile)) {
            mapper.writerWithDefaultPrettyPrinter().writeValue(fos, users);
        } catch (IOException e) {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Redirect to login page with success message
        response.sendRedirect("login.jsp?registered=true");
    }

    private boolean validateInput(String username, String password, String confirmPassword,
                                String fullName, String email, String phone, String role) {
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty() ||
            fullName == null || fullName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            role == null || role.trim().isEmpty()) {
            return false;
        }
        if (!password.equals(confirmPassword)) {
            return false;
        }
        if (password.length() < 8) {
            return false;
        }
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            return false;
        }
        if (!phone.matches("\\d{10}")) {
            return false;
        }
        return true;
    }
}