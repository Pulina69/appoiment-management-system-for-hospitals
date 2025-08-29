package com.medical.servlet;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medical.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/changePassword")
public class ChangePasswordServlet extends HttpServlet {
    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("changePassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        User sessionUser = (User) session.getAttribute("user");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        if (!sessionUser.getPassword().equals(currentPassword)) {
            request.setAttribute("error", "Current password is incorrect.");
            request.getRequestDispatcher("changePassword.jsp").forward(request, response);
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "New passwords do not match.");
            request.getRequestDispatcher("changePassword.jsp").forward(request, response);
            return;
        }
        ObjectMapper mapper = new ObjectMapper();
        File file = new File(getUsersFilePath());
        List<User> users = new ArrayList<>();
        if (file.exists()) {
            users = mapper.readValue(file, new TypeReference<List<User>>() {});
        }
        for (User user : users) {
            if (user.getId().equals(sessionUser.getId())) {
                user.setPassword(newPassword);
                session.setAttribute("user", user);
                break;
            }
        }
        mapper.writerWithDefaultPrettyPrinter().writeValue(file, users);
        // Redirect to doctor profile if doctor, else profile.jsp
        if ("DOCTOR".equalsIgnoreCase(sessionUser.getRole())) {
            response.sendRedirect("viewDoctorProfile.jsp");
        } else {
            response.sendRedirect("profile.jsp");
        }
    }
}
