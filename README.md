# Student Attendance Management System

This is a mobile application developed using **Flutter** for managing student attendance. The app allows students to log in, view their profile, and mark their attendance by scanning QR codes. It integrates with a **Flask** backend to handle authentication and attendance data.

## Features
- **Login System**: Secure login using email and password.
- **QR Code Scanning**: Students can mark their attendance by scanning a QR code.
- **Attendance Dashboard**: Students can view their attendance details and track attendance trends.
- **User Authentication**: The system uses JWT (JSON Web Tokens) for secure user authentication.
- **Responsive UI**: Designed to work across different screen sizes using **Flutter**.

## Technologies Used
- **Frontend**: 
  - **Flutter**: Cross-platform mobile app framework.
  - **fl_chart**: For visualizing attendance data in graphs.
  - **shared_preferences**: For storing and retrieving JWT tokens.
  - **flutter_barcode_scanner**: For scanning QR codes.
  
- **Backend**:
  - **Flask**: Lightweight Python web framework.
  - **JWT**: For secure user authentication.
  - **SQLite/MySQL**: Database for storing user and attendance data.

## Setup & Installation

### Prerequisites
- **Flutter**: [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart**: [Install Dart](https://dart.dev/get-dart)
- **Python**: [Install Python](https://www.python.org/downloads/)
- **Flask**: Install Flask and other Python dependencies via `pip`.

### Flutter (Frontend) Setup
1. Clone this repository to your local machine:
    ```bash
    git clone https://github.com/yourusername/student-attendance-system.git
    cd student-attendance-system
    ```

2. Install the required Flutter dependencies:
    ```bash
    flutter pub get
    ```

3. To run the app on an emulator or device:
    ```bash
    flutter run
    ```

### Flask (Backend) Setup
1. Clone the backend repository (or navigate to your backend folder).
    ```bash
    git clone https://github.com/yourusername/attendance-backend.git
    cd attendance-backend
    ```

2. Set up a Python virtual environment:
    ```bash
    python -m venv venv
    source venv/bin/activate  # For Windows use venv\Scripts\activate
    ```

3. Install required Python libraries:
    ```bash
    pip install -r requirements.txt
    ```

4. Run the Flask server:
    ```bash
    python app.py
    ```

   The backend will be running at `http://127.0.0.1:5000`.

### Environment Variables
You need to set the following environment variables for secure operations:
- **JWT_SECRET_KEY**: A secret key for signing JWT tokens.
- **DATABASE_URL**: The URL for the database connection.

### Database Setup
Set up the database schema by running the following command in the Flask app folder:
```bash
flask db upgrade

### For Docker 
you can follow this steps
- docker-compose up --build
    - access frontEnd by [http://localhost:8080]
    - access backEnd by [http://localhost:8000]