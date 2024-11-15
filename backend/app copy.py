from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager, create_access_token, jwt_required

app = Flask(__name__)

# Configure the app to use MySQL
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/finalyear'
app.config['JWT_SECRET_KEY'] = 'joel'  # Change this to something secure
db = SQLAlchemy(app)
jwt = JWTManager(app)

# Create a User model
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)

    def __repr__(self):
        return f'<User {self.email}>'

# Initialize the database (only run once)
with app.app_context():
    db.create_all()

@app.route('/login', methods=['POST'])
def login():
    email = request.json.get('email', None)
    password = request.json.get('password', None)

    user = User.query.filter_by(email=email).first()

    # Check if user exists and password is correct
    if user and user.password == password:
        access_token = create_access_token(identity=user.id)
        return jsonify(access_token=access_token), 200

    return jsonify(message="Invalid credentials"), 401

# A protected route that requires a valid JWT token
@app.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    return jsonify(message="You have access to this route"), 200

if __name__ == '__main__':
    app.run(debug=True)
