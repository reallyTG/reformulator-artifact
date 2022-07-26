# reformulator-artifact
Artifact for Reformulator ASE'22 paper.

# NOTE

If you're building this locally, make sure to `chmod +x setupCodeQL.sh makeEvaluation.sh`, otherwise Docker can't run it.

# Building the Image Locally

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

### 1. Run CodeQL

*Reformulator* has two phases: first, dataflow between ORM API calls are detected via analysis, and then related ORM API calls are transformed.
This section describes how to detect the dataflows using CodeQL.

1.  CodeQL runs on a database built up from the source code.
    (For the interested, the database contains an AST representation of the code, as well as control flows and data flows.)
    To build this database, we included a convenience script `/home/evaluation/scripts/make-database.sh` which takes two arguments: the path to the code, and the name of the project.
    For the purpose of this example, navigate to the `evaluation` directory and run `make-database.sh`:

```
cd /home/evaluation
./scripts/make-database.sh ./case-studies/youtubeclone/ youtubeclone-backend
```
    This should produce a bunch of terminal output, with "Successfully created database at /home/evaluation/QLDBs/youtubeclone-backend" at the end.