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

@app.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    current_user_id = get_jwt_identity()

    # Check if the current user is a teacher or student
    teacher = Teacher.query.get(current_user_id)
    if teacher:
        return jsonify(
            message="You have access to this route",
            user_type="Teacher",
            email=teacher.email
        ), 200

    student = Student.query.get(current_user_id)
    if student:
        return jsonify(
            message="You have access to this route",
            user_type="Student",
            email=student.email,
            department=student.department
        ), 200

    return jsonify(message="User not found"), 404

# Logout route to invalidate the user's session
@app.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    response = jsonify(message="Logout successful")
    # Remove the JWT token by unsetting the cookies
    unset_jwt_cookies(response)
    return response, 200

if __name__ == '__main__':
    app.run(debug=True)
