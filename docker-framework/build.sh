#!/bin/bash


DOCKER_REG="docker-repo:8081"
DOCKER_USR="admin"
DOCKER_PSW="password"
GRADLE_REPO="gradle-release"
DOCKER_STAGE_REPO="docker-stage-local"
DOCKER_REPO="docker"
DOCKER_PROD_REPO=$"docker-prod-local"
DOCKER_TAG="docker-framework"
WORKSPACE="/var/lib/jenkins/workspace/docker-framework/docker-framework"
ARTFACTORY_URL="http://172.31.9.131:8081/artifactory"
TOMCAT_REPO="tomcat"


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

main () {
    echo -e "\nRunning"

    echo "DOCKER_REG:   ${DOCKER_REG}"
    echo "DOCKER_USR:   ${DOCKER_USR}"
    echo "DOCKER_REPO:  ${DOCKER_REPO}"
    echo "DOCKER_TAG:   ${DOCKER_TAG}"

    # Cleanup

    # Build and push docker images if needed
   
        buildDockerImage
        dockerLogin
        pushDockerImage
    

}

############## Main

main
