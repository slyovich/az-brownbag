resourceGroupName = "ARG-DEMO-BROWNBAG-CHN-01"

containerAppEnvironmentName = "appenv-demo-brownbag-01"

containerApp = {
    name = "app-demo-brownbag-01"
    image-name = "docker-github-runner"
    image = "ghcr.io/slyovich/az-brownbag/docker-github-runner"
    tag = "2.302.1"
    env = [ 
        {
            name = "GH_OWNER"
            value = "slyovich"
        },
        {
            name = "GH_REPOSITORY"
            value = "az-brownbag"
        },
        {
            name = "GH_TOKEN"
            secretRef = "gh-token"
        }
    ]
    registry = {
        server = "ghcr.io"
        username = "slyovich"
        passwordSecretRef = "gh-registry-token"
    }
}

githubRunnerToken = "<YOUR-GITHUB-RUNNER-TOKEN>"
githubRegistryToken = "<YOUR-GITHUB-READ-PACKAGES-TOKEN>"

storageName = "asademobrownbag01"