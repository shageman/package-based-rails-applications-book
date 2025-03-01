# Source Code to _Package-Based Rails Applications_ by Stephan Hagemann

This repository holds the source code used in my book on Package-based Rails Applications.

It is organized by chapter and section encoded as _cXs0Y_ for "Chapter X, Section Y." If a section adds no code that is
specific to it, it may use the source code from the last section preceding it that does have source code samples attached.

Because the Ruby and Rails ecosystems are moving so rapidly, creating a book about high-level structural concepts is
tough when underlying libraries constantly require subtle changes to the sample code. To this end, all source code packages its gem dependencies.

## References

* [Get the book!](https://gradualmodularity.com)
* [stephanhagemann.com](http://stephanhagemann.com) - the author's website

## Development

The `docker` and `generator_scripts` folders are for development of the chapter samples. In fact, all of the samples
were generated via script in a concourse pipeline. I.e., every transformation described in a chapter
can be executed via the shell script belonging to that chapter.

*These instructions assume that you have [docker](https://www.docker.com/) running on OSX.*

### Starting Concourse on Docker

[Concourse](https://github.com/concourse/concourse) acts as our CI server, which will run the pipeline.
You will need to add S3 secrets to the config in `pipeline-secrets.yml` to give the pipeline a place to store the outputs :

~~~~~~~~
---
private_key: YOUR_KEY_TO_GIT_REPO
aws_key: YOUR_KEY
aws_secret: YOUR_SECRET
s3_endpoint: https://s3.us-east-1.amazonaws.com
~~~~~~~~

In one terminal execute the following to install and run the needed docker containers.
~~~~~~~~
CONCOURSE_RUNTIME=containerd docker-compose up -d
~~~~~~~~

This will bring up Concourse at [http://localhost:8080/](http://localhost:8080/).

If any of the containers fail to start, please check the docs of the docker images used for updates to their respective config:

* [concourse docker](https://github.com/concourse/concourse-docker)

### Get the Pipeline Running

Concourse gets configured via its [fly CLI](https://concourse-ci.org/fly.html). Download it [here](https://concourse-ci.org/download.html). Or on Mac with brew installed via `brew cask install fly`.

To point fly at the locally running instance of concourse, first do this (and follow the instructions on screen). The above concourse installation gave you a user `test` with password `test`.
~~~~~~~~
fly --target local login --team-name main --concourse-url http://localhost:8080
~~~~~~~~

Then, to configure and start the pipeline
~~~~~~~~
fly -t local set-pipeline -p pipeline -c pipeline.yml --load-vars-from  pipeline-secrets.yml
fly -t local unpause-pipeline -p pipeline
fly -t local trigger-job -j pipeline/c2s01
~~~~~~~~

Now, navigating to [http://localhost:8080/teams/main/pipelines/pipeline](http://localhost:8080/teams/main/pipelines/pipeline) will show the running pipeline.

The output of the pipeline is *all* of the versions of the Sportsball codebase discussed in the book. Specifically, the output is a series of zip files in `./docker/minio/data/releases` - one zip file for each chapter / step of the pipeline.

### Updating the version of Rails to run against

The folder `code/docker/minio/data/releases` contains a couple of files named `app_XYZ.tgz`. These are archives of empty starter apps. These are empty Rails apps with just a few gems added (generated by `code/generator_scripts/ci/generate-code.sh`). For the rest of the pipeline, this locks down the dependencies that will be used for the generation of the chapter code.

You can manually start the `generate-empty-app` concourse step to generate an empty app with the current version of Rails and the other dependencies of the app.

Every run of the chapter-generation pipeline will use the latest version of Rails found in this folder. If you happen to delete all of the app archives, the chapter-generation pipeline will not work. In that case, either generate a new empty app or reset to the state of this repo to get the pipeline running again.

### Building a new base image

On an amd64-based machine running docker, run

```
docker build -t shageman/ruby33-sorbet:VERSION .
```

When you have a good new build, publish it using the following command. Be sure to increment the version number based on what has already been published: https://hub.docker.com/r/shageman/ruby33-sorbet/tags

```
docker push shageman/ruby33-sorbet:VERSION
```