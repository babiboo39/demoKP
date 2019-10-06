#!/bin/bash

function specifyBuildTool() {
    if [ -f pom.xml ]; then
        echo "mvnw"
    elif [ -f build.gradle ]; then
        echo "gradlew"
    else
        echo "Can not specify build tool"
    fi
}

function specifyEnvName() {
    if [[ ${GIT_BRANCH} == *'feature'* ]] || [[ ${GIT_BRANCH} == *'hotfix'* ]] || [[ ${GIT_BRANCH} == *'bugfix'* ]]; then
        echo 'feature'
    elif [[ ${GIT_BRANCH} == *'master' ]]; then
        echo 'alpha'
    else
        echo 'build not allowed in this branch'
    fi
}

param=$1

case $param in
    specifyBuild)
        specifyBuildTool
        ;;
    specifyEnv)
        specifyEnvName
        ;;
    *)
        echo "No such function that refers to the parameter"
        ;;
esac