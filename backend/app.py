from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity, unset_jwt_cookies

app = Flask(__name__)

# Configure the app to use MySQL
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/finalyear'
app.config['JWT_SECRET_KEY'] = 'joel'  # Change this to something secure
db = SQLAlchemy(app)
jwt = JWTManager(app)

# Create Teacher and Student tables with email and password
class Teacher(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    teacher_code = db.Column(db.String(50), nullable=False)

    def __repr__(self):
        return f'<Teacher {self.email}>'

class Student(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    department = db.Column(db.String(100), nullable=False)

    def __repr__(self):
        return f'<Student {self.email}>'

# Initialize the database (only run once)
with app.app_context():
    db.create_all()

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    user_type = data.get('user_type')
    department = data.get('department')
    teacher_code = data.get('teacher_code')

    # Check for required fields
    if not email or not password or not user_type:
        return jsonify(message="Email, password, and user type are required."), 400

    # Register as Teacher
    if user_type == 'Teacher':
        if not teacher_code:
            return jsonify(message="Teacher code is required for registration."), 400
        if Teacher.query.filter_by(email=email).first():
            return jsonify(message="Teacher with this email already exists."), 400

        new_teacher = Teacher(email=email, password=password, teacher_code=teacher_code)
        db.session.add(new_teacher)
        db.session.commit()
        return jsonify(message="Teacher registered successfully."), 201

    # Register as Student
    elif user_type == 'Student':
        if not department:
            return jsonify(message="Department is required for student registration."), 400
        if Student.query.filter_by(email=email).first():
            return jsonify(message="Student with this email already exists."), 400

        new_student = Student(email=email, password=password, department=department)
        db.session.add(new_student)
        db.session.commit()
        return jsonify(message="Student registered successfully."), 201

    # Invalid user type
    return jsonify(message="Invalid user type."), 400

# Login route
@app.route('/login', methods=['POST'])
def login():
    email = request.json.get('email', None)
    password = request.json.get('password', None)

    # Try to find the user as a teacher first
    teacher = Teacher.query.filter_by(email=email).first()
    if teacher and teacher.password == password:
        access_token = create_access_token(identity=teacher.id)
        return jsonify(
            access_token=access_token,
            user_type="Teacher",
            email=teacher.email
        ), 200

    # If not a teacher, try to find the user as a student
    student = Student.query.filter_by(email=email).first()
    if student and student.password == password:
        access_token = create_access_token(identity=student.id)
        return jsonify(
            access_token=access_token,
            user_type="Student",
            email=student.email,
            department=student.department
        ), 200

    return jsonify(message="Invalid credentials"), 401

# Logout route
@app.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    response = jsonify(message="Logout successful")
    unset_jwt_cookies(response)
    return response, 200

if __name__ == '__main__':
    app.run(debug=True)
