from flask import Flask, request, jsonify
from pymongo import MongoClient
from bson.objectid import ObjectId
from flask_cors import CORS
import os
from dotenv import load_dotenv

load_dotenv()
MONGODB = os.getenv('MONGO_URL')

app = Flask(__name__)
client = MongoClient(MONGODB)
db = client['todo_app']
todos = db['todos']
CORS(app)

@app.route('/todos', methods=['GET'])
def get_todos():
    todos_list = []
    for todo in todos.find():
        todos_list.append({
            '_id': str(todo['_id']),
            'task': todo['task'],
            'completed': todo['completed']
        })
    return jsonify(todos_list)

@app.route('/todos', methods=['POST'])
def add_todo():
    task = request.json['task']
    todo_id = todos.insert_one({
        'task': task,
        'completed': False
    })
    return jsonify({'_id': str(todo_id.inserted_id), 'task': task, 'completed': False})

@app.route('/todos/<id>', methods=['PUT'])
def mark_done(id):
    todos.update_one({'_id': ObjectId(id)}, {'$set': {'completed': True}})
    return jsonify({'message': 'Task marked as done'})

@app.route('/todos/<id>', methods=['DELETE'])
def delete_task(id):
    todos.delete_one({'_id': ObjectId(id)})
    return jsonify({'message': 'Task deleted'})

if __name__ == '__main__':
    app.run(debug=True)
