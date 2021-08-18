#  gbs-tests-constants.sh.inc - test suite for git-branch-status
#
#  Copyright 2020-2021,2023 bill-auger <bill-auger@programmer.net>
#
#  git-branch-status is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License version 3
#  as published by the Free Software Foundation.
#
#  git-branch-status is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License version 3
#  along with git-branch-status.  If not, see <http://www.gnu.org/licenses/>.


## string constants ##

readonly GBS_CMD=git-branch-status
readonly CLIME='\033[1;32m'
readonly CBLUE='\033[0;36m'
readonly CGREEN='\033[0;32m'
readonly CRED='\033[0;31m'
readonly CEND='\033[0m'
readonly MKTEMP_TEMPLATE='gbs-test-XXXXXXXXXX'
readonly LOCAL_NAME='local'
readonly UPSTREAM_NAME='the-upstream'
readonly PEER_NAME='a-collaborator'
readonly MASTER_BRANCH='master'
readonly COMMON_BRANCH='development'
readonly PEER_RENAMED_BRANCH='devel'
readonly WIP_BRANCH='my-wip'
readonly TRACKED_FILE='tracked_file'
readonly TEST_CFG_FILE='test_gbs_config'


## expected config test results ##

readonly CFG_FILE_LOC_ENV_TEXT="GBS_CFG_FILE=(exists):"
readonly CFG_FILE_LOC_DEF_TEXT="GBS_CFG_FILE="
read -r -d '' FETCH_PERIOD_ENV_TEXT <<'EOF'
GBS_FETCH_PERIOD=42
CFG_FETCH_PERIOD=-42
FETCH_PERIOD=42
EOF
read -r -d '' FETCH_PERIOD_CFG_TEXT <<'EOF'
GBS_FETCH_PERIOD=
CFG_FETCH_PERIOD=-42
FETCH_PERIOD=-42
EOF
read -r -d '' FETCH_PERIOD_DEF_TEXT <<'EOF'
GBS_FETCH_PERIOD=
CFG_FETCH_PERIOD=
FETCH_PERIOD=-1
EOF
read -r -d '' LAST_FETCH_ENV_TEXT <<'EOF'
GBS_LAST_FETCH_FILE=DUMMY
CFG_LAST_FETCH_FILE=__TMP_DIR__/GBS_LAST_FETCH
LAST_FETCH_FILE=DUMMY
EOF
read -r -d '' LAST_FETCH_CFG_TEXT <<'EOF'
GBS_LAST_FETCH_FILE=
CFG_LAST_FETCH_FILE=__TMP_DIR__/GBS_LAST_FETCH
LAST_FETCH_FILE=__TMP_DIR__/GBS_LAST_FETCH
EOF
read -r -d '' LAST_FETCH_DEF_TEXT <<'EOF'
GBS_LAST_FETCH_FILE=
CFG_LAST_FETCH_FILE=
LAST_FETCH_FILE=__HOME_DIR__/.GBS_LAST_FETCH
EOF
read -r -d '' ANSI_COLOR_ENV_TEXT <<'EOF'
GBS_USE_ANSI_COLOR=0
CFG_USE_ANSI_COLOR=1
USE_ANSI_COLOR=0
EOF
read -r -d '' ANSI_COLOR_CFG_TEXT <<'EOF'
GBS_USE_ANSI_COLOR=
CFG_USE_ANSI_COLOR=1
USE_ANSI_COLOR=1
EOF
read -r -d '' ANSI_COLOR_DEF_TEXT <<'EOF'
GBS_USE_ANSI_COLOR=
CFG_USE_ANSI_COLOR=
USE_ANSI_COLOR=1
EOF


## expected normal test results ##

# NOTE: the upstream and branch names are intentionally explicit
#       eg: the-upstream/development could be ${UPSTREAM_NAME}/${COMMON_BRANCH}
#           that would be less brittle if the constants are changed;
#           but the explicit text is more readable for debugging

IFS= read -r -d '' LOCAL_TRACKING_TEXT <<'EOF'
  local <-> upstream
EOF
IFS= read -r -d '' LOCAL_COLLAB_TEXT <<'EOF'
  local <-> a-collaborator
EOF
IFS= read -r -d '' LOCAL_UPSTREAM_TEXT <<'EOF'
  local <-> the-upstream
EOF
IFS= read -r -d '' LOCALDEV_LOCALWIP_TEXT <<'EOF'
  development <-> my-wip
EOF
IFS= read -r -d '' LOCALDEV_PEERDEV_TEXT <<'EOF'
  development <-> a-collaborator/devel
EOF
IFS= read -r -d '' PEERWIP_LOCALWIP_TEXT <<'EOF'
  a-collaborator/my-wip <-> my-wip
EOF
IFS= read -r -d '' UPSTRMASTER_PEERMASTER_TEXT <<'EOF'
  the-upstream/master <-> a-collaborator/master
EOF
IFS= read -r -d '' LOCALS_CLEANUP_TEXT <<'EOF'
  locals <-> master
EOF
readonly ARG_REQUIRED_TEXT="fatal: This option requires an argument"
IFS= read -r -d '' TRACKED_ALL_INSYNC_TEXT <<'EOF'
  ---------------------------------------------------------------
  | All tracking branches are synchronized with their upstreams |
  ---------------------------------------------------------------
EOF
IFS= read -r -d '' TRACKED_INSYNC_TEXT <<'EOF'
  -----------------------------------------------------------
  | This tracking branch is synchronized with it's upstream |
  -----------------------------------------------------------
EOF
IFS= read -r -d '' UNTRACKED_INSYNC_TEXT <<'EOF'
  -----------------------------------------------------------------
  | These branches are synchronized with no tracking relationship |
  -----------------------------------------------------------------
EOF
IFS= read -r -d '' REMOTES_INSYNC_TEXT <<'EOF'
  ------------------------------------------------------------------------------------------------
  | All local branches with corresponding names on this remote are synchronized with that remote |
  ------------------------------------------------------------------------------------------------
EOF
IFS= read -r -d '' OUTOFSYNCH_TEXT <<'EOF'
  ---------------------------------------------------------------
 *| development | (even) | (ahead 1) | the-upstream/development |
  ---------------------------------------------------------------
EOF
IFS= read -r -d '' ARBITRARYBRANCHES_LOCALDEV_LOCALWIP_TEXT <<'EOF'
  -------------------------------------------------
 *| development | (behind 2) | (ahead 1) | my-wip |
  -------------------------------------------------
EOF
IFS= read -r -d '' ARBITRARYBRANCHES_LOCALDEV_PEERDEV_TEXT <<'EOF'
  -----------------------------------------------------------
 *| development | (even) | (ahead 1) | a-collaborator/devel |
  -----------------------------------------------------------
EOF
IFS= read -r -d '' ARBITRARYBRANCHES_PEERWIP_LOCALWIP_TEXT <<'EOF'
  -----------------------------------------------------------
  | a-collaborator/my-wip | (behind 2) | (ahead 1) | my-wip |
  -----------------------------------------------------------
EOF
IFS= read -r -d '' CURRENTBRANCH_TEXT <<'EOF'
  ---------------------------------------------------------------
 *| development | (even) | (ahead 1) | the-upstream/development |
  ---------------------------------------------------------------
EOF
IFS= read -r -d '' SPECIFICBRANCH_TEXT <<'EOF'
  --------------------------------------
  | my-wip | n/a | n/a | (no upstream) |
  --------------------------------------
EOF
IFS= read -r -d '' OUTOFSYNCH_DATES_TEXT <<'EOF'
  -------------------------------------------------------------------------------------
  | 2000-01-06 development | (even) | (ahead 1) | 2000-01-02 the-upstream/development |
  -------------------------------------------------------------------------------------
EOF
IFS= read -r -d '' CLEANUP_TEXT <<'EOF'
  --------------------------------------------------------------------------
  | 2000-01-01 merged-into-master | (even) | (even)    | 2000-01-01 master |
  | 2000-01-05 my-wip             | (even) | (ahead 3) | 2000-01-01 master |
  | 2000-01-06 development        | (even) | (ahead 2) | 2000-01-01 master |
  --------------------------------------------------------------------------
	branch: merged-into-master is identical to: master
	Delete merged-into-master? [y/N]
EOF
IFS= read -r -d '' HELP_TEXT <<'EOF'
USAGE:

  git-branch-status
  git-branch-status [ base-branch-name compare-branch-name ]
  git-branch-status [ -a | --all ]
  git-branch-status [ -b | --branch ] [ filter-branch-name ]
  git-branch-status [ -d | --dates ]
  git-branch-status [ -h | --help ]
  git-branch-status [ -l | --local ]
  git-branch-status [ -r | --remotes ]
  git-branch-status [ -v | --verbose ]


EXAMPLES:

  # show only branches for which upstream differs from local
  $ git-branch-status
    | collab-branch  | (behind 1) | (ahead 2) | origin/collab-branch  |
    | feature-branch | (even)     | (ahead 2) | origin/feature-branch |
    | master         | (behind 1) | (even)    | origin/master         |

  # compare two arbitrary branches - local or remote
  $ git-branch-status a-branch another-branch
    | a-branch            | (even)     | (even) | another-branch            |
  $ git-branch-status a-branch a-remote/any-branch
    | a-branch            | (even)     | (even) | a-remote/any-branch       |
  $ git-branch-status a-remote/any-branch a-branch
    | a-remote/any-branch | (behind 1) | (even) | a-branch                  |
  $ git-branch-status a-remote/any-branch other-remote/other-branch
    | a-remote/any-branch | (behind 1) | (even) | other-remote/other-branch |

  # show all branches - local and remote, regardless of state or relationship
  $ git-branch-status -a
  $ git-branch-status --all
   *| master         | (even)     | (ahead 1) | origin/master             |
    | tracked-branch | (even)     | (even)    | origin/tracked-branch     |
    | (no local)     | n/a        | n/a       | origin/untracked-branch   |
    | local-branch   | n/a        | n/a       | (no upstream)             |
    | master         | (behind 1) | (ahead 1) | a-remote/master           |
    | (no local)     | n/a        | n/a       | a-remote/untracked-branch |

  # show the current branch
  $ git-branch-status -b
  $ git-branch-status --branch
   *| current-branch | (even) | (ahead 2) | origin/current-branch |

  # show a specific branch
  $ git-branch-status          specific-branch
  $ git-branch-status -b       specific-branch
  $ git-branch-status --branch specific-branch
    | specific-branch | (even) | (ahead 2) | origin/specific-branch |

  # compare a specific local branch against all other local branches
  $ git-branch-status -c        master
  $ git-branch-status --cleanup master
   *| master             | (behind 2) | (even)    | master |
    | merged-into-master | (even)     | (even)    | master |
    | wip                | (even)     | (ahead 1) | master |
    branch: merged-into-master is identical to: master
    Delete merged-into-master? [y/N]

  # show the timestamp of each out-of-sync local ref
  $ git-branch-status -d
  $ git-branch-status --dates
    | 1999-12-30 master   | (even)     | (even) | 1999-12-30 origin/master  |
    | 1999-12-31 devel    | (behind 2) | (even) | 2000-01-01 origin/devel   |

  # show the timestamp of arbitrary branch refs
  $ git-branch-status -d      a-branch another-branch
  $ git-branch-status --dates a-branch another-branch
    | 1999-12-31 a-branch | (even)     | (even) | 2000-01-01 another-branch |

  # print this usage message
  $ git-branch-status -h
  $ git-branch-status --help
      "prints this usage message"

  # show all local branches - including those synchronized or non-tracking
  $ git-branch-status -l
  $ git-branch-status --local
   *| master         | (even)     | (ahead 1) | origin/master         |
    | tracked-branch | (even)     | (even)    | origin/tracked-branch |
    | local-branch   | n/a        | n/a       | (no upstream)         |

  # show all remote branches - including those not checked-out
  $ git-branch-status -r
  $ git-branch-status --remotes
    | master     | (behind 1) | (even) | a-remote/master           |
    | (no local) | n/a        | n/a    | a-remote/untracked-branch |

  # show all branches with timestamps (like -a -d)
  $ git-branch-status -v
  $ git-branch-status --verbose
    | 1999-12-31 master    | (behind 1) | (even) | 2000-01-01 origin/master  |
    | 1999-12-31 tracked   | (even)     | (even) | 2000-01-01 origin/tracked |
   *| 1999-12-31 local-wip | n/a        | n/a    | (no upstream)             |
EOF
IFS= read -r -d '' LOCALS_TEXT <<'EOF'
  ---------------------------------------------------------------
 *| development | (even) | (ahead 1) | the-upstream/development |
  | master      | (even) | (even)    | the-upstream/master      |
  | my-wip      | n/a    | n/a       | (no upstream)            |
  ---------------------------------------------------------------
EOF
IFS= read -r -d '' REMOTES_COLLAB_TEXT <<'EOF'
  ---------------------------------------------------------------
  | (no local) | n/a        | n/a       | a-collaborator/devel  |
  | master     | (even)     | (even)    | a-collaborator/master |
  | my-wip     | (behind 1) | (ahead 2) | a-collaborator/my-wip |
  ---------------------------------------------------------------
EOF
IFS= read -r -d '' REMOTES_ORIGIN_TEXT <<'EOF'
  ---------------------------------------------------------------
 *| development | (even) | (ahead 1) | the-upstream/development |
  | master      | (even) | (even)    | the-upstream/master      |
  ---------------------------------------------------------------
EOF
IFS= read -r -d '' REMOTES_COLLAB_INSYNC_TEXT <<'EOF'
  --------------------------------------------------------
  | (no local) | n/a    | n/a    | a-collaborator/devel  |
  | master     | (even) | (even) | a-collaborator/master |
  | my-wip     | (even) | (even) | a-collaborator/my-wip |
  --------------------------------------------------------
EOF
IFS= read -r -d '' LOCALS_DATES_TEXT <<'EOF'
  -------------------------------------------------------------------------------------
  | 2000-01-01 master      | (even) | (even)    | 2000-01-01 the-upstream/master      |
  | 2000-01-03 my-wip      | n/a    | n/a       | (no upstream)                       |
  | 2000-01-06 development | (even) | (ahead 1) | 2000-01-02 the-upstream/development |
  -------------------------------------------------------------------------------------
EOF
IFS= read -r -d '' REMOTES_COLLAB_DATES_TEXT <<'EOF'
  --------------------------------------------------------------------------
  | 2000-01-01 master | (even) | (even) | 2000-01-01 a-collaborator/master |
  | (no local)        | n/a    | n/a    | 2000-01-02 a-collaborator/devel  |
  | 2000-01-03 my-wip | (even) | (even) | 2000-01-03 a-collaborator/my-wip |
  --------------------------------------------------------------------------
EOF
IFS= read -r -d '' REMOTES_ORIGIN_DATES_TEXT <<'EOF'
  -------------------------------------------------------------------------------------
  | 2000-01-01 master      | (even) | (even)    | 2000-01-01 the-upstream/master      |
  | 2000-01-06 development | (even) | (ahead 1) | 2000-01-02 the-upstream/development |
  -------------------------------------------------------------------------------------
EOF
IFS= read -r -d '' NCOMMITS_OVERCAP_TEXT <<'EOF'
  -----------------------------------------------------------------
 *| development | (even) | (ahead>999) | the-upstream/development |
  -----------------------------------------------------------------
EOF
IFS= read -r -d '' NCOMMITS_UNDERCAP_TEXT <<'EOF'
  -----------------------------------------------------------------
 *| development | (even) | (ahead 999) | the-upstream/development |
  -----------------------------------------------------------------
EOF
