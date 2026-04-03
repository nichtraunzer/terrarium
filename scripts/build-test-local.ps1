export DOCKER_BUILDKIT=1
# export TERRARIUM_BASE_IMAGE=ghcr.io/nichtraunzer/terrarium
export TERRARIUM_BASE_IMAGE=ghcr.io/effektiv-ai/terrarium-security-hardening
# BASE_TAG=4.6.4
BASE_TAG=latest-linux-amd64



# STAGE 1
cd /workspaces/ec2-user/current/terrarium-security-hardening/docker
# STAGE 1 Build the **upstream** image locally
docker build --target test -f Dockerfile.terrarium \
  -t ${TERRARIUM_BASE_IMAGE}:${BASE_TAG} \
  --build-arg DEVTOOLS_GID=2001 \
  .


# STAGE 1 Run tests in the upstream image
docker run --rm -it ${TERRARIUM_BASE_IMAGE}:${BASE_TAG} bash -lc '
  bats --report-formatter junit /home/terrarium/tests --output /home/terrarium
'

