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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/userList")
public class UserListServlet extends HttpServlet {
    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ObjectMapper mapper = new ObjectMapper();
        File file = new File(getUsersFilePath());
        List<User> users = new ArrayList<>();
        if (file.exists()) {
            users = mapper.readValue(file, new TypeReference<List<User>>() {});
        }
        // Only show patients in user list
        List<User> patients = new ArrayList<>();
        for (User user : users) {
            if ("PATIENT".equalsIgnoreCase(user.getRole())) {
                patients.add(user);
            }
        }
        request.setAttribute("users", patients);
        request.getRequestDispatcher("userList.jsp").forward(request, response);
    }
}