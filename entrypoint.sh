#!/bin/bash

[[ -z "${INPUT_JOB_NAME}" ]] && echo "Job name not set" && exit 1 || jobname="${INPUT_JOB_NAME}"
[[ -z "${INPUT_BRANCH_NAME}" ]] && echo "Branch name not set" && exit 1 || branch="${INPUT_BRANCH_NAME}"
[[ -z "${INPUT_JENKINS_USER}" ]] && echo "Jenkins user not set" && exit 1 || jenkinsuser="${INPUT_JENKINS_USER}"
[[ -z "${INPUT_JENKINS_TOKEN}" ]] && echo "Jenkins token not set" && exit 1 || jenkinstoken="${INPUT_JENKINS_TOKEN}"
[[ -z "${INPUT_JENKINS_URL}" ]] && echo "Jenkins URL not set" && exit 1 || jenkinsurl="${INPUT_JENKINS_URL}"

describejob=$(curl --silent -u $jenkinsuser:$jenkinstoken $jenkinsurl/$jobname/$branch/api/json)
buildstatus=$(echo $describejob | jq -r '.color')

echo "::set-output name=status::$buildstatus"

if [ "$buildstatus" == "notbuilt_anime" ] || [ "$buildstatus" == "blue_anime" ] || [ "$buildstatus" == "red_anime" ]; then
    message="Environment already running 👟. Will be restarted from last branch commit 🔁"
    echo "::set-output name=decision::$message"

    #Restart pipeline
    #Stop
    jobnextbuildid=$(echo $describejob | jq -r '.nextBuildNumber')
    jobbuildid=$(( jobnextbuildid - 1 ))
    apicall=$(curl --silent -u $jenkinsuser:$jenkinstoken $jenkinsurl/$jobname/$branch/$jobbuildid/wfapi/pendingInputActions)
    inputid=$(echo "$apicall" | jq -r '.[0] .id')
    code=$(curl -X POST -s -o /dev/null -I -w "%{http_code}" -u "$jenkinsuser:$jenkinstoken" "$jenkinsurl/$jobname/$branch/$jobbuildid/input/$inputid/proceedEmpty")
    [[ $code -eq 200 ]] || [[ $code -eq 201 ]] && echo "::set-output name=result::'Stoping triggered HTTP/$code'" || echo "::set-output name=result::'Stopping trigger failed HTTP/$code'" 

    #Start
    echo "Sleepeng 30 sec"
    sleep 30s
    startcode=$(curl -X POST -s -o /dev/null -I -w "%{http_code}" -u "$jenkinsuser:$jenkinstoken" "$jenkinsurl/$jobname/$branch/buildWithParameters?token=$jenkinstoken")
    [[ $startcode -eq 200 ]] || [[ $startcode -eq 201 ]] && echo "::set-output name=result::'Triggered HTTP/$startcode'" || echo "::set-output name=result::'Job trigger failed HTTP/$startcode'"

elif [ "$buildstatus" == "blue" ] || [ "$buildstatus" == "red" ] || [ "$buildstatus" == "aborted" ]; then
    message="Environment stopped ⏹️. Running with default parameters ⏩"
    echo "::set-output name=decision::$message"

    #Start with parameters
    code=$(curl -X POST -s -o /dev/null -I -w "%{http_code}" -u "$jenkinsuser:$jenkinstoken" "$jenkinsurl/$jobname/$branch/buildWithParameters?token=$jenkinstoken")
    [[ $code -eq 200 ]] || [[ $code -eq 201 ]] && echo "::set-output name=result::'Triggered HTTP/$code'" || echo "::set-output name=result::'Job trigger failed HTTP/$code'" 

elif [ "$buildstatus" == "notbuilt" ]; then
    message="❕ It's a first run for this branch ❕. Deployment will be run with draft_mini database copy ⏩."
    echo "::set-output name=decision::$message"

    #Start without parameters"
    code=$(curl -X POST -s -o /dev/null -I -w "%{http_code}" -u "$jenkinsuser:$jenkinstoken" "$jenkinsurl/$jobname/$branch/build?token=$jenkinstoken")
    [[ $code -eq 200 ]] || [[ $code -eq 201 ]] && echo "::set-output name=result::'Triggered HTTP/$code'" || echo "::set-output name=result::'Job trigger failed HTTP/$code'"

else
    message="❌ Unknown status from Jenkins ❌. Please retry in 1 minute or contact DevOps engineer 🔧"
    echo "::set-output name=decision::$message"
    exit 93
fi