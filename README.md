# **terrarium**

<table style="width: 100%; border-style: none;"><tr>
<td style="width: 140px; text-align: center;"> <img width="128px" src="docs/images/terrarium.png" alt="terrarium logo"/></a></td>
<td>
<strong>terrarium Developer Environment</strong><br />
<i>An immutable Developer Environment for developers working with <b><a href="https://www.opendevstack.org/">OpenDevStacks'</a></b> Cloud Quickstarters.
</td>
</tr></table>

With **terrarium** we offer an immutable Developer Environment for developers working with  **[OpenDevStack](https://www.opendevstack.org/)** projects. **terrarium** provides the same environment which is used to deploy AWS or AZURE components via ODS.

By using the Visual Studio Code Remote - Containers extension it enables the developer to open cloud component repositories inside a container and take advantage of Visual Studio Code's full feature set. 

This repository contains an example container definition to help get you up and running with **terrarium**. The definition describes the appropriate container image and VS Code extensions that should be installed. A container configuration file (devcontainer.json) and other needed files that you can drop into any existing folder as a starting point for containerizing your project.

## Usage

If the Cloud Quickstarter does not contain it already simply create a [`.devcontainer`](.devcontainer) directory and put the devcontainer.json into it.
```json
{
  "image": "ghcr.io/nichtraunzer/terrarium:latest"
}
```
## Contents

- [`.devcontainer`](.devcontainer) - Contains a plain devcontainer.json eample.
- [`examples`](examples) - Contains a more sophisticated example.
- [`terraform`](terraform) - Contains the Docker file.
- [`tools`](tools) - Contains an additional prompt example.


## Update the terrarium tools

The tools and libraries of the terrarium toolset have to be updated from time to time.
The following steps have to be performed:
- Check for new versions of tool variables *_VERSION in i[Dockerfile.terrarium](./terraform/docker/Dockerfile.terrarium)
- Check for new versions of python libraries in file [python_requirements](./terraform/docker/python_requirements) (might depend on Python Version)
- Check for new versions of the ruby Gems in [Gemfile](./terraform/docker/Gemfile)
- Rebuild the container image
  `$ DOCKER_BUILDKIT=1 docker build -t terrarium:update-tools -f ./Dockerfile.terrarium .` 
- Mount the folder with the new toolset and rebuild Gemfile.lock from scratch using `bundle install --jobs=22`
- verify updates with ods-quickstarters/inf-terraform-[aws|azure]
  `docker run -ti --user 1000 -v $HOME/.bash_history:/home/terrarium/.bash_history -v`pwd`:/workspace -v $HOME/.gitconfig:/home/terrarium/.gitconfig -v $HOME/.cache/git/credential/socket:/home/terrarium/.cache/git/credential/socket terrarium:tools-update /bin/bash`
- commit & push changes & create pull request
