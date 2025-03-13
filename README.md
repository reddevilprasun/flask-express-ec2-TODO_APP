
# Todo Application: Express Frontend and Flask Backend
## (DevOps Training/practice part) - TuteDude

This repository contains a simple Todo application that uses **Express.js** as the frontend and **Flask** as the backend. The backend is connected to MongoDB for data storage. Both the frontend and backend are containerized using Docker and deployed on an AWS EC2 instance.

## Table of Contents
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Dockerization](#dockerization)
  - [Frontend Dockerfile](#frontend-dockerfile)
  - [Backend Dockerfile](#backend-dockerfile)
  - [Docker Compose](#docker-compose)
- [Deploy on AWS EC2](#deploy-on-aws-ec2)
- [Accessing the Application](#accessing-the-application)


---

## Features
- **Add a Task:** Users can add new tasks.
- **Mark Task as Done:** Users can mark a task as done.
- **View All Tasks:** All tasks are displayed on the same page.

## Technologies Used
- **Frontend:** Express.js (JavaScript)
- **Backend:** Flask (Python)
- **Database:** MongoDB (Hosted separately)
- **Docker:** For containerization of both frontend and backend
- **AWS EC2:** For deployment

## Prerequisites
Before you begin, ensure you have met the following requirements:
- **Node.js** and **npm** installed (for frontend development)
- **Python** and **pip** installed (for backend development)
- **MongoDB** instance available (you can use MongoDB Atlas or a self-hosted MongoDB instance)
- **Docker** installed
- **AWS EC2** instance with access via SSH

## Setup

### Backend (Flask)
1. **Navigate to the backend directory**:
   ```bash
   cd backend
   ```
2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
3. **Run the Flask backend**:
   ```bash
   python app.py
   ```

### Frontend (Express)
1. **Navigate to the frontend directory**:
   ```bash
   cd frontend
   ```
2. **Install dependencies**:
   ```bash
   npm install
   ```
3. **Run the Express frontend**:
   ```bash
   npm start
   ```

### MongoDB
Make sure MongoDB is up and running, and you have the correct MongoDB connection URI configured in the Flask app (in `app.py`).
