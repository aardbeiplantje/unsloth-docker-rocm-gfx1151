group "default" {
  targets = ["local"]
}
group "release" {
  targets = ["containers"]
}
group "local" {
  targets = ["_local"]
}
variable "DOCKER_REGISTRY" {
  default = "ghcr.io"
}
variable "DOCKER_REPOSITORY" {
  default = "ai"
}
variable "DOCKER_IMAGE_NAME" {
  default = "unsloth-gfx1151"
}
variable "DOCKER_TAG" {
  default = "latest"
}
variable "CACHEBUST" {
  default = "1"
}
variable "ROCM_PATH" {
  default = "/opt/rocm"
}
target "_common" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64"]
  networks = ["host"]
  buildkit = true
  entitlements = ["security.insecure"] 
  contexts = {
    rocmdata = "${ROCM_PATH}"
  }
}
target "_local" {
  inherits = ["_common"]
  target = "runtime"
  tags = [
    "local/${DOCKER_REPOSITORY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}",
  ]
  output = [
    "type=docker,name=local/${DOCKER_REPOSITORY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
  ]
}
