# reformulator-artifact

Self-contained code artifact to run the *Reformulator* Sequelize ORM API refactoring tool.
This implements the approach discussed in the ASE'22 paper *"Reformulator: Automated Refactoring of the N+1 Problem in Database-Backed Applications"* by Turcotte et al.
This artifact is being evaluated in the ASE'22 Artifact track.

### Table of Contents

1. Notes
2. Building the Image
3. Running the Image
4. Gist / Sanity Check / Kick-the-Tires
5. Paper Experiment Reproduction
6. Detailed Artifact Description
7. Extending the Artifact

# NOTES

- If you're building this locally, make sure to `chmod +x setupCodeQL.sh makeEvaluation.sh setupProjects.sh seedForDeepDive.sh` to give Docker permission to run the scripts.
- One of the subject applications (`wall`) has validation enabled for data that is to be stored in the database.
For this reason, our automated method of seeding the database does not always work, and if you notice that the database is incomplete should you choose to investigate this application, try re-seeding it once or twice.

# Building the Image

To build the artifact, simply run:

```
git clone <this repo>
cd reformulator-artifact
docker build -t reformulator .
```

The image itself is just shy of 5GB.

# Running the Image

The following command will launch the Reformulator Docker container in daemon mode, meaning that the docker container is running in the background and can be connected to.

```
docker run -d -t -i -p 3000:3000 -p 5000:5000 reformulator
# The container ID will be written to the console.
```

Note the container ID, as you'll need it to connect to the container.
**Note on ports**: the command as it is binds port 3000 in docker to port 3000 on your localhost, similarly with port 5000.
This is required so that you can access the sites that are hosted in docker.
If your port 3000 is occupied, the anatomy of the port forwarding is `-p <port on machine>:<port in docker>`, so change `<port on machine>` according to your own system.

To connect to the container, type the following in a terminal:
```
docker exec -it <container-id> bash
```
You can connect multiple terminals to the container if you'd like.
If you lose the container id, simply write `docker ps` and find the container named `reformulator`.

When you want to stop the container: `docker stop <container-id>`.

## Container Structure

The structure of the Docker container is as follows:

```
/home
--> /reformulator
----> /orm-refactoring        (The actual code transformation.)
----> /reformulator-analysis  (The analysis that feeds in to the code transformation.)
--> /evaluation
----> /case-studies
------> /<one-dir-for-each-project-in-evaluation>
----> /scripts
----> /query-results
----> /QLDBs
--> /codeql_home
```

# Gist / Sanity Check / Kick-the-Tires

This section illustrates the general workflow of the artifact with `youtubeclone` as exemplar.
This section assumes you are in the Docker container.
(Running through this section should confirm that the artifact is operational.)

### What is this Artifact?

This artifact is a self-contained environment to reproduce the evaluation of the ASE'22 paper *"Reformulator: Automated Refactoring of the N+1 Problem in Database-Backed Applications"* by Turcotte et al.
The paper presents *Reformulator*, a tool for automatically refactoring Select N+1 problems in Sequelize-backed JavaScript web applications.
This artifact contains the source code for *Reformulator*, as well as the eight subject applications that *Reformulator* was evaluated on in the paper.

At a high-level, the idea of the evaluation was to first identify HTTP request handlers in the servers behind these web applications that had Select N+1 anti-patterns in their code.
E.g., the `youtubeclone` application has several Select N+1 anti-patterns, and the search for users HTTP request handler exhibits the anti-pattern.
Once identified, we exercised the frontend of the application until we figured out how to send the HTTP request to the server.
We manually inserted profiling code into the applications to collect the time it took the server to serve the request.
Then, we applied the refactorings, triggered the HTTP request again, and both confirmed that no behavioral differences were introduced by the refactoring, and noted the performance difference between the original and refactored code.

### Run CodeQL

*Reformulator* has two phases: first, dataflow between ORM API calls are detected via analysis, and then related ORM API calls are transformed.
This section describes how to detect the dataflows using CodeQL.

1.  CodeQL runs on a database built up from the source code.
    (For the interested, the database contains an AST representation of the code, as well as control flows and data flows.)
    To build this database, we included a convenience script `/home/evaluation/scripts/make-database.sh` which takes two arguments: the path to the code, and the name of the project.
    For the purpose of this example, navigate to the `evaluation` directory and run `make-database.sh` (<1 min):
    ```
    cd /home/evaluation
    ./scripts/make-database.sh ./case-studies/youtubeclone/ youtubeclone-backend

    # Writes a bunch of terminal output, capped off with "Successfully created database at /home/evaluation/QLDBs/youtubeclone-backend"
    ```

2.  Now we can run the dataflow detecting query on the database.
    We have also included a convenience script for this `/home/evaluation/scripts/run-query.sh` which takes two arguments: the name of the project, and the name of the query.
    Again from the `evaluation` directory, run `run-query.sh` as follows (~2 mins, first run takes long because the query needs to be compiled by CodeQL):
    ```
    ./scripts/run-query.sh youtubeclone-backend find-sequelize-flows

    # First writes "Compiling query plan for /home/reformulator/reformulator-analysis/find-sequelize-flows.ql."
    # Then after a time should write "[1/1 eval _._s] Evaluation done; writing results to [...]"
    # (This can take some time.)
    ```

3.  The result of these two steps is the creation of a .csv file with the Sequelize dataflows for a project.
    To confirm that everything ran smoothly:
    ```
    vim /home/evaluation/query-results/find-sequelize-flows/youtubeclone-backend.csv

    # Should show a file with 13 lines: a header, and 12 dataflows.
    ```

### Run the Transformation

The output of the previous phase is input to the actual code transformation.
We first discuss the anatomy of the command, and then show an example using the flows obtained in the last step.
The command to run the transformation is: 
```
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=<path to the project root> \
    --flows=<path to the dataflows> \
    --models=<path to the Sequelize models> \
    --sequelize-file=<path to the sequelize definition file>
```

The `--pathTo` and `--flows` options simply tell the transformation where to look for the code to transform, and which flows should be transformed, respectively.
The `--models` option tells the transformation where to find the Sequelize ORM models; in an ORM, there is a model (typically a class) defined for each table in the database, and the transformation needs to be aware of these to generate the correct code.
The usual place to find the Sequelize ORM models is in a `.../models/` subdirectory.
The `--sequelize-file` option tells the transformation where to find the Sequelize definition file; most associations between models are not defined on the models themselves, but are instead defined in this definition file, e.g., with code like `Model1.hasMany(Model2)`.
The usual name for such a definition file is `sequelize.js` or `database.js`, and it can typically found near the other ORM files.

(Before proceeding, make sure you are using version 16 of NodeJS.
To do so, input `nvm use 16` in the terminal.)

Concretely, to transform `youtubeclone`: 
```
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=/home/evaluation/case-studies/youtubeclone/youtubeclone-backend/ \
    --flows=/home/evaluation/query-results/find-sequelize-flows/youtubeclone-backend.csv \
    --models=/home/evaluation/case-studies/youtubeclone/youtubeclone-backend/src/models/ \
    --sequelize-file=/home/evaluation/case-studies/youtubeclone/youtubeclone-backend/src/sequelize.js
```

You should see the following terminal output (and if you get an error, try `nvm use 16` and then re-running the command):

```
Finding flows in: /home/evaluation/case-studies/youtubeclone/youtubeclone-backend/src/controllers/user.js
Finding flows in: /home/evaluation/case-studies/youtubeclone/youtubeclone-backend/src/controllers/video.js
Transforming pair: findAll -> count
Transforming pair: findAll -> count
Transforming pair: findAll -> count
Transforming pair: findAll -> findOne
Transforming pair: findAll -> count
Transforming pair: findAll -> count
Transforming pair: findAll -> count
Transforming pair: findAll -> count
Transforming pair: findAll -> count
Transforming pair: findAll -> findOne
Transforming pair: findAll -> count
Transforming pair: findAll -> count
```
To confirm that the transformation worked, you can navigate to the source directory for `youtubeclone-backend` and verify:

```
cd /home/evaluation/case-studies/youtubeclone/youtubeclone-backend

# Abuse the fact that the git repository and branch are set up in a useful way:
git status
```

This should report that there are two modified files, `src/controllers/user.js` and `src/controllers/video.js`. 
For an example of a transformation in action, try `vim +94 src/controllers/user.js`.
You should see a variable definition `const view_counts_####` (where `####` are some alphanumeric characters) which is initialized with a call to `View.findAll`.
(FWIW: This corresponds to a fix for the N+1 problem, where all of the views are pre-fetched rather than fetched in the loop.)

### Test the Transformation

**Important NOTE:** Everytime the container is (re-)started, the postgres and mysql database services needs to be (re-)started as well.
To do this, simply run `service postgresql start` and `service mysql start` (note: the MySQL service in particular is a little finicky, so if the service fails to start just try again). 

All of the applications in our evaluation are web-based and utilize databases. 
Typically, a database-backed web application has three components: a front-end, a back-end, and a database.
E.g., `youtubeclone` has `youtubeclone-backend`, `youtubeclone-frontend`, and a database hosted on `ElephantSQL`.
We will focus on our running example `youtubeclone` in this section, and show how you can get it up and running and test the refactorings.

1.  *Configure the Application*: actually, the application is already pre-configured to run out of the box.
    In the `.env` file (`cat /home/evaluation/case-studies/youtubeclone/youtubeclone-backend/.env`), you'll find details on the database that the subject application is connected to (don't worry, it's a free version of an ElephantSQL database).
    The database already has some videos in it that we uploaded for our evaluation.

2.  *Starting the Application*: to run `youtubeclone`, both the front- and back-end need to be running.
    For this, we ask that you run two docker terminals; to do so, open two terminals, and in both of them type `docker exec -it <reformulator-container-id> bash`, with the ID of the reformulator container.
    Both terminals will be connected to the same container.

    To start the **frontend**, from one terminal connected to the container:
    ```
    cd /home/evaluation/case-studies/youtubeclone/youtubeclone-frontend
    npm run start
    ```

    To start the **backend**, from a different terminal connected to the container: 
    ```
    cd /home/evaluation/case-studies/youtubeclone/youtubeclone-backend
    npm run start
    ```
    A bunch of output will be written to the terminal; these are all queries that are executed by the ORM.
    A more detailed recounting of this output follows in the next subsection.

3.  *Testing the Application*: to find and interact with the application, open a browser and type `localhost:3000` into the address bar (or whichever local port you configured to forward to the docker port).
    You can log in with email "email@email.com" and password "email".
    You should see many queries executed in your terminal thats running the server.
    If you've been following the instructions sequentially until now, this will be the *refactored* code.

4.  *Re/factored Backend*: for convenience, we have included the code with all refactorings, profiling, and logging in a separate branch titled `orm-refactoring-refactored`, and the original code (+ profiling) in branch `orm-refactoring-original`.
    To switch to the original version for comparison, kill the server that's currently executing (`CTRL + C`) and type `git reset --hard`, and restart the server with `npm run start`.
    If ever you want to switch to the original or refactored versions, just checkout the appropriate branches.

At this point, the artifact should be operational.

#### Explanation of Terminal Output from Running Applications

We have included profiling code and enabled query logging for each of the applications; this means that the terminal that is running the server will be very busy, and you'll need to look there to collect timings and visually inspect queries.

To give a sense for how to parse this output, we will discuss an example with `youtubeclone`.
In the default database configuration with the original code, loading the homepage of `youtubeclone` for a user that is logged in should yield something like this in the terminal:
```
==================== recommendVideos // start ====================
Executing (default): SELECT "Video"."id", "Video"."title", "Video"."description", "Video"."thumbnail", "Video"."userId", "Video"."createdAt", "User"."id" AS "User.id", "User"."avatar" AS "User.avatar", "User"."username" AS "User.username" FROM "Videos" AS "Video" LEFT OUTER JOIN "Users" AS "User" ON "Video"."userId" = "User"."id" ORDER BY "Video"."createdAt" DESC;
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = '2c0aec8a-02bf-41f9-9d8a-36e09737fb20';
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = 'c93e6607-5f02-442d-b625-ec35a2f6681b';
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = 'aa7c3ace-6a2f-47f2-99f4-72940794b696';
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = '65bc0525-79e0-4ef6-ac00-13a5806cadfa';
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = '3350be9d-6451-4ea3-9e5a-aac8700aa81d';
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = 'ba862783-b90a-4074-8711-b17b3a98b312';
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = 'c12d94a5-806b-48b9-bce9-6e0eb7b0db9b';
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = 'deb938e9-55c5-4982-b786-9d9a563b9fd6';
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = 'b901e3c0-8e8c-4b8c-8638-1119f18c6609';
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = '5a1514d7-bf59-485f-ab83-ee0f1c49473b';
Executing (default): SELECT count(*) AS "count" FROM "Views" AS "View" WHERE "View"."videoId" = '61886685-cc79-46e3-b88c-dd39ac1be267';
====================  recommendVideos // end  ====================
312.2787857055664
```
Here, `recommendVideos` is the human-readable name we gave to the HTTP request handler under study.
The number displayed after the final `recommendVideos` print (`312.2787857055664`) is the time in milliseconds taken for the server to prepare a response.
Between the `===` logs you'll note many queries: these correspond to the queries generated by the ORM while the `youtubeclone` backend prepared the response.
You can actually see the Select N+1 problem here, as there are multiple queries that look almost identical except for the `"videoID"` being selected.

Now, for the refactored code (here we killed the server, entered `git checkout orm-refactoring-refactored` into the terminal to change branches, restarted the server, and refreshed the page):
```
==================== recommendVideos // start ====================
Executing (default): SELECT "Video"."id", "Video"."title", "Video"."description", "Video"."thumbnail", "Video"."userId", "Video"."createdAt", "User"."id" AS "User.id", "User"."avatar" AS "User.avatar", "User"."username" AS "User.username" FROM "Videos" AS "Video" LEFT OUTER JOIN "Users" AS "User" ON "Video"."userId" = "User"."id" ORDER BY "Video"."createdAt" DESC;
Executing (default): SELECT "videoId", COUNT("View"."videoId") AS "aggregateCount" FROM "Views" AS "View" WHERE "View"."videoId" IN ('2c0aec8a-02bf-41f9-9d8a-36e09737fb20', 'c93e6607-5f02-442d-b625-ec35a2f6681b', 'aa7c3ace-6a2f-47f2-99f4-72940794b696', '65bc0525-79e0-4ef6-ac00-13a5806cadfa', '3350be9d-6451-4ea3-9e5a-aac8700aa81d', 'ba862783-b90a-4074-8711-b17b3a98b312', 'c12d94a5-806b-48b9-bce9-6e0eb7b0db9b', 'deb938e9-55c5-4982-b786-9d9a563b9fd6', 'b901e3c0-8e8c-4b8c-8638-1119f18c6609', '5a1514d7-bf59-485f-ab83-ee0f1c49473b', '61886685-cc79-46e3-b88c-dd39ac1be267') GROUP BY "View"."videoId";
====================  recommendVideos // end  ====================
51.689720153808594
```
There are far fewer queries, and indeed one single query seems to be fetching for all of the multiple `"videoId"`.
The time taken for the refactored handler to prepare a response was much lower, `51.689720153808594` ms.

# Paper Experiment Reproduction

This artifact contains the necessary material to investigate RQs 2 through 5.
For RQ1, we ran the `npm-filter` tool on many hundreds of thousands of GitHub repositories over multiple thousand human hours, and we do not recommend trying to reproduce that.
We included a spreadsheet with our results for RQ1 in `/home/data`, and the final subsection will describe the data. 

Each of the anti-patterns studies are numbered, and a sheet describing them is included in `/home/data` as well.
The next section will describe how to trigger each of them.

## Project Details

Before diving into the research questions themselves, we will describe each of the projects so that you may investigate them yourself. 
The projects are pre-installed, and the databases are pre-configured (this was done as part of the setup of the image).
Any changes that are made in the container will be undone when the container is stopped.

### youtubeclone

**To run**: `npm run start` in the `/home/evaluation/case-studies/youtubeclone/youtubeclone-frontend` directory, and `npm run start` in `/home/evaluation/case-studies/youtubeclone/youtubeclone-backend` (please use two different terminals connected to the same container).
Navigate to `localhost:3000` on your browser.
Log in with user email "email@email.com", password "email".

**To trigger N+1 problems**: 

0. need to be subscribed to atat, and navigate to Subscriptions tab
1. search for 'a'
2. access a profile that has videos uploaded (atat)
3. go to homepage
4. access subscriptions when you have no subscriptions
5. like some videos, and navigate to 'Liked Videos'
6. search for 'zoom'

### eventbright

**To run**: `npm run start` in `/home/evaluation/case-studies/eventbright/frontend`, `npm run start:development` in `/home/evaluation/case-studies/eventbright/backend` (please use two different terminals connected to the same container).
(The PostgreSQL service needs to be running for this application; if it isn't, run `service postgresql start`.)
Navigate to `localhost:3000` on your browser.

**Procedure**: this application is straightforward.
There are event displayed, and you have various options to filter them.
You may want to log in to the demo profile by clicking 'Demo' at the top right.

**To trigger N+1 problems**:

7. search for 'california' (each letter calls the refactored function)
8. navigate to "Charity"
9. click 'music', and search for "f"
10. homepage (i.e., no filters at all, 'All' selected)
11. access demo profile
12. access demo profile (make sure you have liked a few things by clicking the little <3 on a couple events in the dashboard---we used 5 for the test)
13. *can't execute this code, as you cannot get tickets for events in the base DB*

### employee-tracker

**To run**: `npm run test` in `/home/evaluation/case-studies/employee-tracker`. There is no separate front end for this application, as it is a simple CLI to the employee server backend.
(The MySQL service needs to be running for this; if it isn't, run `service mysql start`.)
CLI is available on the terminal.

**Procedure**: this is a CLI dashboard, navigate with arrow keys and select the desired option.

**To trigger N+1 problems**:

14. select 'View All Employees'
15. select 'View All Departments and Their Employees', then choose a department (beware, there is an infinite loop if you do this more than once. Just CTRL+C a few times if you get stuck.)

### property-manage

**To run**: `npm run start:development` in `/home/evaluation/case-studies/property-manage/backend`, `npm run start` in `/home/evaluation/case-studies/property-manage/frontend` (please use two different terminals connected to the same container). 
(The PostgreSQL service needs to be running for this application; if it isn't, run `service postgresql start`.)
Navigate to `localhost:3000` on your browser.

**Procedure**: Click 'Login', click 'Demo User'.
You'll be taken to the main property dashboard.

**To trigger N+1 problems**:

20. *this anti-pattern doesn't seem to trigger, and we didn't count it in the paper*
21. refresh main dashboard

### wall

**IMPORTANT NOTE ON THIS APPLICATION**: please run `nvm use 12` before using this application, as it is only compatible when `node -v` is 12.
Run `nvm use 16` when you are done.

**To run**: `npm run start` in `/home/evaluation/case-studies/wall`, and `npm run start` in `/home/evaluation/case-studies/wall/client` (please use two different terminals connected to the same container).
(The MySQL service needs to be running for this; if it isn't, run `service mysql start`.)

**Procedure**: the first time you start the application, there will be problems, and you will need to make yourself an account (on the left bar, click 'Register').
When we were testing the application, we created an account 'email@email.com', with 'email' as a password.
There may or may not be some cat photos (his name is Virgo)!

**To trigger N+1 problems**:

26. refresh the main page (when we were timing these, we recorded the first matched pair of start and end times, as the application is quite asynchronous)
27. refresh the main page (^)

**Note on Profiling**: in this application, both of the anti-patterns are invoked at the same time.
For logging, we commented and uncommented the logging code in the HTTP request handlers when we wanted to test the other anti-pattern.
They are in files `schema/images.js` and `schema/groups.js`.

### Math_Fluency_App

**To run**: `npm run start` in `/home/evaluation/case-studies/Math_Fluency_App`
(The MySQL service needs to be running for this; if it isn't, run `service mysql start`.)
Navigate to `localhost:3000`.

**Procedure**: this is a dashboard to interact with a teacher + students + tests + results database.
You'll mainly focus on the three requests below.
Click 'GET' next to the request, and then 'Try it out' to the right of the expanded window.
Input the requested id (usually 1) in the field, and click "Execute".

**To trigger N+1 problems**:

17. /results/student/{studentId}/summary with studentId = 1
18. /results/teacher/{teacherId}/summary with teacherId = 1
19. /results/test/{testId}/summary w/ testId = 1

### Graceshopper-Elektra

**To run**: run `npm run start-dev` in `/home/evaluation/case-studies/Graceshopper-Elektra`.
(The PostgreSQL service needs to be running for this application; if it isn't, run `service postgresql start`.)
Navigate to `localhost:3000`.

**Procedure**: at the top right, click 'signup' and create a dummy account (or login with your dummy account).
Click 'plants', also at the top right---from here, you can trigger the N+1 problem as described below.

**To trigger N+1 problems**:

16. add 5 items to card, scroll to bottom of page and hit 'checkout' at bottom right, fill in dummy details, and hit 'confirm order'.

**Notes**: there are some wonky graphics with the Docker version of this application (blue boxes), please ignore.

### NetSteam

**To run**: `npm run start` in `/home/evaluation/case-studies/NetSteam/backend`, `npm run start` in `/home/evaluation/case-studies/NetSteam/frontend` (please use two different terminals connected to the same container).
(The PostgreSQL service needs to be running for this application; if it isn't, run `service postgresql start`.)
Navigate to `localhost:3000`.

**Procedure**: at the top right, click 'Demo' log in as a demo user.
Then, you can click on any of the images to view the user reviews for the game trailer.
(All of the anti-patterns in this application revolve around the reviews.)

**To trigger N+1 problems**:

22. hover over the GTA5 game, and click the 'Show More' button in the right hand listing.
23. submit a review for GTA 5
24. edit your review
25. delete the review you just posted

## **RQ2**

This research question examined if any behavioral differences were introduced by the refactorings.
For **RQ2**, we manually went through each of the anti-patterns discussed in the previous section, and invoked the associated code both before and after refactoring, and visually compared the information that was displayed. 
For convenience, each of the subject applications has an associated GitHub repository with two branches, `orm-refactoring-original` and `orm-refactoring-refactored`. 
These branches are complete with all of the necessary profiling code to collect times and display the generated queries to console.

Thus, to test **RQ2**, chose an application and run it before refactoring by checking out the original branch and then starting it.
For example, with `youtubeclone`:
```
cd /home/evaluation/case-studies/youtubeclone/youtubeclone-backend
git checkout orm-refactoring-original
npm run start
# and also `npm run start` in the frontend!
```
Then, you can navigate to `localhost:3000` in a browser on your home machine and test the application.
When you want to test the refactored code, kill the server (`CTRL-C` in the terminal running the server backend), checkout the refactored code, and restart the server:
```
git checkout orm-refactoring-refactored
# start the application... and also the frontend :-)
```
Then, you can visually compare the results obtained post refactoring with the original results.
There are a few visual glitches in the `youtubeclone` application due to the Cloudinary server not playing nicely with Docker, so do not be alarmed; otherwise the content should match.

## **RQ3**

This research question examined the performance characteristics of the refactored code, and it is divided into two parts.
First, there is a comparison of performance for each of the request handlers between original and refactored code, and then there is the closer look at the performance characteristics of five request handlers at various database sizes.

### General Comparison

The subject applications are equipped with profiling and logging code that records and displays the time taken for each of the handlers under study.
To conduct this phase of the evaluation, we ran each of the handlers with anti-patterns with the original code, and compared the running times reported by the profiling code with the times reported by running the refactored handlers.
Like in **RQ2**, we achieved this by checking out the original and refactored versions in turn (the process for this RQ is the exact same as the previous RQ, the only difference is we read the time reported on the terminal.)
We repeated this process 10 times for each handler, and importantly we killed the server between each try (or did a hard refresh) to avoid caching (browsers are quite smart about caching, this was a reliable way to empty the cache).
Each of the request handlers has a unique terminal message associated with it, so examining the terminal output should be straightforward.
For example, with `youtubeclone`, refreshing or otherwise navigating to the main "Home" dashboard should log "recommendVideos" to console along with a time; before refactoring for our test, this time was ~300ms, and post refactoring it was ~50ms.

### Closer Look

For this phase of **RQ3**, we configured databases for five applications with varying amounts of data (10, 100, and 1000) such that five different HTTP request handlers would need to process that much data.

- `youtubeclone`: search for users;
- `eventbright`: main events display;
- `property-manage`: properties dashboard;
- `employee-tracker`: view all employees;
- `NetSteam`: view all reviews for a trailer.

To conduct this evaluation, we have included various `.env` files in the relevant applications that will point the application to the appropriate database.
These files are: `.env.10` for the 10-scale, `.env.100` for the 100-scale, and `.env.1000` for the 1000-scale, with `.env.basic` for the basic configuration.
These databases have already all been seeded during the configuration of the image.
If you want to test, e.g., `eventbright` at the 1000-scale, you would do:

```
cd /home/evaluation/case-studies/eventbright/backend
git checkout orm-refactoring-original
cp .env.1000 .env # overwrite the basic .env file with the one for the 1000-scale
npm run start
# ...and then start the frontend in a different terminal
```
In our test, loading the main page took a long time, ~3500ms.
Repeating this process after `git checkout orm-refactoring-refactored` yielded a much smaller load time, ~150ms.

To obtain the results in Table 3, we ran each of the affected HTTP request handlers 10 times both before and after refactoring at each scale, performing a hard refresh or killing the server between runs to eliminate caching, and noting the time reported by the profiler each time (written to console).
This is a tedious process, but running the handlers before and after refactoring at the higher scales should show you that speedups are observed (particularly for `youtubeclone`, `eventbright`, and `NetSteam`).

## **RQ4**

To examine page load times, we made use of the Chrome DevTools, which can be accessed from the Chrome web browser.
(Note that you could probably use any web inspector in any browser to verify the results.)
Thankfully, the page load improvements are appreciable to the human eye even without tooling.

To conduct this phase of the evaluation, we proceeded in a similar manner to **RQ3**'s closer look, but instead of noting the time that the HTTP request handlers took to execute, we inspected the page loading behavior using the developer tools.
Concretely, we recorded various aspects of page loading in the 'Performance' tab of the Chrome DevTools, and used the snapshots to estimate when the page was fully loaded.
For example, again with `eventbright` at the 1000-scale, you can open the Inspector in Chrome (right click anywhere on the page, click "Inspect").
You should see a detailed information page open on the right of the browser.
Navigate to the "Performance" tab, and near the top left you should see a three little buttons: a circle, an arrow going in a circle, and a crossed circle.
The second is a button to profile the page refresh, and if you click it the page will refresh and once it is done, a profile of the page loading, including visual snapshots, should be available.
We estimated the time it took from refresh to full data population from this screen, but simply refreshing the page before and after refactoring should give you a sense that the refactoring dramatically improves page loading at larger database sizes.

## **RQ5**

In the last phase of the evaluation, we investigated how long it took our took to run, and we included the package installation time as a reference.
We used the Unix `time` command for this.

### Installation

To get the install time, remove the node modules from a project `rm -rf node_modules` and then `time npm i`.
E.g., with `employee_tracker`:
```
cd /home/evaluation/case-studies/employee_tracker
rm -rf node_modules
time npm i
# Lots of output, including
# real	0m15.548s # wall clock time, irrelevant
# user	0m4.021s  # time taken to deal with user cod
# sys	0m8.097s  # system time
#                 # total time = user time + sys time
```

### QLDB Build Time

To run the query, the QLDB needs to be built for the project being analyzed.
To time it, e.g., with `employee_tracker`:
```
cd /home/evaluation
# Make sure that /home/evaluation/QLDBs/employee-tracker is gone, i.e.,
# rm -rf /home/evaluation/QLDBs/employee-tracker
time ./scripts/make-database.sh ./case-studies/ employee-tracker
```

### Query Run Time

To run the query in earnest, we have the helper script.
You can time it with Unix time, e.g., with `employee_tracker`:
```
time ./scripts/run-query.sh employee-tracker find-sequelize-flows
```
**Note**: the first run ever of the query will take substantially longer as CodeQL needs to compile the QL query.
So make sure to run it once just to shake that out.

### Transformation Time

This is usually basically instantaneous, and we didn't bother counting it.

## Data Description

All of the data we used to create the tables in the paper can be found in `/home/data/ORM_Refactoring_Evaluation.xlsx`.
We recommend you open this in Excel, or in Google Sheets, since there are many subpages, which we describe below.

- Overall Results: here, each HTTP request handler is assigned a unique ID ('ID' column), and links to the handlers in question are present. 
Each request handler can have multiple anti-patterns in it, which are counted in the '# APs' column.
The '# Queries' column states how many queries were generated before and after refactoring (which we counted thanks to the logging we enabled in the projects).
The 'Before Refactoring' column states average and standard deviation of the times taken to fully execute the handler before refactoring, and 'After Refactoring' is the same except targeting the refactored code.
'Perf Factor' states the difference in averages before and after refactoring as a factor.
The final column, 'Notes', is a bit of a misnomer: it's the p-value of a TTest comparing the times drawn before and after refactoring, to confirm the statistical significance of the results.
One handler (getLeases #20) we found ourselves unable to fire, and didn't count it in the paper.
- CSV-Friendly Sheet: same as above, just nicer to export and import into other applications (e.g., R, where we made the plots)
- Raw Times: for each HTTP request (identified by their ID, on the top column), we collected 10 run times before and after refactoring, which are all reported here.
- Raw Times (for Supplemental): same as above, easier to export.
- Scaling DB Size Experiment: for each of the five HTTP request handlers in the five applications we selected for our closer look, this sheet reports the times before and after and at the various DB scales. 
Means and StDevs are reported as well.
- Scaling_DB_Size_Experiment_Supplemental: easier exporting.
- Page Load Experiment: for each of the four applications we investigated page load performance, results are reported here at all database scales. 
A result of * indicates that data loading was complete before animations were completed, so it was not possible to gauge exactly the time.
- Tool Run Time: lists the running time of the tool in the right hand table.
The left-hand stuff is a parser for the raw output.
- Tool Run Times (Raw): the raw tool run times, copy-pasted from terminal.
- Result Sizes: the number of anti-patterns in various projects.
- AP Distribution: the distribution of different types of Select N+1 problems across our subject applications.

# Detailed Artifact Description 

This artifact is a full-featured docker image containing all of what is necessary to run most JavaScript web applications.
`mysql` and `postgresql` servers can be run in the container such that any database-backed web applications can interact with them.
The image is provisioned with 8 JavaScript web applications that can be run out-of-the-box, and the container exposes two ports to the system running it so that the web applications can be accessed from the user's machine.

The `/home/reformulator` directory contains the source code for the `reformulator` tool: in `./reformulator-analysis`, the static analysis to detect dataflow between two ORM API calls is expressed in QL, the query language for CodeQL, and in `./orm-refactoring` the code transformation is implemented as a JavaScript application using the Babel parser and AST transformer.
The `/home/evaluation` directory contains the evaluation for our tool: `./case-studies` has the 8 aforementioned web applications, `./QLDBs` stores the CodeQL databases for each of them, `./query-results` contains the results of running the QL dataflow analysis on the projects, and `./scripts` contains a number of helpful scripts.
Last but not least, `/home/data` contains the data we used to make the tables in the paper.

# Extending the Artifact

Any researchers or developers looking to prototype JavaScript tooling for database-backed web applications may benefit from this artifact.
JavaScript projects are very annoying to set up, and particularly random web applications taken from GitHub; this artifact has eight such projects configured with multiple databases of various sizes. 

## Additional Subject Applications

If a user would like to add projects to the Docker image, they can simply clone them into `/home/evaluation/case-studies/`.
All of the convenience scripts we included work with the directory structure as it is in the container, so as long as new projects are added to that directory things should just work.
The helper scripts that the Dockerfile makes reference to are documented, so a motivated user should be able to even extend the image permanently with additional projects by modifying `makeEvaluation.sh` and `setupProjects.sh`.
