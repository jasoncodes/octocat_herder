Checklist (and a short version for the impatient)
=================================================

  * Commits:

    - Make commits of logical units.

    - Check for unnecessary whitespace with "git diff --check" before
      committing.

    - Commit using Unix line endings (check the settings around "crlf"
      in git-config(1)).

    - Do not check in commented out code or unneeded files.

    - The first line of the commit message should be a short
      description (50 characters is the soft limit, excluding ticket
      number(s)), and should skip the full stop.

    - The body should provide a meaningful commit message, which:

      - uses the imperative, present tense: "change", not "changed" or
        "changes".

      - includes motivation for the change, and contrasts its
        implementation with the previous behavior.

    - Make sure that you have tests for the bug you are fixing, or
      feature you are adding.

    - Make sure the test suite passes after your commit (rake spec).

  * Submission:

    - Fork the repository on GitHub.

    - Push your changes to a topic branch in your fork of the
      repository.

    - Submit a pull request.

The long version
================

  1.  Make separate commits for logically separate changes.

      Please break your commits down into logically consistent units
      which include new or changed tests relevent to the rest of the
      change.  The goal of doing this is to make the diff easier to
      read for whoever is reviewing your code.  In general, the easier
      your diff is to read, the more likely someone will be happy to
      review it and get it into the code base.

      If you're going to refactor a piece of code, please do so as a
      separate commit from your feature or bug fix changes.

      We also really appreciate changes that include tests to make
      sure the bug isn't re-introduced, and that the feature isn't
      accidentally broken.

      Describe the technical detail of the change(s).  If your
      description starts to get too long, that's a good sign that you
      probably need to split up your commit into more finely grained
      pieces.

      Commits which plainly describe the the things which help
      reviewers check the patch and future developers understand the
      code are much more likely to be merged in with a minimum of
      bike-shedding or requested changes.  Ideally, the commit message
      would include information, and be in a form suitable for
      inclusion in the release notes.

      Please also check that you are not introducing any trailing
      whitespaces or other "whitespace errors".  You can do this by
      running "git diff --check" on your changes before you commit.

  3.  Sending your changes

      To submit your changes via a GitHub pull request, we _highly_
      recommend that you have them on a topic branch, instead of
      directly on "master".  It makes things much easier to keep track
      of, especially if you decide to work on another thing before
      your first change is merged in.

      GitHub has some pretty good
      [general documentation](http://help.github.com/) on using
      their site.  They also have documentation on
      [creating pull requests](http://help.github.com/send-pull-requests/).

      In general, after pushing your topic branch up to your
      repository on GitHub, you'll switch to the branch in the GitHub
      UI and click "Pull Request" towards the top of the page in order
      to open a pull request.
