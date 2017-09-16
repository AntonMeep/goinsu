goinsu [![Page on DUB](https://img.shields.io/dub/v/goinsu.svg?style=flat-square)](http://code.dlang.org/packages/goinsu)[![License](https://img.shields.io/dub/l/goinsu.svg?style=flat-square)](https://github.com/ohdatboi/goinsu/blob/master/LICENSE)[![TravisCI](https://img.shields.io/travis/ohdatboi/goinsu/master.svg?style=flat-square)](https://travis-ci.org/ohdatboi/goinsu)[![CircleCI](https://img.shields.io/circleci/project/github/ohdatboi/goinsu.svg?style=flat-square)](https://circleci.com/gh/ohdatboi/workflows/goinsu)
=============

**goinsu** - a simple `su` which doesn't mess with TTY and other stuff. It is as simple as "Hey, run this program as this user".

## Why?
```
$ docker run -it --rm ubuntu:trusty su -c "ps aux"
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  7.0  0.0  46644  2628 pts/0    Ss+  19:07   0:00 su -c ps aux
root         7  0.0  0.0  15584  2100 ?        Rs   19:07   0:00 ps aux
$ docker run -it --rm ubuntu:trusty sudo ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  7.0  0.0  46028  3044 pts/0    Ss+  19:07   0:00 sudo ps aux
root         6  0.0  0.0  15584  2140 pts/0    R+   19:07   0:00 ps aux
$ docker run -it --rm -v`pwd`/goinsu:/usr/bin/goinsu ubuntu:trusty goinsu root ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   7152   852 pts/0    Rs+  19:08   0:00 ps aux
```

## Why reinvent gosu?
**goinsu** does the same thing but in 10KB (well, 50KB if compiled as a static executable) instead of 1.8MB.

## Whe reinvent su-exec?
**goinsu** is written in the D programming language, which is a high-level programming language with metaprogramming, CTFE, and other cool things you can't find in C.

## betterC?

Yep. goinsu written in a subset of the D programming language, called betterC. Just google for it, ya' know.

## Alternatives

You can use `gosu` or `su-exec`, but they aren't as cool as **goinsu**.

