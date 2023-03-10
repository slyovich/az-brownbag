resourceGroupName = "ARG-DEMO-BROWNBAG-CHN-03"

containerAppEnvironment = {
    name = "appenv-demo-brownbag-01"
    resource-group-name = "ARG-DEMO-BROWNBAG-CHN-02"
}

containerApp = {
    name = "app-demo-brownbag-01"
    image-name = "docker-github-runner"
    image = "ghcr.io/slyovich/az-brownbag/docker-github-runner"
    tag = "2.302.1"
    registry = {
        server = "ghcr.io"
        username = "slyovich"
    }
}

githubRunnerToken = "<YOUR-GITHUB-RUNNER-TOKEN>"
githubRegistryToken = "<YOUR-GITHUB-READ-PACKAGES-TOKEN>"

storageName = "asademobrownbag01"