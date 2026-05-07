# Smart Resume Builder & Job Application Tracker App

A Flutter-based mobile application that helps students and job seekers create resumes, manage job applications, track application status, and monitor progress with offline-first support.

---

## Features

### Resume Builder
- Create multiple resumes
- Edit and delete resumes
- Add:
  - Personal Details
  - Education
  - Skills
  - Experience
  - Career Objective

### Job Application Tracker
- Add job applications
- Track application status
- Link resumes to applications
- Generate unique Application IDs

### Application Status Tracking
Track job applications using statuses:
- Applied
- Shortlisted
- Interview Scheduled
- Rejected
- Selected

### Dashboard Analytics
- Total applications
- Selected applications
- Rejected applications
- Interview statistics
- Recent applications
- Charts and analytics

### Search & Filter
Search by:
- Company Name
- Job Role

Filter by:
- Status
- Date
- Resume Used

### Offline First Support
- Local data storage using Hive
- Works without internet
- Syncs data when online

---

# Tech Stack

## Frontend
- Flutter

## State Management
- Riverpod

## Local Database
- Hive

## Backend
- Firebase Firestore

## Charts
- fl_chart

## Routing
- GoRouter

---

# Folder Structure

```bash
lib/
├── core/
├── features/
│   ├── resume/
│   ├── applications/
│   ├── dashboard/
│   └── search/
├── routes/
├── services/
├── widgets/
└── main.dart
