from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity, unset_jwt_cookies
from datetime import datetime

app = Flask(__name__)

# Configure the app to use MySQL
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/finalyear'
app.config['JWT_SECRET_KEY'] = 'joel'  # Change this to something secure
db = SQLAlchemy(app)
jwt = JWTManager(app)

# Create Teacher and Student tables with additional 'name' field for Student
class Teacher(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    name = db.Column(db.String(100), nullable=False)  # Name field added
    teacher_code = db.Column(db.String(50), nullable=False)

    def __repr__(self):
        return f'<Teacher {self.email}>'

class Student(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    name = db.Column(db.String(100), nullable=False)  # Name field added
    department = db.Column(db.String(100), nullable=False)

    def __repr__(self):
        return f'<Student {self.email}>'

class Attendance(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.Integer, db.ForeignKey('student.id'), nullable=False)
    date = db.Column(db.Date, nullable=False)
    status = db.Column(db.String(50), nullable=False)  # 'Present' or 'Absent'

    def __repr__(self):
        return f'<Attendance {self.date} - {self.status}>'

# Initialize the database (only run once)
with app.app_context():
    db.create_all()

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    name = data.get('name')  # Name field handled here
    user_type = data.get('user_type')
    department = data.get('department')
    teacher_code = data.get('teacher_code')

    if not email or not password or not user_type:
        return jsonify(message="Email, password, and user type are required."), 400

    if user_type == 'Teacher':
        if not teacher_code:
            return jsonify(message="Teacher code is required for registration."), 400
        if Teacher.query.filter_by(email=email).first():
            return jsonify(message="Teacher with this email already exists."), 400

        new_teacher = Teacher(email=email, password=password, name=name, teacher_code=teacher_code)
        db.session.add(new_teacher)
        db.session.commit()
        return jsonify(message="Teacher registered successfully."), 201

    elif user_type == 'Student':
        if not department or not name:
            return jsonify(message="Name and department are required for student registration."), 400
        if Student.query.filter_by(email=email).first():
            return jsonify(message="Student with this email already exists."), 400

        new_student = Student(email=email, password=password, name=name, department=department)
        db.session.add(new_student)
        db.session.commit()
        return jsonify(message="Student registered successfully."), 201

    return jsonify(message="Invalid user type."), 400

@app.route('/login', methods=['POST'])
def login():
    email = request.json.get('email', None)
    password = request.json.get('password', None)

    teacher = Teacher.query.filter_by(email=email).first()
    if teacher and teacher.password == password:  # Direct password comparison
        access_token = create_access_token(identity=teacher.id)
        return jsonify(
            access_token=access_token,
            user_type="Teacher",
            email=teacher.email
        ), 200

    student = Student.query.filter_by(email=email).first()
    if student and student.password == password:  # Direct password comparison
        access_token = create_access_token(identity=student.id)
        return jsonify(
            access_token=access_token,
            user_type="Student",
            email=student.email,
            name=student.name,
            department=student.department
        ), 200

    return jsonify(message="Invalid credentials"), 401

@app.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    user_id = get_jwt_identity()
    # Updated to use db.session.get() instead of query.get()
    student = db.session.get(Student, user_id)
    teacher = db.session.get(Teacher, user_id)

    if student:
        return jsonify(
            email=student.email,
            name=student.name,
            department=student.department
        ), 200
    if teacher:
        return jsonify(
            email=teacher.email
        ), 200

    return jsonify(message="Invalid user or token."), 404

@app.route('/attendance_history', methods=['GET'])
@jwt_required()
def attendance_history():
    student_id = get_jwt_identity()
    student = db.session.get(Student, student_id)  # Updated to use db.session.get()

    if student:
        # Get the student's attendance records
        attendance_records = Attendance.query.filter_by(student_id=student.id).all()
        attendance_data = []
        for record in attendance_records:
            attendance_data.append({
                'date': record.date.strftime('%Y-%m-%d'),
                'status': record.status
            })
        return jsonify(attendance=attendance_data), 200

    return jsonify(message="Student not found or invalid token."), 404

@app.route('/mark_attendance', methods=['POST'])
@jwt_required()
def mark_attendance():
    student_id = get_jwt_identity()
    student = db.session.get(Student, student_id)  # Updated to use db.session.get()

    if not student:
        return jsonify(message="Student not found."), 404

    # Get today's date
    today_date = datetime.today().date()

    # Check if attendance has already been marked for today
    existing_attendance = Attendance.query.filter_by(student_id=student_id, date=today_date).first()

    if existing_attendance:
        return jsonify(message="Attendance already marked for today."), 400

    # Mark attendance as present ('Present')
    new_attendance = Attendance(student_id=student_id, date=today_date, status='Present')
    db.session.add(new_attendance)
    db.session.commit()

    return jsonify(message="Attendance marked as present for today."), 200

@app.route('/teacher/details', methods=['GET'])
@jwt_required()
def teacher_details():
    """
    Returns the details of the logged-in teacher.
    """
    teacher_id = get_jwt_identity()
    teacher = db.session.get(Teacher, teacher_id)  # Fetch the teacher from the database using the token's identity

    if teacher:
        return jsonify(
            id=teacher.id,
            email=teacher.email,
            teacher_code=teacher.teacher_code,
            name=teacher.name
        ), 200

    return jsonify(message="Teacher not found or invalid token."), 404

@app.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    response = jsonify(message="Logout successful")
    unset_jwt_cookies(response)
    return response, 200

if __name__ == '__main__':
    app.run(debug=True)
