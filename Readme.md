# OOP Concepts Used System Project
Looking at the code you've shared, particularly the EditAppointmentServlet.java file, I can
identify several Object-Oriented Programming (OOP) concepts being used throughout the
project:
## 1. Encapsulation - **Data hiding**: Private methods like `getUsersFilePath()` and
`getAppointmentsFilePath()` hide implementation details - **Access control**: The class exposes only the necessary HTTP methods (`doGet` and
`doPost`) while keeping helper methods private - **Model classes**: Using proper model classes like `User` and `Appointment` to
encapsulate related data
## 2. Inheritance - **Servlet inheritance**: `EditAppointmentServlet` extends `HttpServlet`, inheriting core
servlet functionality - **Method overriding**: The class overrides `doGet()` and `doPost()` methods from the
parent class to provide specific implementations
## 3. Polymorphism - **Method overriding**: Different behavior implemented for the inherited methods
(`doGet` and `doPost`)
  `TypeReference<List<Appointment>>` to handle different model types with the same
  JSON parsing code
## 4. Abstraction - **Interface implementation**: The servlet implements interfaces defined by the Jakarta
EE specification - **Hiding complexity**: Complex file operations and JSON parsing are abstracted away
from the business logic - **Simplified API**: The servlet provides a clean HTTP interface for appointment editing
operations
## 5. Object Composition - **Model relationships**: The application uses object relationships between `User` and
`Appointment` classes - **Container objects**: Using collections like `List<User>` and `List<Appointment>` to
manage groups of related objects
## 6. Single Responsibility Principle - Each class has a specific responsibility: - `EditAppointmentServlet` handles HTTP requests for editing appointments - `User` and `Appointment` classes represent data models - `ObjectMapper` handles JSON serialization/deserialization
## 7. Design Patterns - **MVC Pattern**: The code separates: - Model (Appointment and User classes) - View (JSP files)
  The codebase demonstrates good OOP practices such as: - Proper separation of concerns - Clear class hierarchies - Encapsulated implementation details - Reusable components - Type safety through generics - Clean interfaces between components
  These OOP principles help make the application more maintainable, extensible, and
  robust.
  HOW TO USE  
  To run your JSP-based Medical Appointment System project with IntelliJ IDEA Ultimate and
  Tomcat, follow these detailed steps:
## Step 1: Install Prerequisites
1. **IntelliJ IDEA Ultimate** (Community Edition doesn't fully support JavaEE features)
2. **Apache Tomcat** (version 10.x or 9.x depending on your Jakarta EE/Java EE version)
3. **JDK** (version 11 or later recommended)
## Step 2: Configure Tomcat in IntelliJ
1. Open IntelliJ IDEA Ultimate
2. Go to **File → Settings → Build, Execution, Deployment → Application Servers**
3. Click the **+** button and select **Tomcat Server**
4. Browse to your Tomcat installation directory (should contain "bin", "conf", "lib" folders)
5. Click **OK** to save the server configuration
## Step 3: Open Your Project
1. Go to **File → Open**
2. Navigate to your project directory (v246)
3. Click **OK** to open the project
## Step 4: Verify Project Structure
1. Go to **File → Project Structure** (or press Ctrl+Alt+Shift+S)
2. Under **Project Settings → Project**, verify your JDK is correctly set
3. Under **Modules**, ensure your project is recognized as a Java Web application: - Module should have Web facet - Verify source folders are correctly marked - Check dependencies (especially Jakarta/JavaEE and JSON libraries)
## Step 5: Configure Run/Debug Configuration
1. Click on **Run → Edit Configurations**
2. Click the **+** button and select **Tomcat Server → Local**
3. Configure the server: - Name: `Tomcat for Medical Appointment System` - Application server: Select your Tomcat server - URL: `http://localhost:8080/v246_war_exploded/` - JRE: Select your JDK
4. Under the **Deployment** tab: - Click **+** and select **Artifact** - Choose `v246:war exploded` - Set Application context to `/v246_war_exploded`
5. Under the **Server** tab: - Adjust port settings if needed - Set "On 'Update' action" to "Update classes and resources" - Set "On frame deactivation" to "Update resources"
6. Click **OK** to save the configuration
## Step 6: Ensure JSON Files are Properly Deployed
1. Make sure your JSON data files are in the correct location:
``` 
/WEB-INF/classes/appointments.json 
/WEB-INF/classes/users.json 
/WEB-INF/classes/payment.json 
``` 
2. If not, add a step in your build process to copy them: - Go to **File → Project Structure → Artifacts** - Expand the `v246:war exploded` artifact - Right-click on `WEB-INF/classes` and select **Create Directory** - Name it `data` (optional, if you want a subfolder) - Right-click on the new directory and select **Add Copy of** - Navigate to your JSON files and add them
## Step 7: Run the Project
1. Click the **Run** button (green triangle) or press Shift+F10
2. Select your Tomcat configuration if prompted
3. IntelliJ will build the project, deploy it to Tomcat, and open your browser
## Step 8: Debug if Needed
If you encounter issues:
1. Check the IntelliJ console and Tomcat logs for errors
2. Use **Run → Debug** instead of Run for better error detection
3. Set breakpoints in your Java code to trace execution
4. For JSP errors, look at the browser's developer console and Tomcat logs
   USER LOGIN  
   ADMIN  
   username =a
   password=a
   DOCTOR
   Username=d  
   Password=d
   PATIENT
   Username=p
   Password=p
   This is mainly used user credentials when I was creating and testing this project  
   Thank you. 
# Appointment Management System for Hospital

## Overview
This project is a web-based Appointment Management System designed for hospitals. It allows patients to book, view, and manage appointments with doctors, while providing administrative features for hospital staff and doctors to manage schedules, users, and appointments.

## Features
- Patient registration and login
- Doctor registration and login
- Admin dashboard for managing users and appointments
- Book, edit, and cancel appointments
- View doctor profiles and availability
- Change and reset password functionality
- Payment processing for appointments
- Responsive user interface with JSP and CSS

## Technologies Used
- Java (Servlets, JSP)
- Jakarta EE
- Maven
- JSON for data storage
- HTML, CSS (custom styles)

## Project Structure
- `src/main/java/com/medical/` - Java source code (models, servlets, filters)
- `src/main/webapp/` - JSP pages and static resources
- `src/main/webapp/WEB-INF/` - Configuration files (web.xml)
- `target/` - Compiled classes and generated WAR file

## How to Run
1. **Build the project:**
   - Use Maven to build: `mvn clean package`
2. **Deploy the WAR file:**
   - Deploy `medical-appointment.war` from the `target/` directory to your servlet container (e.g., Apache Tomcat).
3. **Access the application:**
   - Open your browser and go to `http://localhost:8080/medical-appointment` (URL may vary based on your server configuration).

## Usage
- **Patients:** Register, log in, book appointments, view and edit profile, make payments.
- **Doctors:** Log in, view appointments, manage availability, edit profile.
- **Admins:** Manage users, doctors, appointments, and view system statistics.

## Data Storage
- User and appointment data are stored in JSON files under `WEB-INF/classes/`.

## Default User Credentials (for testing)
- **Admin:**
  - Username: `a`
  - Password: `a`
- **Doctor:**
  - Username: `d`
  - Password: `d`
- **Patient:**
  - Username: `p`
  - Password: `p`

## Authors
- [Your Name]

## License
This project is for educational purposes only.