module goinsu;

import std.stdio : writefln;
import std.string : toStringz, fromStringz, indexOf;
import std.format : format;
import std.process : environment, execvp;

import core.sys.posix.grp : getgrnam;
import core.sys.posix.pwd : getpwnam;
import core.sys.posix.unistd : getuid, getgid, setuid, setgid;
import core.sys.posix.stdlib : gid_t, setenv;
import core.stdc.errno : errno;
import core.stdc.string : strerror;

extern(C) int setgroups(size_t size, const(gid_t)* list);
extern(C) int getgrouplist(const(char)* user, gid_t group, gid_t* groups, int* ngroups);

int main(string[] args) {
	auto usage = (int code = 0) {
		"Usage: %s user-spec command [args]".writefln(args[0]);
		return code;
	};

	if(args.length < 3)
		return usage(0);

	string user;
	string group;

	if(args[1].indexOf(':') != -1) {
		auto i = args[1].indexOf(':');
		user = args[1][0..i];
		group = args[1][i+1..$];
	} else {
		user = args[1];
	}

	auto pw = user.toStringz.getpwnam;
	if(pw is null && errno)
		throw new Exception("Error while searching for user '%s': %s"
			.format(user, errno.strerror.fromStringz));

	if(pw is null)
		throw new Exception("User '%s' doesn't exist".format(user));

	immutable uid = pw.pw_uid;
	auto gid = pw.pw_gid;

	if(group.length) {
		auto gr = group.toStringz.getgrnam;
		if(gr is null && errno)
			throw new Exception("Error while searching for group '%s': %s"
				.format(group, errno.strerror.fromStringz));

		if(gr is null)
			throw new Exception("User '%s' isn't in group '%s'".format(user, group));

		gid = gr.gr_gid;
	}

	if(uid == getuid && gid == getgid) {
		args[2].execvp(args[2..$]);
		return 1;
	}

	environment["HOME"] = pw.pw_dir.fromStringz;

	int ngroups;
	if(user.toStringz.getgrouplist(gid, null, &ngroups) == -1) {
		gid_t[] groups = new gid_t[ngroups];

		if(user.toStringz.getgrouplist(gid, groups.ptr, &ngroups) == -1)
			assert(0);

		if(setgroups(groups.length, groups.ptr) < 0)
			throw new Exception("Error while setting groups: %s"
				.format(errno.strerror.fromStringz));
	}

	if(gid.setgid < 0)
		throw new Exception("Error while changing group: %s"
			.format(errno.strerror.fromStringz));

	if(uid.setuid < 0)
		throw new Exception("Error while changing user: %s"
			.format(errno.strerror.fromStringz));

	args[2].execvp(args[2..$]);

	return 1;
}
