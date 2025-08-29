package com.medical.servlet;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medical.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.util.List;

@WebServlet("/forgotPassword")
public class ForgotPasswordServlet extends HttpServlet {
    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String role = request.getParameter("role");
        ObjectMapper mapper = new ObjectMapper();
        File file = new File(getUsersFilePath());
        List<User> users = mapper.readValue(file, new TypeReference<List<User>>() {});
        for (User user : users) {
            if (user.getEmail().equalsIgnoreCase(email) && user.getRole().equalsIgnoreCase(role)) {
                request.setAttribute("success", "Your password is: " + user.getPassword());
                request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
                return;
            }
        }
        request.setAttribute("error", "No user found with that email and role.");
        request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
    }
}