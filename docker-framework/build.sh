#!/bin/bash


DOCKER_REG=${DOCKER_REG:-docker-repo:8081}
DOCKER_USR=${DOCKER_USR:-admin}
DOCKER_PSW=${DOCKER_PSW:-password}
GRADLE_REPO=${GRADLE_REPO:-gradle-release}
DOCKER_STAGE_REPO=${DOCKER_STAGE_REPO:-docker-stage-local}
DOCKER_PROD_REPO=${DOCKER_PROD_REPO:-docker-prod-local}
DOCKER_TAG={$DOCKER_TAG:-docker-framework}
WORKSPACE="/var/lib/jenkins/workspace/docker-framework/docker-framework"
ARTFACTORY_URL=${ARTFACTORY_URL:-http://172.31.8.155:8081/artifactory}
TOMCAT_REPO=${TOMCAT_REPO:-tomcat}

errorExit () {
      echo -e "\nERROR: $1"; echo
      exit 1
}

usage () {
      cat << END_USAGE

      ${SCRIPT_NAME} - Script for building the Gradle-Build web application in Ubuntu, Tomcat Container with Docker image and Kubernetes Helm chart

      Usage: ./${SCRIPT_NAME} <options>

      --build             : [optional] Build the Docker image
      --push              : [optional] Push the Docker image

      -h | --help         : Show this usage

      END_USAGE

          exit 1
}

# Docker login
dockerLogin () {
      echo -e "\nDocker login"
      cd ${WORKSPACE}
      if [ ! -z "${DOCKER_REG}" ]; then

          if [ -z "${DOCKER_USR}" ] || [ -z "${DOCKER_PSW}" ]; then
              errorExit "Docker credentials not set (DOCKER_USR and DOCKER_PSW)"
          fi
          docker login -u ${DOCKER_USR} -p ${DOCKER_PSW} ${DOCKER_REG}/${DOCKER_REPO}  || errorExit "Docker login to ${DOCKER_REG} failed"
                                 
      else
          echo "Docker registry not set. Skipping"
      fi
}

# Build Docker images
buildDockerImage () {

      echo -e "\nBuilding ${DOCKER_REPO}/${DOCKER_TAG}:latest and pushing to the docker registry"
      echo -e "\n"
      
      echo -e "\nDownload Tomcat and Java from Tomcat Repository"
      
      curl -u ${DOCKER_USR}:${DOCKER_PSW} $ARTFACTORY_URL/${TOMCAT_REPO}/apache-tomcat-8.0.32.tar -o ${WORKSPACE}/apache-tomcat-8.0.32.tar.gz           
      curl -u ${DOCKER_USR}:${DOCKER_PSW} $ARTFACTORY_URL/${TOMCAT_REPO}/jdk-8u91-linux-x64.tar -o ${WORKSPACE}/jdk-8u91-linux-x64.tar       

      echo -e "\n"
      echo -e "\nBuilding Docker Container and Pushing to Stage Repository "
                          
      docker build -t ${DOCKER_REG}/${DOCKER_REPO}/${DOCKER_TAG}:latest ${WORKSPACE} || errorExit "Building ${DOCKER_REPO}/${DOCKER_REPO}/docker-framework:${DOCKER_TAG} failed"           
      docker tag ${DOCKER_REG}/${DOCKER_REPO}/${DOCKER_TAG}:latest ${DOCKER_REG}/${DOCKER_STAGE_REPO}/docker-framework:latest          
      
}

# Push Docker images
buildProdDockerImage () {
      docker tag ${DOCKER_REG}/${DOCKER_STAGE_REPO}/docker-framework:latest  ${DOCKER_REG}/${DOCKER_PROD_REPO}/${DOCKER_TAG}:latest
      docker push ${DOCKER_REG}/${DOCKER_PROD_REPO}/${DOCKER_TAG}:latest || errorExit "Pushing ${DOCKER_REPO}:${DOCKER_TAG} failed"
}


processOptions () {
    if [ $# -eq 0 ]; then
        usage
    fi

    while [[ $# > 0 ]]; do
        case "$1" in
            --build)
                BUILD="true"; shift
            ;;
            --push)
                PUSH="true"; shift
                
            --registry)
                DOCKER_REG=${2}; shift 2
            ;;
            --docker_usr)
                DOCKER_USR=${2}; shift 2
            ;;
            --docker_psw)
                DOCKER_PSW=${2}; shift 2
            ;;
            --tag)
                DOCKER_TAG=${2}; shift 2  
            ;;
            -h | --help)
                usage
            ;;
            *)
                usage
            ;;
        esac
    done
}

main () {
    echo -e "\nRunning"

    echo "DOCKER_REG:   ${DOCKER_REG}"
    echo "DOCKER_USR:   ${DOCKER_USR}"
    echo "DOCKER_REPO:  ${DOCKER_REPO}"
    echo "DOCKER_TAG:   ${DOCKER_TAG}"

    # Cleanup

    # Build and push docker images if needed
    if [ "${BUILD}" == "true" ]; then
        buildDockerImage
    fi
    if [ "${PUSH}" == "true" ]; then
        # Attempt docker login
        dockerLogin
        pushDockerImage
    fi

}

############## Main

processOptions $*
main
