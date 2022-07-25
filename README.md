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
