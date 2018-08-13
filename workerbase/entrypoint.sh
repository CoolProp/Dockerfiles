#!/bin/bash
CTRLAPP="buildbot-worker"
function shutdown()
{
  $CTRLAPP stop ${WORKERDIR}
  exit 0
}

function startup()
{
  if [ ! -d "${WORKERDIR}" ]; then
    $CTRLAPP create-worker ${WORKERDIR} ${BUILDMASTER}:${BUILDMASTER_PORT} ${WORKERNAME} ${WORKERPASS}
    echo "${BOTADMIN} <${BOTEMAIL}>" > ${WORKERDIR}/info/admin
    echo "${BOTHOST}" > ${WORKERDIR}/info/host
  fi
  # Remove the security relevant variables from the environment
  # Otherwise, they will be listed as clear text in the buildbot 
  # logs that are publicly available.
  unset BUILDMASTER
  unset BUILDMASTER_PORT
  unset WORKERPASS
  unset BOTADMIN
  unset BOTEMAIL
  unset BOTHOST
  $CTRLAPP start ${WORKERDIR}
  echo "Remember to update the SSH configuration:"
  echo "docker cp \${HOME}/.ssh ${WORKERNAME}:${HOME}/"
  echo "docker cp \${HOME}/.pypirc ${WORKERNAME}:${HOME}/"
  echo "docker exec --user root ${WORKERNAME} find ${HOME} ! -user buildbot -exec chown buildbot {} \\;"
}

trap shutdown TERM SIGTERM SIGKILL SIGINT

startup;

# Just idle for one hour and keep the process alive
# waiting for SIGTERM.
while : ; do
sleep 3600 & wait
done
#
echo "The endless loop terminated, something is wrong here."
exit 1
