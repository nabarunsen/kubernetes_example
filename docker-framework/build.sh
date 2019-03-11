#!/bin/bash
 
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    SCRIPT_NAME=$(basename $0)
    BUILD_DIR=${SCRIPT_DIR}
    DOCKER_REG=${DOCKER_REG:-docker-repo:8081}
    DOCKER_USR=${DOCKER_USR:-admin}
    DOCKER_PSW=${DOCKER_PSW:-password}
    GRADLE_REPO=${gradle-release}
    DOCKER_REPO=${DOCKER_REPO:-docker}
    WORKSPACE="/var/lib/jenkins/workspace/docker-framework/docker-framework"
    ARTFACTORY_URL=${ARTFACTORY_URL:-http://172.31.8.155:8081/artifactory}
 
               
    cd ${WORKSPACE}
               
    echo -e "\nDocker login"
 
    if [ ! -z "${DOCKER_REG}" ]; then
    
        if [ -z "${DOCKER_USR}" ] || [ -z "${DOCKER_PSW}" ]; then
            errorExit "Docker credentials not set (DOCKER_USR and DOCKER_PSW)"
        fi
        docker login -u ${DOCKER_USR} -p ${DOCKER_PSW} ${DOCKER_REG}/${DOCKER_REPO}  || errorExit "Docker login to ${DOCKER_REG} failed"
                               
    else
        echo "Docker registry not set. Skipping"
    fi
 
    echo -e "\nBuilding ${DOCKER_REPO}/docker-framework:latest and pushing to the docker registry"
    curl -u ${DOCKER_USR}:${DOCKER_PSW} $ARTFACTORY_URL/tomcat/apache-tomcat-8.0.32.tar -o $BUILD_DIR/apache-tomcat-8.0.32.tar.gz           
    curl -u ${DOCKER_USR}:${DOCKER_PSW} $ARTFACTORY_URL/tomcat/jdk-8u91-linux-x64.tar -o $BUILD_DIR/jdk-8u91-linux-x64.tar                           
    docker build -t ${DOCKER_REG}/${DOCKER_REPO}/docker-framework:latest ${WORKSPACE} || errorExit "Building ${DOCKER_REPO}/${DOCKER_REPO}/docker-framework:${DOCKER_TAG} failed"           
    docker tag ${DOCKER_REG}/${DOCKER_REPO}/docker-framework:latest ${DOCKER_REG}/${DOCKER_REPO}/docker-framework:latest          
    docker push ${DOCKER_REG}/${DOCKER_REPO}/docker-framework:latest
 
    
 
