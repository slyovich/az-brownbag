resourceGroupName = "ARG-DEMO-BROWNBAG-CHN-01"

container-app-environment-id = "<YOUR-CONTAINER-APP-ENVIRONMENT-ID>"

container-app = {
    name = "app-demo-brownbag-01"
    image-name = "docker-github-runner"
    image = "ghcr.io/slyovich/az-brownbag/docker-github-runner"
    tag = "2.302.1"
    secrets = [ 
        {
            name = "gh-token"
            value = "<YOUR-GITHUB-RUNNER-TOKEN>"
        },
        {
            name = "gh-registry-token"
            value = "<YOUR-GITHUB-READ-PACKAGES-TOKEN>"
        }
    ]
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