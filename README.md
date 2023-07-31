# git-branch-status - print pretty git branch sync status reports

By default, the `git-branch-status` command shows the divergence relationship between branches for which the upstream differs from it's local counterpart.

A number of command-line switches exist, selecting various reports that compare any or all local or remote branches.


![git-branch-status screen-shot][scrot]


#### Notes regarding the screen-shot above:

* This is showing the exhaustive '--all' report. Other reports are constrained (see 'USAGE' below).
* The "local <-> upstream" section is itemizing all local branches. In this instance:
  * The local branch 'deleteme' is not tracking any remote branch.
  * The local branch 'kd35a' is tracking remote branch 'kd35a/master'.
  * The local branch 'knovoselic' is tracking remote branch 'knovoselic/master'.
  * The local branch 'master' is tracking remote branch 'origin/master'.
* The "local <-> kd35a" section is itemizing all branches on the 'kd35a' remote. In this instance:
  * The local branch 'master' is 2 commits behind and 24 commits ahead of the remote branch 'kd35a/master'.
  * The remote 'kd35a' has no other branches.
* The "local <-> knovoselic" section is itemizing all branches on the 'knovoselic' remote. In this instance:
  * The local branch 'master' is 4 commits behind and 24 commits ahead of the remote branch 'knovoselic/master'.
  * The remote 'knovoselic' has no other branches.
* The "local <-> origin" section is itemizing all branches on the 'origin' remote. In this instance:
  * The remote branch 'origin/delete-me' may or may not be checked-out locally; but no local branch exists with the name: 'delete-me'.
  * The local branch 'deleteme' is at the same commit as the remote branch 'origin/deleteme' but this is not a tracking relationship.
  * The local branch 'master' is tracking the remote branch 'origin/master'.
* The asterisks to the left of the local 'master' branch names indicate the current working branch.
* The blue branch names indicate an explicit tracking relationship between a local branch and it's upstream counterpart.
* The "local <-> upstream" section relates tracking relationships between local branches and their upstream counterparts; while the remote-specific sections relate identically named branches. Tracking relationships may or may not be indicated in the remote-specific sections, depending on whether or not both counterparts also coincidentally have the same branch name.
* In addition to the local amd remote reports, there are two other reports that are not shown in the screen-shot: a single branch report and an arbitrary branch comparison report. The report context determines the semantics of the green "... synchronized ..." messages which may appear under the respectively appropriate circumstances, as such:
  * In the "local <-> upstream" section, the green message indicates that all local branches which are tracking an upstream are synchronized with their respective upstream counterparts.
  * In remote-specific sections, the green message indicates that all local branches which have the same name as some branch on this remote are synchronized with that remote branch. These are not necessarily tracking relationships.
  * In single branch reports, the green message indicates that the local branch is tracking an upstream branch and is synchronized with it's upstream counterpart.
  * In arbitrary branch comparison reports, the green message indicates that the two compared branches are synchronized with each other.


```
USAGE:

  git-branch-status
  git-branch-status [ base-branch-name compare-branch-name ]
  git-branch-status [ -a | --all ]
  git-branch-status [ -b | --branch ] [ filter-branch-name ]
  git-branch-status [ -c | --cleanup ]
  git-branch-status [ -d | --dates ]
  git-branch-status [ -h | --help ]
  git-branch-status [ -l | --local ]
  git-branch-status [ -r | --remotes ]
  git-branch-status [ -v | --verbose ]


EXAMPLES:

  # show only branches for which upstream differs from local
  $ git-branch-status
    | collab-branch  | (behind 1)-|-(ahead 2) | origin/collab-branch  |
    | feature-branch | (even)    -|-(ahead 2) | origin/feature-branch |
    | master         | (behind 1)-|-(even)    | origin/master         |

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
   *| master              | (even)    -|-(ahead 1) | origin/master           |
    | tracked-branch      | (even)    -|-(even)    | origin/tracked-branch   |
    | untracked-branch    | n/a        | n/a       | origin/untracked-branch |
    | local-branch        | n/a        | n/a       | (no upstream)           |
    | master              | (behind 1) | (ahead 1) | a-peer/master           |
    | tracked-peer-branch | n/a       -|-n/a       | a-peer/tracked-branch   |
    | (no local)          | n/a        | n/a       | a-peer/unused-branch    |

  # show the current branch
  $ git-branch-status -b
  $ git-branch-status --branch
   *| current-branch | (even)-|-(ahead 2) | origin/current-branch |

  # show a specific branch
  $ git-branch-status          specific-branch
  $ git-branch-status -b       specific-branch
  $ git-branch-status --branch specific-branch
    | specific-branch | (even)-|-(ahead 2) | origin/specific-branch |

  # compare a specific local branch against all other local branches
  $ git-branch-status -c        master
  $ git-branch-status --cleanup master
   *| master             | (behind 2)-|-(even)    | master |
    | merged-into-master | (even)     | (even)    | master |
    | wip                | (even)     | (ahead 1) | master |
    branch: merged-into-master is identical to: master
    Delete merged-into-master? [y/N]

  # show the timestamp of each out-of-sync local ref
  $ git-branch-status -d
  $ git-branch-status --dates
    | 1999-12-30 master | (even)    -|-(even) | 1999-12-30 origin/master |
    | 1999-12-31 devel  | (behind 2)-|-(even) | 2000-01-01 origin/devel  |

  # show the timestamp of arbitrary branch refs
  $ git-branch-status -d      a-branch another-branch
  $ git-branch-status --dates a-branch another-branch
    | 1999-12-31 a-branch | (even) | (even) | 2000-01-01 another-branch |

  # print this usage message
  $ git-branch-status -h
  $ git-branch-status --help
      "prints this usage message"

  # show all local branches - including those synchronized or non-tracking
  $ git-branch-status -l
  $ git-branch-status --local
   *| master         | (even)-|-(ahead 1) | origin/master         |
    | tracked-branch | (even)-|-(even)    | origin/tracked-branch |
    | local-branch   | n/a    | n/a       | (no upstream)         |

  # show all remote branches - including those not checked-out
  $ git-branch-status -r
  $ git-branch-status --remotes
    | master     | (behind 1) | (even) | a-remote/master        |
    | (no local) | n/a        | n/a    | a-remote/unused-branch |

  # show all branches with timestamps (like -a -d)
  $ git-branch-status -v
  $ git-branch-status --verbose
    | 1999-12-31 master: initial commit | (behind 1)-|-(even) | 2000-01-01 origin/master: initial commit |
    | 1999-12-31 feature: bump version  | (even)    -|-(even) | 2000-01-01 origin/feature: bump version  |
   *| 1999-12-31 local-wip: a wip       | n/a        | n/a    | (no upstream)                            |
```


_NOTE: please direct bug reports, feature requests, or PRs to one of the upstream repos:_
* [https://github.com/bill-auger/git-branch-status/issues/][github-issues]
* [https://pagure.io/git-branch-status/issues/][pagure-issues]
* [https://codeberg.org/bill-auger/git-branch-status/issues/][codeberg-issues]


[scrot]:          http://bill-auger.github.io/git-branch-status-scrot.png "git-branch-status screen-shot"
[github-issues]:  https://github.com/bill-auger/git-branch-status/issues/
[pagure-issues]:  https://pagure.io/git-branch-status/issues/
[codeberg-issues]: https://codeberg.org/bill-auger/git-branch-status/issues/
