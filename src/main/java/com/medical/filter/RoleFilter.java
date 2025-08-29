package com.medical.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/patient/*", "/doctor/*", "/admin/*"})
public class RoleFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        // Get the requested URL path
        String requestPath = httpRequest.getRequestURI();
        
        // Check if user is logged in
        if (session == null || session.getAttribute("username") == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp");
            return;
        }

        // Get user's role from session
        String userRole = (String) session.getAttribute("role");
        
        // Check if user has access to the requested path
        if (!hasAccess(userRole, requestPath)) {
            // Redirect to appropriate error page or dashboard
            switch (userRole) {
                case "PATIENT":
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "profile.jsp");
                    break;
                case "DOCTOR":
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "viewDoctorProfile.jsp");
                    break;
                case "ADMIN":
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "dashboard.jsp");
                    break;
                default:
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "login.jsp");
            }
            return;
        }

        // If user has access, continue with the request
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup code if needed
    }

    private boolean hasAccess(String userRole, String requestPath) {
        if (userRole == null) {
            return false;
        }

        // Define access rules for each role
        switch (userRole) {
            case "PATIENT":
                return requestPath.contains("/PATIENT/");
            case "DOCTOR":
                return requestPath.contains("/DOCTOR/");
            case "ADMIN":
                return requestPath.contains("/ADMIN/");
            default:
                return false;
        }
    }
}