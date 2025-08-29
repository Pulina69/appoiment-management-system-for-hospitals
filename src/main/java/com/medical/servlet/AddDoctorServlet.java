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

@WebServlet("/addDoctor")
public class AddDoctorServlet extends HttpServlet {
    private String getUsersFilePath() {
        return getServletContext().getRealPath("/WEB-INF/classes/users.json");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Example: set specializations for dropdown
        List<String> specializations = List.of("Cardiology", "Dermatology", "Neurology", "Pediatrics", "General Medicine");
        request.setAttribute("specializations", specializations);
        request.getRequestDispatcher("addDoctor.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String specialization = request.getParameter("specialization");
        String qualification = request.getParameter("qualification");
        String experience = request.getParameter("experience");
        String joinDate = java.time.LocalDate.now().toString();
        String id = String.valueOf(System.currentTimeMillis());

        ObjectMapper mapper = new ObjectMapper();
        File file = new File(getUsersFilePath());
        List<User> users = new ArrayList<>();
        if (file.exists()) {
            users = mapper.readValue(file, new TypeReference<List<User>>() {});
        }
        for (User u : users) {
            if (u.getUsername().equalsIgnoreCase(username) || u.getEmail().equalsIgnoreCase(email)) {
                request.setAttribute("error", "Username or email already exists.");
                doGet(request, response);
                return;
            }
        }
        User user = new User();
        user.setId(id);
        user.setUsername(username);
        user.setPassword(password);
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole("DOCTOR");
        user.setJoinDate(joinDate);
        user.setStatus("ACTIVE");
        // Optionally: set specialization, qualification, experience as custom fields or in address/notes
        users.add(user);
        mapper.writerWithDefaultPrettyPrinter().writeValue(file, users);
        response.sendRedirect("doctorList");
    }
}
