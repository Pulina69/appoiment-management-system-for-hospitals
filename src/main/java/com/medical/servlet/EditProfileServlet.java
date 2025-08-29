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

@WebServlet("/editProfile")
public class EditProfileServlet extends HttpServlet {
    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("editProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        User sessionUser = (User) session.getAttribute("user");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        ObjectMapper mapper = new ObjectMapper();
        File file = new File(getUsersFilePath());
        List<User> users = new ArrayList<>();
        if (file.exists()) {
            users = mapper.readValue(file, new TypeReference<List<User>>() {});
        }
        for (User user : users) {
            if (user.getId().equals(sessionUser.getId())) {
                user.setFullName(fullName);
                user.setEmail(email);
                user.setPhone(phone);
                session.setAttribute("user", user);
                break;
            }
        }
        mapper.writerWithDefaultPrettyPrinter().writeValue(file, users);
        request.setAttribute("success", "Profile updated successfully.");
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}
