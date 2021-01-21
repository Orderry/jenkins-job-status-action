#!/bin/bash

[[ -z "${INPUT_JOB_NAME}" ]] && echo "Job name not set" && exit 1 || jobname="${INPUT_JOB_NAME}"
[[ -z "${INPUT_BRANCH_NAME}" ]] && echo "Branch name not set" && exit 1 || branch="${INPUT_BRANCH_NAME}"
[[ -z "${INPUT_JENKINS_USER}" ]] && echo "Jenkins user not set" && exit 1 || jenkinsuser="${INPUT_JENKINS_USER}"
[[ -z "${INPUT_JENKINS_TOKEN}" ]] && echo "Jenkins token not set" && exit 1 || jenkinstoken="${INPUT_JENKINS_TOKEN}"
[[ -z "${INPUT_JENKINS_URL}" ]] && echo "Jenkins URL not set" && exit 1 || jenkinsurl="${INPUT_JENKINS_URL}"

buildstatus=$(curl --silent -u $jenkinsuser:$jenkinstoken $jenkinsurl/$jobname/$branch/api/json | jq -r '.color')

echo "::set-output name=status::$buildstatus"

if [ "$buildstatus" == "notbuilt_anime" ]; then
    message="Environment already running 👟. Will be restarted from last branch commit 🔁"
    echo "::set-output name=decision::$message"
    message="Stop and restart"
    echo "::set-output name=decision::$message"
elif [ "$buildstatus" == "blue" ] || [ "$buildstatus" == "red" ]; then
    message="Environment stopped ⏹️. Running with default parameters ⏩"
    echo "::set-output name=decision::$message"
    message="Start with parameters"
    echo "::set-output name=decision::$message"
elif [ "$buildstatus" == "notbuilt" ]; then
    message="❕ It's a first run for this branch ❕. Deployment will be run with draft_mini database copy ⏩."
    echo "::set-output name=decision::$message"
    message="Start without parameters"
    echo "::set-output name=decision::$message"
else
    message="❌ Unknown status from Jenkins ❌. Please retry in 1 minute or contact DevOps engineer 🔧"
    echo "::set-output name=decision::$message"
    exit 93
fi