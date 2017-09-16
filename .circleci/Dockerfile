FROM busybox:glibc

COPY .circleci/tester /bin/
COPY goinsu /bin/

# Add new user
RUN adduser testuser -D -h "" -g "It's ya' boy, testuser"

# testuser is in every single group
RUN cat /etc/group | cut -d: -f1 | xargs -n1 addgroup testuser

RUN chmod +s /bin/goinsu # Let goinsu mess with uid/gid

USER testuser
ENV HOME /opt/is/my/city

RUN id

# Format:
# script "argument to pass to goinsu" "expected (ids)" "expected (names)"

RUN tester 0		"0:0:$(id -G root)"	"root:root:$(id -Gn root)"
RUN tester 0:0		"0:0:0"		"root:root:root"
RUN tester root	"0:0:$(id -G root)"	"root:root:$(id -Gn root)"
RUN tester 0:root	"0:0:0"		"root:root:root"
RUN tester root:0	"0:0:0"		"root:root:root"
RUN tester 1000	"1000:1000:$(id -G)"	"testuser:testuser:$(id -Gn)"
RUN tester 0:1000	"0:1000:1000"		"root:testuser:testuser"
RUN tester 1000:root	"1000:0:0"		"testuser:root:root"

RUN tester 0:		"0:0:$(id -G root)"	"root:root:$(id -Gn root)"
RUN tester ""		"0:0:$(id -G root)"	"root:root:$(id -Gn root)"
RUN tester ":0"	"0:0:0"		"root:root:root"

RUN [ "$(goinsu 0		env | grep '^HOME=')" ==	"HOME=/root" ]
RUN [ "$(goinsu 0:0		env | grep '^HOME=')" ==	"HOME=/root" ]
RUN [ "$(goinsu root		env | grep '^HOME=')" ==	"HOME=/root" ]
RUN [ "$(goinsu root:root	env | grep '^HOME=')" ==	"HOME=/root" ]
RUN [ "$(goinsu 0:root		env | grep '^HOME=')" ==	"HOME=/root" ]
RUN [ "$(goinsu 0:1000		env | grep '^HOME=')" ==	"HOME=/root" ]
RUN [ "$(goinsu testuser	env | grep '^HOME=')" ==	"HOME=/" ]
RUN [ "$(goinsu testuser:0	env | grep '^HOME=')" ==	"HOME=/" ]
RUN [ "$(goinsu 1000:root	env | grep '^HOME=')" ==	"HOME=/" ]
