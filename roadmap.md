Notarius
========

Notarius releases are named after Latin [book sizes][]. We go from
something large and course, _folio_, to someting fine and specific,
_duodecimo_. In a similar fashion to the [git flow][] branching model,
releases are unversioned. This is a general timeline for what gets
worked on when.

The current release, version 0.1.0, corresponds to the _folio_ stage.

folio
-----

Initial API design, including configuration syntax and how namespaces
work with each other. Support for logging to the console (STDOUT) and
logging to a file. Basic documentation in YARD, and most code covered
in RSpec.

quarto
------

Clean up of YARD and RSpec documentation so it looks and feels
consistant. Most code is documented. Tightening of specs to reduce code
duplication and cover more edge cases. Migration of code to private
classes and methods to keep the API clean.

octavo
------

Elmination of Ruby headers in log files. All code is documented. Support
for setting logging level per logger. Ability to log blocks with delayed
evaluation. Stripping of color codes from file logging.

duodecimo
---------

Syslog support, both local and remote. Ability to specify stream (STDOUT
or STDERR) when logging to console. Handle internationalization (multi
byte log messages) nicely.

[book sizes]: http://en.wikipedia.org/wiki/Book_size "Book size on Wikipedia"
[git flow]: http://nvie.com/posts/a-successful-git-branching-model/ "A successful Git branching model >> nvie.com"
