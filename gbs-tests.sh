#!/bin/bash

source ./gbs-tests-constants.sh.inc


## test data variables ##

TempDir=''
TestName=''
Expected=''
Actual=''


## logging ##

STATE() { printf "\n=== ${CLIME}${1}${CEND} ===\n\n" ; true ; }
LOG()   { printf "${CBLUE}${1}${CEND}\n"             ; true ; }
PASS()  { printf "${CGREEN}PASSED: ${1}${CEND}\n"    ; true ; }
FAIL()  { printf "${CRED}FAILED: ${1}${CEND}\n"
          printf "${CRED}Expected:${CEND}\n${2}\n"
          printf "${CRED}Actual:${CEND}\n${3}\n"     ; true ; }


## business ##

Init()
{
  [[   -z "${GBS_CMD}" ]] && ERR "constants file load failed - bailing" && return 1
  [[ ! -x "${GBS_CMD}" ]] && ERR "GBS_CMD is not executable - bailing"  && return 1

  if   TempDir="$(mktemp --directory -t $MKTEMP_TEMPLATE)"
  then STATE "initializing" ; LOG "created temp directory: ${TempDir}" ;
  else ERR "failed to create temp directory - bailing" ; return 1 ;
  fi

  export GBS_TEST_CFG=1
  export GBS_USE_ANSI_COLOR=0
  export GBS_FETCH_PERIOD=-1
  export GBS_CFG_FILE=${TempDir}/${TEST_CFG_FILE}

  if   [[ -f $(git-branch-status | grep 'DEF_CFG_FILE=' | sed 's|[^:]*: ||') ]]
  then ERR "default config file must not exist - bailing" ; return 1 ;
  fi

  LOG "preparing test config file"
  echo "readonly CFG_FETCH_PERIOD=-42"                           > ${GBS_CFG_FILE}
  echo "readonly CFG_LAST_FETCH_FILE=${TempDir}/GBS_LAST_FETCH" >> ${GBS_CFG_FILE}
  echo "readonly CFG_USE_ANSI_COLOR=1"                          >> ${GBS_CFG_FILE}

  LOG "creating: '${UPSTREAM_NAME}'"
  cd ${TempDir} ; mkdir ${UPSTREAM_NAME} ; cd ${UPSTREAM_NAME}
  git init                                                                  > /dev/null
  touch ${TRACKED_FILE} ; git add ${TRACKED_FILE} ;
  echo 'some text' > ${TRACKED_FILE}
  git commit -m 'upstream-initial' --date 2000-01-01 ${TRACKED_FILE}        > /dev/null
  LOG "preparing branches for: '${UPSTREAM_NAME}'"
  git checkout -b ${COMMON_BRANCH}                                         2> /dev/null
  echo 'diff text' > ${TRACKED_FILE}
  git commit -m 'upstream-change'  --date 2000-01-02 ${TRACKED_FILE}        > /dev/null
  git checkout master                                                      2> /dev/null

  LOG "cloning: '${UPSTREAM_NAME}' as: '${PEER_NAME}'"
  cd ${TempDir}
  git clone --origin ${UPSTREAM_NAME} ${UPSTREAM_NAME} ${PEER_NAME}        2> /dev/null
  cd ${PEER_NAME}
  LOG "preparing branches for: '${PEER_NAME}'"
  git checkout -b ${PEER_RENAMED_BRANCH} ${UPSTREAM_NAME}/${COMMON_BRANCH} &> /dev/null
  git checkout -b ${WIP_BRANCH}          ${PEER_RENAMED_BRANCH}            2> /dev/null
  echo 'more text' >> ${TRACKED_FILE}
  git commit -m 'peer-change' --date 2000-01-03 ${TRACKED_FILE}             > /dev/null

  LOG "cloning: '${UPSTREAM_NAME}' as: '${LOCAL_NAME}'"
  cd ${TempDir}
  git clone --origin ${UPSTREAM_NAME} ${UPSTREAM_NAME} ${LOCAL_NAME}       2> /dev/null
  cd ${LOCAL_NAME}
  LOG "adding remote: '${PEER_NAME}' to: '${LOCAL_NAME}'"
  git remote add ${PEER_NAME} ../${PEER_NAME}
  git fetch ${PEER_NAME}                                                   2> /dev/null
  LOG "preparing branches for: '${LOCAL_NAME}'"
  git checkout -b ${COMMON_BRANCH} ${UPSTREAM_NAME}/${COMMON_BRANCH}       &> /dev/null
  echo 'more text' >> ${TRACKED_FILE}
  git commit -m 'local-change' --date 2000-01-04 ${TRACKED_FILE}            > /dev/null
  git checkout -b ${WIP_BRANCH}    ${COMMON_BRANCH}                        2> /dev/null
  echo 'more text' >> ${TRACKED_FILE}
  git commit -m 'local-change' --date 2000-01-05 ${TRACKED_FILE}            > /dev/null
  git checkout ${COMMON_BRANCH}                                            &> /dev/null
}

AssertEqual()
{
  if   diff <(printf "%s" "${Expected}") <(printf "%s" "${Actual}") &> /dev/null
  then PASS "${TestName}"
  else FAIL "${TestName}" "${Expected}" "${Actual}"
       exit 1
  fi
}

TestConfig()
{
  STATE "running config tests"

  export GBS_TEST_CFG=1

  TestName="config file location via env"
  Expected="$(printf "%s" "${CFG_FILE_LOC_ENV_TEXT} ${TempDir}/${TEST_CFG_FILE}")"
  Actual=$(git-branch-status | grep 'GBS_CFG_FILE=')
  AssertEqual

  TestName="config file location default"
  Expected="$(printf "%s" "${CFG_FILE_LOC_DEF_TEXT}")"
  Actual=$(GBS_CFG_FILE= git-branch-status | grep 'GBS_CFG_FILE=')
  AssertEqual

  TestName="fetch period via env"
  Expected="$(printf "%s" "${FETCH_PERIOD_ENV_TEXT}")"
  Actual=$(GBS_FETCH_PERIOD=42 git-branch-status | grep 'FETCH_PERIOD=')
  AssertEqual
  TestName="fetch period via config"
  Expected="$(printf "%s" "${FETCH_PERIOD_CFG_TEXT}")"
  Actual=$(GBS_FETCH_PERIOD= git-branch-status | grep 'FETCH_PERIOD=')
  AssertEqual
  mv ${GBS_CFG_FILE} ${GBS_CFG_FILE}-bak
  TestName="fetch period default"
  Expected="$(printf "%s" "${FETCH_PERIOD_DEF_TEXT}")"
  Actual=$(GBS_FETCH_PERIOD= git-branch-status | grep 'FETCH_PERIOD=')
  AssertEqual
  mv ${GBS_CFG_FILE}-bak ${GBS_CFG_FILE}

  TestName="last fetch file via env"
  Expected="$(printf "%s" "${LAST_FETCH_ENV_TEXT}" | sed "s|__TMP_DIR__|${TempDir}|")"
  Actual=$(GBS_LAST_FETCH_FILE=DUMMY git-branch-status | grep 'LAST_FETCH_FILE=')
  AssertEqual
  TestName="last fetch file via config"
  Expected="$(printf "%s" "${LAST_FETCH_CFG_TEXT}" | sed "s|__TMP_DIR__|${TempDir}|")"
  Actual=$(GBS_LAST_FETCH_FILE= git-branch-status | grep 'LAST_FETCH_FILE=')
  AssertEqual
  mv ${GBS_CFG_FILE} ${GBS_CFG_FILE}-bak
  TestName="last fetch file default"
  Expected="$(printf "%s" "${LAST_FETCH_DEF_TEXT}" | sed "s|__HOME_DIR__|${HOME}|")"
  Actual=$(GBS_LAST_FETCH_FILE= git-branch-status | grep 'LAST_FETCH_FILE=')
  AssertEqual
  mv ${GBS_CFG_FILE}-bak ${GBS_CFG_FILE}

  TestName="ansi color via env"
  Expected="$(printf "%s" "${ANSI_COLOR_ENV_TEXT}")"
  Actual=$(GBS_USE_ANSI_COLOR=0 git-branch-status | grep 'USE_ANSI_COLOR=')
  AssertEqual
  TestName="ansi color via config"
  Expected="$(printf "%s" "${ANSI_COLOR_CFG_TEXT}")"
  Actual=$(GBS_USE_ANSI_COLOR= git-branch-status | grep 'USE_ANSI_COLOR=')
  AssertEqual
  mv ${GBS_CFG_FILE} ${GBS_CFG_FILE}-bak
  TestName="ansi color default"
  Expected="$(printf "%s" "${ANSI_COLOR_DEF_TEXT}")"
  Actual=$(GBS_USE_ANSI_COLOR= git-branch-status | grep 'USE_ANSI_COLOR=')
  AssertEqual
  mv ${GBS_CFG_FILE}-bak ${GBS_CFG_FILE}
}

TestOptions()
{
  STATE "running options tests"

  export GBS_TEST_CFG=0

  (git checkout ${COMMON_BRANCH} ; git reset --hard ${UPSTREAM_NAME}/${COMMON_BRANCH}) &> /dev/null

  TestName="default in-sync"
  Expected="$(printf "\n%s%s" "${LOCAL_TRACKING_TEXT}" "${TRACKED_ALL_INSYNC_TEXT}")"
  Actual=$(git-branch-status)
  AssertEqual

  (git rm ${TRACKED_FILE} ; git commit -m 'rm' --date 2000-01-06 ;) > /dev/null

  TestName="default out-of-sync"
  Expected="$(printf "\n%s%s" "${LOCAL_TRACKING_TEXT}" "${OUTOFSYNCH_TEXT}")"
  Actual=$(git-branch-status)
  AssertEqual

  TestName="arbitrary branches local<->local"
  Expected="$(printf "\n%s%s" "${LOCALDEV_LOCALWIP_TEXT}" "${ARBITRARYBRANCHES_LOCALDEV_LOCALWIP_TEXT}")"
  Actual=$(git-branch-status ${COMMON_BRANCH} ${WIP_BRANCH})
  AssertEqual

  TestName="arbitrary branches local<->remote"
  Expected="$(printf "\n%s%s" "${LOCALDEV_PEERDEV_TEXT}" "${ARBITRARYBRANCHES_LOCALDEV_PEERDEV_TEXT}")"
  Actual=$(git-branch-status ${COMMON_BRANCH} ${PEER_NAME}/${PEER_RENAMED_BRANCH})
  AssertEqual

  TestName="arbitrary branches remote<->local"
  Expected="$(printf "\n%s%s" "${PEERWIP_LOCALWIP_TEXT}" "${ARBITRARYBRANCHES_PEERWIP_LOCALWIP_TEXT}")"
  Actual=$(git-branch-status ${PEER_NAME}/${WIP_BRANCH} ${WIP_BRANCH})
  AssertEqual

  TestName="arbitrary branches remote<->remote"
  Expected="$(printf "\n%s%s" "${UPSTRMASTER_PEERMASTER_TEXT}" "${UNTRACKED_INSYNC_TEXT}")"
  Actual=$(git-branch-status ${UPSTREAM_NAME}/master ${PEER_NAME}/master)
  AssertEqual

  TestName="all branches"
  Expected="$(printf "\n%s%s\n%s%s\n%s%s"                              \
                     "${LOCAL_TRACKING_TEXT}" "${LOCALS_TEXT}"         \
                     "${LOCAL_COLLAB_TEXT}"   "${REMOTES_COLLAB_TEXT}" \
                     "${LOCAL_UPSTREAM_TEXT}" "${REMOTES_ORIGIN_TEXT}" )"
  Actual=$(git-branch-status --all)
  AssertEqual

  TestName="current branch"
  Expected="$(printf "\n%s%s" "${LOCAL_TRACKING_TEXT}" "${CURRENTBRANCH_TEXT}")"
  Actual=$(git-branch-status --branch)
  AssertEqual

  TestName="specific branch"
  Expected="$(printf "\n%s%s" "${LOCAL_TRACKING_TEXT}" "${SPECIFICBRANCH_TEXT}")"
  Actual=$(git-branch-status --branch ${WIP_BRANCH})
  AssertEqual

  TestName="dates"
  Expected="$(printf "\n%s%s" "${LOCAL_TRACKING_TEXT}" "${OUTOFSYNCH_DATES_TEXT}")"
  Actual=$(git-branch-status --dates)
  AssertEqual

  TestName="help"
  Expected="$(printf "%s" "${HELP_TEXT}")"
  Actual=$(git-branch-status --help)
  AssertEqual

  TestName="local"
  Expected="$(printf "\n%s%s" "${LOCAL_TRACKING_TEXT}" "${LOCALS_TEXT}")"
  Actual=$(git-branch-status --local)
  AssertEqual

  TestName="remotes out-of-sync"
  Expected="$(printf "\n%s%s\n%s%s"                                     \
                     "${LOCAL_COLLAB_TEXT}"   "${REMOTES_COLLAB_TEXT}"  \
                     "${LOCAL_UPSTREAM_TEXT}" "${REMOTES_ORIGIN_TEXT}" )"
  Actual=$(git-branch-status --remotes)
  AssertEqual

  (git checkout ${WIP_BRANCH} ; git reset --hard ${PEER_NAME}/${WIP_BRANCH} ;) &> /dev/null
  (git checkout ${COMMON_BRANCH} ;                                           ) &> /dev/null

  TestName="remotes in-sync"
  Expected="$(printf "\n%s%s%s\n%s%s"                                                                  \
                     "${LOCAL_COLLAB_TEXT}"   "${REMOTES_COLLAB_INSYNC_TEXT}" "${REMOTES_INSYNC_TEXT}" \
                     "${LOCAL_UPSTREAM_TEXT}" "${REMOTES_ORIGIN_TEXT}"                                )"
  Actual=$(git-branch-status --remotes)
  AssertEqual

  return # FIXME: dates sorting is not stable

  TestName="verbose"
  Expected="$(printf "\n%s%s\n%s%s%s\n%s%s"                                                           \
                     "${LOCAL_TRACKING_TEXT}" "${LOCALS_DATES_TEXT}"                                  \
                     "${LOCAL_COLLAB_TEXT}"   "${REMOTES_COLLAB_DATES_TEXT}" "${REMOTES_INSYNC_TEXT}" \
                     "${LOCAL_UPSTREAM_TEXT}" "${REMOTES_ORIGIN_DATES_TEXT}"                         )"
  Actual=$(git-branch-status --verbose)
  AssertEqual
}

RunTests()
{
  TestConfig                     && \
  TestOptions                    && \
  STATE "(: all tests passed :)"
}

Cleanup()
{
  STATE "cleaning up"

  rm -rf $TempDir 2> /dev/null
}

main()
{
  local result

  Init && RunTests ; result=$? ;

  Cleanup

  exit ${result}
}


## main entry ##

main
