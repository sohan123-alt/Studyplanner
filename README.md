# AI Study Planner & Exam Predictor (Bangladesh Focused)
### JSP + Oracle Database | Apache Tomcat Project

---

## 📁 Complete Project Structure

```
StudyPlanner/
│
├── database.sql                        ← Run this in Oracle SQL Developer first
│
└── WebContent/
    ├── index.jsp                       ← Landing page
    ├── register.jsp                    ← Student registration
    ├── login.jsp                       ← Student login
    ├── logout.jsp                      ← Clears session
    ├── dashboard.jsp                   ← Student home dashboard
    ├── subjects.jsp                    ← Add/delete subjects
    ├── syllabus.jsp                    ← Upload syllabus text
    ├── studyplan.jsp                   ← AI study plan generator
    ├── progress.jsp                    ← Score tracking
    ├── weak_subjects.jsp               ← Weak subject analysis
    ├── predictions.jsp                 ← Exam question predictions
    │
    ├── includes/
    │   ├── db.jsp                      ← Oracle DB connection (EDIT THIS)
    │   ├── header.jsp                  ← Student navigation
    │   └── footer.jsp                  ← Page footer
    │
    ├── admin/
    │   ├── login.jsp                   ← Admin login
    │   ├── logout.jsp                  ← Admin session clear
    │   ├── dashboard.jsp               ← Admin overview + stats
    │   ├── admin_header.jsp            ← Admin navigation
    │   ├── manage_users.jsp            ← View/search/delete users
    │   ├── manage_subjects.jsp         ← Add/view/delete subjects
    │   ├── manage_syllabus.jsp         ← View/delete syllabuses
    │   └── manage_predictions.jsp      ← Full CRUD for predictions
    │
    ├── css/
    │   └── style.css                   ← Main stylesheet (responsive)
    │
    └── WEB-INF/
        └── web.xml                     ← Deployment descriptor
```

---

## ⚙️ SETUP INSTRUCTIONS (Step by Step)

### Step 1 — Install Required Software
| Software | Download |
|---|---|
| JDK 11 or 17 | https://www.oracle.com/java/technologies/downloads/ |
| Apache Tomcat 10 | https://tomcat.apache.org/download-10.cgi |
| Oracle XE (Database) | https://www.oracle.com/database/technologies/xe-downloads.html |
| Oracle SQL Developer | https://www.oracle.com/tools/downloads/sqldev-downloads.html |
| ojdbc8.jar (JDBC driver) | https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html |

---

### Step 2 — Run the Database Script

1. Open **Oracle SQL Developer**
2. Connect to your Oracle XE instance
3. Open `database.sql`
4. Click **Run Script (F5)**
5. Verify: Tables created + 1 admin + 6 sample predictions

> **Default Oracle XE connection:**
> - Host: `localhost`
> - Port: `1521`
> - SID: `XE` (or service name `XEPDB1` for 21c+)

---

### Step 3 — Configure Database Connection

Open `WebContent/includes/db.jsp` and edit these 3 lines:

```java
static final String DB_URL  = "jdbc:oracle:thin:@localhost:1521:XE";
// For Oracle 21c+, use service name:
// static final String DB_URL  = "jdbc:oracle:thin:@localhost:1521/XEPDB1";

static final String DB_USER = "system";       // your Oracle username
static final String DB_PASS = "your_password"; // your Oracle password
```

---

### Step 4 — Add OJDBC Driver

1. Download `ojdbc8.jar` from Oracle website
2. Place it in: `WebContent/WEB-INF/lib/ojdbc8.jar`
   (Create the `lib` folder if it doesn't exist)

---

### Step 5 — Deploy to Tomcat

**Option A — Copy to webapps:**
1. Copy the entire `StudyPlanner` folder to:
   `C:\Apache Tomcat\webapps\StudyPlanner\`
2. Start Tomcat: run `startup.bat`

**Option B — Using Eclipse/IntelliJ:**
1. Import as a Dynamic Web Project
2. Add Tomcat server in IDE
3. Add `ojdbc8.jar` to project build path
4. Run on Server

---

### Step 6 — Access the Application

| URL | Page |
|---|---|
| http://localhost:8080/StudyPlanner/ | Landing Page |
| http://localhost:8080/StudyPlanner/register.jsp | Student Register |
| http://localhost:8080/StudyPlanner/login.jsp | Student Login |
| http://localhost:8080/StudyPlanner/admin/login.jsp | Admin Login |

---

## 🔑 Default Login Credentials

| Role | Username / Email | Password |
|---|---|---|
| Admin | `admin` | `admin123` |
| Student | Register a new account | Your chosen password |

---

## 🗄️ Database Tables Summary

| Table | Purpose |
|---|---|
| `Admin` | Admin accounts |
| `Users` | Student accounts |
| `Subjects` | Subjects per student |
| `Syllabus` | Uploaded syllabus text |
| `StudyPlan` | Generated study tasks |
| `Progress` | Test scores per subject |
| `Predictions` | Exam question predictions |

---

## 🤖 AI / Rule-Based Logic Explained

### Study Plan Generator (studyplan.jsp)
```
Rule: Rotate subjects day-by-day for 14 days
Rule: Assign task types: New Topic → Revision → Practice → repeat
Rule: Subjects with earlier exam_date get listed first (priority)
Rule: Every 3rd day = 3 hours; other days = 2 hours
```

### Weak Subject Detection (weak_subjects.jsp)
```
Rule: AVG(score / max_score * 100) < 50%  → WEAK   (red)
Rule: AVG(score / max_score * 100) 50–70% → AVERAGE (orange)
Rule: AVG(score / max_score * 100) > 70%  → STRONG  (green)
```

### Exam Readiness Score (dashboard.jsp)
```
Rule: SUM(all scores) / SUM(all max_scores) * 100 = readiness %
Rule: >= 70% = On Track (green)
Rule: 40–70% = Fair (orange)
Rule: < 40%  = Needs Work (red)
```

---

## 🌐 Page Flow

```
index.jsp
  ├── register.jsp → login.jsp
  └── login.jsp
        └── dashboard.jsp
              ├── subjects.jsp
              ├── syllabus.jsp
              ├── studyplan.jsp
              ├── progress.jsp
              ├── weak_subjects.jsp
              └── predictions.jsp

admin/login.jsp
  └── admin/dashboard.jsp
        ├── admin/manage_users.jsp
        ├── admin/manage_subjects.jsp
        ├── admin/manage_syllabus.jsp
        └── admin/manage_predictions.jsp (Add / Edit / Delete)
```

---

## ❗ Common Errors & Fixes

| Error | Fix |
|---|---|
| `ClassNotFoundException: oracle.jdbc.driver.OracleDriver` | ojdbc8.jar not in WEB-INF/lib/ |
| `Connection refused` | Oracle XE service not running — start OracleServiceXE |
| `ORA-01017 invalid username/password` | Wrong DB_USER or DB_PASS in db.jsp |
| `ORA-12505 unknown SID` | Change `:XE` to `/XEPDB1` in DB_URL |
| `404 Not Found` | Wrong deployment path or Tomcat not started |
| `HTTP 500` | Check Tomcat logs in `logs/catalina.out` |

---

## 📦 Tech Stack

- **Frontend:** HTML5, CSS3, JavaScript (vanilla)
- **Backend:** JSP (JavaServer Pages) with scriptlets
- **Database:** Oracle XE (JDBC via ojdbc8)
- **Server:** Apache Tomcat 10
- **No Servlets, no Spring, no Maven** — pure JSP for simplicity

---

*Built for university project demo — AI Study Planner & Exam Predictor, Bangladesh*
