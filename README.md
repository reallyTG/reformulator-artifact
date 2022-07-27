# reformulator-artifact

Self-contained code artifact to run the *Reformulator* Sequelize ORM API refactoring tool.
This implements the approach discussed in the ASE'22 paper *"Reformulator: Automated Refactoring of the N+1 Problem in Database-Backed Applications"* by Turcotte et al.
This artifact is being evaluated in the ASE'22 Artifact track.

### Table of Contents

1. Notes
2. Building the Image
3. Running the Image
4. Gist / Sanity Check / Kick-the-Tires

# NOTES

If you're building this locally, make sure to `chmod +x setupCodeQL.sh makeEvaluation.sh`, otherwise Docker can't run it.

# Building the Image

To build the artifact, simply run:

```
git clone <this repo>
cd reformulator-artifact
docker build -t reformulator .
```

**If you are coming from Zenodo**: instead, simply navigate into the reformulator-artifact directory, and run `docker build -t reformulator .`. 

# Running the Image

The following command will launch the Reformulator Docker container, and gives you a bash CLI.

```
docker run -t -i reformulator
```

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
    # Then after a time should write "[1/1 eval 9.7s] Evaluation done; writing results to [...]"
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

Concretely, to transform `youtubeclone`: 
```
node /home/reformulator/orm-refactoring/dist/transform.js --mode=CodeQL \
    --pathTo=/home/evaluation/case-studies/youtubeclone/youtubeclone-backend/ \
    --flows=/home/evaluation/query-results/find-sequelize-flows/youtubeclone-backend.csv \
    --models=/home/evaluation/case-studies/youtubeclone/youtubeclone-backend/src/models/ \
    --sequelize-file=/home/evaluation/case-studies/youtubeclone/youtubeclone-backend/src/sequelize.js
```

You should see the following terminal output:

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

