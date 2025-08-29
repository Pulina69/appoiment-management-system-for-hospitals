package com.medical.servlet;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medical.model.User;
import com.medical.model.TempUser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.List;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        ObjectMapper mapper = new ObjectMapper();
        File file = new File(getUsersFilePath());
        List<User> users = mapper.readValue(file, new TypeReference<List<User>>() {});
        for (User user : users) {
            if (user.getUsername().equalsIgnoreCase(username)
                    && user.getPassword().equals(password)
                    && user.getRole().equalsIgnoreCase(role)) {
                HttpSession session = request.getSession();
                session.setAttribute("username", user.getUsername());
                session.setAttribute("role", user.getRole());
                session.setAttribute("user", user);
                // Store TempUser in session for the duration of the project
                TempUser tempUser = new TempUser(user);
                session.setAttribute("tempUser", tempUser);
                // Redirect by role
                if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect("dashboard.jsp");

                } else if ("DOCTOR".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect("viewDoctorProfile.jsp");
                } else {
                    response.sendRedirect("profile.jsp");
                }
                return;
            }
        }
        request.setAttribute("error", "Invalid credentials or role.");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}