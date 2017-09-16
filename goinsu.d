#!/usr/bin/env rdmd
/+
dub.json:
{ "name": "goinsu" }
+/

module goinsu;

import core.sys.posix.sys.types : uid_t, gid_t;

extern(C) @nogc:

// TODO: use D_betterC as soon as dmd with https://github.com/dlang/dmd/pull/7132 is released
version(BetterC) {
	// `errno` is defined in C header, so small C wrapper is required (See errnofix.c)
	pragma(mangle, "getErrno") int errno();
} else {
	// druntime does the same thing, but in this case program should be linked with druntime
	import core.stdc.errno : errno;
}

int setgroups(size_t size, const(gid_t)* list);
int getgrouplist(const(char)* user, gid_t group, gid_t* groups, int* ngroups);

auto getByNameOrId(alias byid, T, alias byname)(char* v) {
	import core.stdc.stdlib : strtol;
	char* end;
	auto i = v.strtol(&end, 10);
	return *end == '\0' ? byid(cast(T) i) : byname(v);
}

void fail(alias err = -1, A...)(in string fmt, A args) {
	import core.stdc.stdio : stderr, fprintf;
	import core.stdc.stdlib : exit;
	stderr.fprintf(fmt.ptr, args);
	stderr.fprintf("\n");
	exit(err);
}

int main(int argc, char** argv) {
	import core.sys.posix.unistd : getuid, getgid, execvp, setgid, setuid;
	import core.stdc.string : strerror, strchr;

	if(argc < 3)
		"Usage: %s user-spec command [args]".fail!(0)(argv[0]);

	auto user = argv[1];
	auto group = user.strchr(':');
	if(group)
		*group++ = '\0'; // "user:group\0" ====> "user\0group\0"

	import core.sys.posix.pwd : getpwuid, getpwnam;
	auto pw = user.getByNameOrId!(getpwuid, uid_t, getpwnam);

	if(pw is null && errno)
		"Error while getting user '%s': %s"
			.fail!errno(user, errno.strerror);

	if(pw is null)
		"User '%s' doesn't exist".fail(user);

	immutable uid = pw.pw_uid;
	auto gid = pw.pw_gid;

	if(group && group[0] != '\0') {
		import core.sys.posix.grp : getgrgid, getgrnam;

		auto gr = group.getByNameOrId!(getgrgid, gid_t, getgrnam);
		if(gr is null && errno)
			"Error while getting group '%s': %s"
				.fail!errno(group, user, errno.strerror);

		if(gr is null)
			"Group '%s' doesn't exist".fail(group);

		gid = gr.gr_gid;
	}

	if(uid == getuid && gid == getgid) {
		argv[2].execvp(&argv[2]);

		return 1;
	}

	import core.sys.posix.stdlib : setenv;
	"HOME".setenv(pw.pw_dir, 1);

	if(group && group[0] != '\0') {
		if(1.setgroups(&gid) < 0)
			"Error while setting group '%s': %s"
				.fail!errno(group, errno.strerror);
	} else {
		import core.stdc.stdlib : realloc;
		int ngroups;
		gid_t* gl;

		while(true) {
			if(pw.pw_name.getgrouplist(gid, gl, &ngroups) >= 0) {
				if(ngroups.setgroups(gl) < 0)
					"Error while setting groups: %s"
						.fail!errno(errno.strerror);
				break;
			}

			gl = cast(typeof(gl)) gl.realloc(ngroups * gid_t.sizeof);
			if(gl is null) "Out of memory".fail!(-1);
		}

		if(gl !is null)
			gl.realloc(0);
	}

	if(gid.setgid < 0)
		"Error while changing group: %s".fail!errno(errno.strerror);

	if(uid.setuid < 0)
		"Error while changing user: %s".fail!errno(errno.strerror);

	argv[2].execvp(&argv[2]);

	return 1;
}
