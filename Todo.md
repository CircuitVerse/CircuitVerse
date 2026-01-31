# Avo Migration Progress 

This shall be a parallel incremental Migration with existing dashboard

## Proposed Project Structure: 
- all the resources are added in the `app/avo/resources` in the format : (subject to change)
```
app/ 
├── avo/
│   ├── resources/
│   ├── actions/
│   ├── filters/
│   ├── dashboards/         
│   ├── cards/             
│   └── tools/             
│
├── concerns/
│   └── avo/
│       └── authentication.rb
│
└── policies/
    └── avo/
        └── application_policy.rb
```
## Plan : 

### Phase 1 – Core Domain Resources
> These are the highest-value admin features

Resources to migrate (in this order):
- User
- Project
- Group
- Assignment
- Contest

### Phase 2 – Supporting Admin Features
> Now migrate secondary domain models:

- Navigation-level resources
- Announcements
- FeaturedCircuits
- CustomMails
- Tags / Taggings
- Stars
- Collaborations
- Grades

### Phase 3 – Read-Only System & Audit Tables

- Resources (index + show ONLY)
- ActiveStorage
- Blobs
- Attachments
- Ahoy
- Events
- Visits
- Mailkick
- OptOuts
- Commontator
- Threads
- Comments
- Subscriptions
- MaintenanceTasks
- Runs

## TODO:
- [x] Avo installed
- [x] added `admin2` as the route for accessing avo dashboard
- [x] added `app/avo/resources` as the base resources, Authentication wired to `current_user.admin?`
- [x] Migrate the following panels:
  - [x] Navigation
    - [x] Announcements
    - [x] Assignments
    - [x] Collaborations
    - [x] Contests
    - [x] Contest Winners
    - [x] Custom Mails
    - [x] Featured Circuits
    - [x] Forum Categories
    - [x] Forum Posts
    - [x] Forum Subscriptions
    - [x] Forum Threads
    - [x] Grades
    - [x] Groups
    - [x] Group Members
    - [x] Grades
    - [x] Groups
    - [x] Group Members
    - [x] Issue Circuits Data
    - [x] Noticed Notifications
    - [x] Pending Invitations
    - [x] Projects
    - [x] Project Data
    - [x] Push Subscriptions
    - [x] Stars
    - [x] Submission
    - [x] Submission Votes
    - [x] Tags
    - [x] Taggings
    - [x] Users

  - [x] ActiveStorage
    - [x] Attachments
    - [x] Blobs
    - [x] Variant Records

  - [x] Commontator
    - [x] Comments
    - [x] Subscriptions
    - [x] Threads

  - [x] Ahoy
    - [x] Events
    - [x] Visits

  - [x] Mailkick
    - [x] Opt Outs

  - [x] Maintenance Tasks
    - [x] Runs

- [x] Migrate site administration
- [ ] Add test files (optional)
- [ ] Grouping of the resources according to panels (requires avo PRO)
- [x] Circuitverse themed dashboard

--- 

Bugs: 
- [ ] Assignments - grades finalized, feature restrictions, projects, grades(projects and grades comes after creation), list all the values in view, export
- [ ] collaboration - export, createdAt date in jan 27 format rather than numbers, show in app(eye icon)
- [ ] contests - add filters - deadline,createdAt,updatedAt, add submissions, submission votes, contest winner while creating, export found contests
- [ ] contest winners - export, filter, export found winners
- [ ] custom mails - content, export, sent, remove createdAt, updatedAt as its read only, filter on all
- [ ] new featured circuit - edit this project, export, filter
- [ ] forum categories - export, filter, 
- [ ] forum posts - export, filter, solved
- [ ] forum subcription - export, filter
- [ ] forum thread - optin subs,optout subs, users
- [ ] grades - filter(add all),export
- [ ] groups - group member count, group token,token expires at
- [ ] group members - assignment addition
- [ ] issue circuit data - export 
- [ ] pending invitations - export
- [ ] project data - export,filter  
- [ ] projects - actions(toggle featured status), export, adding forks, stars, collaborators, taggings, grade, commentator thread etc
- [ ] push notif - fitler export 
- [ ] stars - filter, export 
- [ ] submissions - filter, exports, submission votes count,
- [ ] submission votes - filter export 
- [ ] subscriptions - rename as commentator subscription, filter export, rename thread to discussion
- [ ] tags - taggings, projects 
- [ ] tagging - filter,export
- [ ] users - filter, export, actions remove,password,password confirmation, reset password sent at, remember createdAt last sign in At, current signin ip remove read only etc many more   
- [ ] activeStorage attachments - filter export,
- [ ] activeStorage blob - Filename,Content type, Metadata, Service name, byte size, checksum,attachemnts, variant records,preview image
- [ ] variant records - filter, export
- [x] comments - filter,export, read only many are there, tconvert name of thread to discussion, children
- [x] threads - rename as commentator threads, closer remove, comments and subs, fitler export
- [x] events - filter export events
- [x] mailkick - filter export lock version csv upload


