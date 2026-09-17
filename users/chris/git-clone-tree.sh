# Clone a repository into the bare-plus-sibling-worktrees layout: a .bare
# directory holding the object store, a .git file pointing at it, and one
# worktree per branch alongside. No single worktree owns the repository, so
# any of them can be added or removed without disturbing the others.
#
# Reached as `git clone-tree` through the alias in ./git.nix, which means
# git's conventions for shell aliases apply -- notably that they run from the
# top of the enclosing worktree rather than from wherever the command was
# typed.

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "usage: git clone-tree <url> [directory]" >&2
    exit 2
fi

# Recover the directory the command was typed in. Before running an alias,
# git moves to the top of the enclosing worktree and records the difference
# in GIT_PREFIX; outside a worktree it stays put and sets nothing.
cd "${GIT_PREFIX:-.}"

url=$1
top=${2:-$(basename "$url" .git)}

case $top in
    "" | . | .. | /)
        echo "git clone-tree: cannot derive a directory name from '$url'" >&2
        exit 1
        ;;
esac

# Refuse a target that is already a repository. Left to itself, the `mv`
# below would move the new git directory *inside* an existing .bare rather
# than failing, quietly nesting one repository in another.
if [ -e "$top/.bare" ] || [ -e "$top/.git" ]; then
    echo "git clone-tree: $top is already a repository" >&2
    exit 1
fi

# --no-checkout rather than --bare, so that the clone keeps the ordinary
# +refs/heads/*:refs/remotes/origin/* refspec. A --bare clone fetches straight
# into refs/heads/*, leaving no remote-tracking refs, and without those
# `git worktree add` has nothing to resolve a branch name against.
#
# Cloning before descending into $top keeps a relative <url> meaning what the
# caller meant by it.
git clone --no-checkout "$url" "$top/.tmp"
mv "$top/.tmp/.git" "$top/.bare"
rmdir "$top/.tmp"

cd "$top"

# core.bare stops the top level presenting itself as a checkout in which every
# tracked file has been deleted. guessRemote lets a later `git worktree add
# <path>` find origin/<path> for itself, without naming the branch twice.
git --git-dir=.bare config core.bare true
git --git-dir=.bare config worktree.guessRemote true

# Relative, so the whole tree can be moved without rewriting this.
echo 'gitdir: ./.bare' > .git

# A remote with no commits advertises no HEAD, so there is no default branch
# to lay out. What has been built so far is still sound: once the remote has
# a branch, `git fetch && git worktree add` completes the job.
if ! origin_head=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null); then
    echo "git clone-tree: $url has no default branch; $top has no worktree yet" >&2
    exit 0
fi

# The worktree path keeps the branch name verbatim, slashes and all, so that
# guessRemote can work backwards from path to branch when further worktrees
# are added by hand.
branch=${origin_head#origin/}
git worktree add "$branch" "$branch"
