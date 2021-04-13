# dkgit

thin wrapper around git (**particularly older versions of git**) which causes it to use the ssh identity file found at `$(pwd)/.git_deploy_key` (controllable with `$GIT_DEPLOY_KEY`)

Don't commit keys to repos. This is not about that. This script can be useful when you have things like automated git pulls which use special-purpose github deploy keys.

Since version 1, git has supported the `GIT_SSH` envvar, which lets you specify a path to an executable. BUT the envvar cannot contain arguments for SSH... just a path. This script utilizes this envvar.

---

With more modern versions of git you don't need this script:

* (git >= 2.3.0) supports the `GIT_SSH_COMMAND` environment variable (which allows the arguments that `GIT_SSH` forbids)

    ```sh
    GIT_SSH_COMMAND="ssh -i $GIT_DEPLOY_KEY -F /dev/null"
    # ...or more directly...
    GIT_SSH_COMMAND="ssh -i $(pwd)/.git_deploy_key -F /dev/null"
    ```

* (git >= 2.10.0) is **EVEN BETTER**! you can set the ssh identity file for a specific git working directory by setting core.sshCommand in the local config file:

    ```sh
    $ git config --local \
      core.sshCommand \
      "ssh -i $(pwd)/.git_deploy_key -F /dev/null"
    ```

The excellent answers at this stack overflow question really helped me out with this: <https://superuser.com/questions/232373/how-to-tell-git-which-private-key-to-use/>


## Example Usage:

1. generate an ssh key:

    ```sh
    $ ssh-keygen \
      -t ed25519 \
      -P "" \
      -C "deploy key; host:$(hostname); subject:$(pwd)" \
      -f .git_deploy_key
    ```

2. Give the pub key to your git host

3. Use dkgit instead of using git directly:

    ```sh
    $ dkgit clone git@example.com/turtles/turtle_server.git
    ```
