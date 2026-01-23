# Avo Migration Progress 

This shall be a parallel incremental Migration with existing dashboard

## Completed
- Avo installed
- added `admin2` as the route for accessing avo dashboard
- added `app/avo/resources` as the base resources, Authentication wired to `current_user.admin?`

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
- migrate the following panels: 
    - navigation 
        - announcements 
        - assignments 
        - collaborations
        - contests 
        - contest winners
        - custom mails
        - featured circuits 
        - forum categories
        - forum posts
        - forum subscriptions
        - forum threads
        - grades
        - groups 
        - group members
        - issue circuits data
        - noticed notifications 
        - pending invitations 
        - projects 
        - project data 
        - push subscriptions
        - stars
        - submission votes
        - tags 
        - taggings
        - users
    - activeStorage
        - attachments 
        - blobs
        - variant records
    - Commontator 
        - comments 
        - subscriptions
        - threads
    - ahoy
        - events
        - visits
    - mailkick
        - opt outs 
    - maintainance Tasks
        - runs
- Migrate site administration 
- Add Test files (optional)

