*Smart Examination Portal*

Industry-Sponsored Smart Examination Portal developed as part of an academic-industry collaboration project under the guidance of Vishwakarma Institute of Technology, Pune and sponsored by NKSKILLEDGE PVT LTD.

The application is built using Flutter with a hybrid database architecture integrating Supabase PostgreSQL and MongoDB Atlas. The system provides a scalable and secure digital examination workflow with automated evaluation, media verification, and real-time exam management features.

*Tech Stack*
Frontend
Flutter
Dart
Backend & Database
Supabase PostgreSQL
MongoDB Atlas
MongoDB GridFS
Tools & Packages
supabase_flutter
mongo_dart
flutter_dotenv
image_picker
camera
permission_handler
Core Features
Authentication & Student Management
Secure student login system
Department-based student registration
Dynamic student profile management
Profile image upload and retrieval
Examination Workflow
Department-wise exam allocation
Assigned exams dashboard
Real-time timer-controlled exams
Automatic exam submission
Duplicate attempt prevention
Automated score calculation
Exam Analytics
Completed exams tracking
Missed exams detection
Dynamic filtering based on exam deadlines
Media Verification System
Front-camera based verification capture
Automated short-duration video recording
MongoDB GridFS video storage
Profile image storage using GridFS
Advanced DBMS Concepts Implemented
Relational Database Concepts
JOIN operations
Subquery (NOT IN) logic
Foreign key relationships
One-to-many relationships
Dynamic filtering and relational mapping
NoSQL Concepts
MongoDB document-based architecture
GridFS chunk-based file storage
Binary media handling
Cross-database linking
Hybrid Architecture
PostgreSQL used for structured academic data
MongoDB used for unstructured media storage
Shared studentId linkage between SQL and MongoDB

*Project Architecture*
Flutter Application
        │
        ├── Supabase PostgreSQL
        │      ├── Students
        │      ├── Exams
        │      ├── Questions
        │      └── Student Exams
        │
        └── MongoDB Atlas
               ├── Student Profiles
               ├── Exam Verifications
               ├── GridFS Files
               └── GridFS Chunks

*GridFS Implementation*

The project uses MongoDB GridFS for scalable media storage.

Stored Media
Profile images
Verification videos
GridFS Collections
fs.files
fs.chunks

GridFS internally splits large binary files into chunks and reconstructs them dynamically during retrieval.

*Security Improvements*

Environment-based secret management using .env
Secure database credential handling
GitHub-safe configuration setup
Runtime permission handling for media access
Screens Included
Student Login
Student Dashboard
Assigned Exams
Completed Exams
Missing Exams
Student Profile
Verification Recording Workflow
Future Enhancements
AI-based proctoring
PDF marksheet generation
Admin analytics dashboard
Facial recognition verification
Cloud storage optimization
Real-time malpractice detection


*Developed By*
Madhusudan Kailash Madankar
Flutter & DBMS Project Developer


*Industry Collaboration*
*Sponsored by:*
NKSKILLEDGE PVT LTD


*Academic Institution:*
Vishwakarma Institute of Technology, Pune


*License*
This project was developed for academic and demonstration purposes.