# More about the Examples

This readme explains the file(s) that are in the `examples` directory.

## The file `devcontainer.json`

The file should be located at `.devcontainer/devcontainer.json`. It defines what Visual Studio Code needs to do / provide to enable developing inside of a docker container.

The below code is showing what you find in the example file and explains what each entry is used for.

Please note: `json` files do not support comments. That is why you should use the content of the file `devcontainer.json` in this folder and not just copy the below snippet into a file.

### Explaining the example file

```javascript
{
  // the "image" property defines the docker image that should be used as development container
  "image": "ghcr.io/nichtraunzer/terrarium:latest",

  // this "postStartCommand" adds git completion
  "postStartCommand" : "wget -O $HOME/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash",

  // inside the "containerEnv" object we add the environment variables that should be available inside of the container
  "containerEnv": {
    "AWS_DEFAULT_REGION": "eu-west-1",
    "AWS_REGION": "eu-west-1"
  }
}
```

### Customizing the Starship prompt

The base image ships with a default `starship.toml` configuration at
`~/.config/starship.toml` and initializes both starship and zoxide
automatically.

To override the default prompt, place your own `starship.toml` alongside
this `devcontainer.json` and use a `Dockerfile` to copy it:

```dockerfile
FROM ghcr.io/nichtraunzer/terrarium:latest
COPY starship.toml /home/terrarium/.config/starship.toml
```

Then reference the Dockerfile from your `devcontainer.json`:

```jsonc
{
  "build": {
    "dockerfile": "Dockerfile"
  }
}
```
