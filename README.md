# hsl-open-data-api-demo
A repository for demonstrating basic API tests creation using HSL API.

# What is aimed to be demonstrated in this project?

    High-quality, Cloud-native Python test application creation

Sections:

- [Basic API test using Robot Framework & Pytest](#basic-api-test-using-robot-framework--pytest)
- [Advanced Docker image creation](#advanced-docker-image-creation)
- [Dependency management](#dependency-management)
- [Maintaining high quality of the code](#maintaining-high-quality-of-the-code)
- [Github CI implementation](#github-ci-implementation)
- [Development environment as a code](#development-environment-as-a-code)

## Basic API test using Robot Framework & Pytest

In the test, it is tested that randomly picked public transport stops are visible in the API reponse that
is got from HSL API after sending a graphql POST request query to the HSL API server.

- Basic API test using robot framework is done in [test_stops.robot](hsl-api/tests/robot/test_stops.robot).
- Basic API test using pytest is done in [test_stops.py](hsl-api/tests/pytest/test_stops.py).

Both of these tests use [init_vars.py](hsl-api/tests/init_vars.py) file that makes it easy
to define secrets and more complex variable definitions.

To make the test easily debuggable, a configuration named `dev only: robot-tests-lsp-protocol`
is defined to a [launch.json](.vscode/launch.json) file that can be used to execute the tests with a debugger.
Similar configuration is also defined to the pytest.
When using VsCode, one can simply
1. Press `Ctrl + Shift + D` key combination to open the debugger
2. Select the configuration from the dropdown menu
3. Press `F5` to execute the robot
tests using a debugger.

Additionally, a [launcher](execute_tests.py) was developed that uses the arguments that are
defined to the [launch.json](.vscode/launch.json) file. This way, production and development
way of executing the test is aligned and scenarios where test works in development environment
but not in production environment are reduced.

## Advanced Docker image creation

[Dockerfile](Dockerfile) defines the image that is used for executing the developed application
and tests. In the Dockerfile, there are three stages named
- `main-build`
- `dev-tests-build`
- `dev-env-build`

By using the stages in Docker image building, it is possible to optimize the image size
that is needed for executing each test or functionality. `main-build` will only execute
the actual tests that are developed in this repository. However, because it is desired to
re-use the production environment basis for executing the development related tests, there
are two additional stages introduced.

`dev-tests-build` is a stage that will be used to execute code-quality related tests, i.e.
linter tests. It is also used to test that python dependencies are the latest available version to
ensure that project will remain maintainable.

`dev-env-build` stage is used to generate a development environment for the developer. This
is convenient because now developer uses the exactly same environment basis as the tests
that are executed in the Github servers. This is intended to be used only locally.

In the [Github workflow](.github/workflows/workflow.yaml) file, only `main-build` and `dev-tests-build`
are used. This way, image sizes are optimized like visible in the below comparison. This
reduces the waiting times in building and pushing phases.

    REPOSITORY           TAG               IMAGE ID       SIZE
    hsl-open-api-demo    main-build        32bd9716c960   1.03GB
    hsl-open-api-demo    dev-tests-build   bb9273cf25ce   1.1GB
    hsl-open-api-demo    dev-env-build     3cd872322482   1.41GB

## Dependency management

In the [Github workflow](.github/workflows/workflow.yaml) file, there is a script defined
that will ensure that python dependencies are up to date which will increase maintainablity
and security of the project.

      - run: |
          pip-compile -o requirements_new.txt requirements.in > /dev/null 2>&1
          diff --brief <(grep -v '#' requirements.txt) <(grep -v '#' requirements_new.txt)
      - run: |
          pip-compile -o requirements-dev_new.txt requirements-dev.in > /dev/null 2>&1
          diff --brief <(grep -v '#' requirements-dev.txt) <(grep -v '#' requirements-dev_new.txt)

In short, it will check if the requirement files are changed by pip-compile when those are generated
again from the base requirements. It will ignore lines with comments.


**Funnily enough, it already caught a dependency issue in this**
**[commit](https://github.com/jkmetsola/hsl-open-data-api-demo/commit/d23ecd074acbb81e7667df004e3f4c2f825d2abe)|[test](https://github.com/jkmetsola/hsl-open-data-api-demo/actions/runs/8951016019/job/24602982676) which was fixed in this**
**[commit](https://github.com/jkmetsola/hsl-open-data-api-demo/commit/782cdea078779771b8bffa656fc3260c0a031930)|[test](https://github.com/jkmetsola/hsl-open-data-api-demo/actions/runs/8958683205/job/24603199847).**



## Maintaining high quality of the code

In order to maintain high quality of the code or rather assert it, there are static code-quality
analysis tools installed i.e. 'linters' and those are executed as a part of [Github workflow](.github/workflows/workflow.yaml)
tests. Those tools are
 - robotidy
 - robocop
 - ruff check
 - ruff format
 - shellcheck
 - hadolint
 - actionlint

## Github CI implementation

This repository uses [Github workflow](.github/workflows/workflow.yaml) to establish a simple, yet efficient CI pipeline.
It is highly maintainable CI system solution compared to e.g. Jenkins that usually has massive
amount of different dependencies plus it requires an own master-server & agents for execution.

There are two different workflows. In the [main workflow](.github/workflows/workflow.yaml)
`image building`, `tests`, and `dev tests` are executed. `tests` and `dev tests` are using
 the Docker image stages that are built using the Dockerfile located in this repository.
 The main workflow will be executed in case of `pull request` or `push` to the `main` branch.

The [release workflow](.github/workflows/workflow-release.yaml), will build the main build
without the `-test` postfix and release the image to the dockerhub. This workflow will run
only when there is a push to the main branch.

## Development environment as a code

As mentioned earlier in the [Advanced Docker image creation](#advanced-docker-image-creation)
section, there is a special `dev-env-build` stage in the Dockerfile intended to be used for local development.
VsCode offers excellent tools to use this kind of dev-container for development.

Basically the development environment is defined to [devcontainer.json](.devcontainer/devcontainer.json)
and [Dockerfile](Dockerfile) which makes it highly reproducible environment and greatly
reduces the `"working in my environment"` syndrome.


# How to use built-in development environment?

This development environment is designed to be used with Linux OS that has Docker installed in it.
Development can be done by using `.devcontainer/devcontainer.json` which has definitions
for establishing development container. ms-vscode-remote.remote-containers extension is needed.

When VsCode IDE is open, do the following: <br>
`Ctrl + Shift + P`<br>
`Dev Containers: Rebuild and Reopen in Container`

Refer to https://code.visualstudio.com/docs/devcontainers/create-dev-container for further instructions.

    Note: Docker should be installed to the host machine in order for this to work.

# Main references:

https://digitransit.fi/en/developers/apis/1-routing-api/0-graphql/#creating-and-sending-queries
<br>
https://digitransit.fi/en/developers/apis/1-routing-api/#endpoints
<br>
https://digitransit.fi/en/developers/apis/1-routing-api/#api-requirements
<br>
https://digitransit.fi/en/developers/api-registration/#use-of-api-keys