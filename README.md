Notarius
========

Notarius is a logging library with opinions. The word "notarius" is
Latin for "shorthand writer". To this end, Notarius does everything
possible to encourage you to write short useful log messages. 

 * Whitespace is converted to spaces.
 * Lines are truncated to 140 characters.
 * Timestamps are formatted as ISO 8601.
 * Call stacks are easy to grep.
 * Duplicate messages are discarded.

Notarius does not want you to be happy now, while you're writing code.
It wants the person reading your logs at 3am trying to figure out why
your code doesn't work to be happy. If those happen to be the same
person, Notarius would rather future you be happier.

There is infinitely more future than there is now.

Installation
------------

Notarius is packaged as a Ruby gem. You do `gem install notarius` from
the command line to get it.

Configuration
-------------

Notarius is namespaced. This lets multiple libraries use Notarius
without clobbering each others logs.

```ruby
require 'notarius'

Notarius.configure 'BIG' do |log|
  log.file.enable = true
  log.file.path = '/var/log/notarius/notebook.log'
end
```

If you try to log to the same file as another library, Notarius will
yell at you and throw an exception. Notarius does not want you to
obliterate someone else's carefully crafted logs. However, it will tell
you what they've namespaced their logs so you can redirect them
elsewhere.

By default, Notarius doesn't log to anything, not even the console. If
you want console logging, you have to enable it.

```ruby
Notarius.configure 'BIG' do |log|
  log.console.enable = true
end
```

Notarius is fine with you calling the `configure` method multiple times.
Set up defaults when your program starts and change them later.

Usage
-----

Using Notarius is simple. Include the `Notarius::NAME` module (where
NAME is the string you passed to the `configure` method) and call
`log.info`, `log.warn`, or `log.error`. You can log anything that
responds to a `:to_s` message.

```ruby
class Player 
  include Notarius::BIG

  def move direction
    log.info "You head off down the #{direction} path."
  end

  def poke object
    log.warn "Gingerly, you nudge the #{object}."
  end

  def attack monster 
    if monster.nil?
      log.error "You attack the darkness."
    else
      log.info "You whack the #{monster} with a stick."
    end
  end
end
```

Opinions
--------

Notarius only has three logging levels: info, warning, and error. You
don't need more than that. If think you do, your logs are too verbose.

There is one line of output per message. If you insert carriage returns
and newlines in a message, they will be converted into spaces. The same
goes for tabs. Log statements shouldn't read like poetry. Exceptions are
the exceptional exception to this rule.

Messages are truncated so the total length of a line is less than 140
characters. This makes them easy to tweet. Tweetablility is important,
because it's what the people reading logs at 3am do when they find
something hilarious. If you're writing non-tweetable messages, your logs
are too verbose.

To make it easy to grep for warnings and errors, messages are output as
"level [timestamp] message". You can do `cat notarius.log | grep ^WARN`
and find all the warnings in a log.

If the object you pass to the `info`, `warn`, and `error` methods
responds to `:message` and `:backtrace` messages, you'll get output
like this:

```bash
level [timestamp] message
!  backtrace
!  backtrace
!  backtrace 
```

This makes it easy to log exceptions. More importantly, it makes it easy
to find exceptions: `cat notarius.log | grep -B 1 "^\!"`

If you try to write the same message multiple times, only the first one
will show up. This is true even if you change the logging level, or the
timestamps of the messages are different. Multiple identical lines in
the log are a sign that your code is broken.

Inspiration
-----------

At lot of the Notarius philosophy was stolen from [Logula][logula]. The
rest of it comes from several years watching sysadmins work, and
realizing that programmers often make their lives for more difficult
than we intend.

Notarius tries to make things easier.

License
-------

Notarius is available under an [MIT-style][mit] license. See the
{file:LICENSE.md} document for more information.

[logula]: https://github.com/codahale/logula "Logula is a Scala library
which provides a sane log output format and easy-to-use mixin for adding
logging to your code."
