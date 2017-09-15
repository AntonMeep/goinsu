import reggae;
import std.format : format;

enum ARCH	= userVars.get("ARCH", "x86");
enum BUILD_STATIC	= userVars.get("BUILD_STATIC", false);
enum STATIC_LIBC	= userVars.get("STATIC_LIBC", "");

enum errnoFixObj = Target("errnofix.o",
	"%s -c %s $in -o $out"
		.format(options.cCompiler,
			ARCH == "x86" ? "-m32" : "-m64"),
	Target("errnofix.c")
);

enum goinsuObj = Target("goinsu.o",
	// TODO: remove -version=BetterC
	"%s -betterC -version=BetterC -release -O -c %s $in -of$out"
		.format(options.dCompiler,
			ARCH == "x86" ? "-m32" : "-m64"),
	Target("goinsu.d")
);

mixin build!(
	Target("goinsu",
		"%s -O %s $in %s -o $out"
			.format(options.cCompiler,
				ARCH == "x86" ? "-m32" : "-m64",
				BUILD_STATIC ? "-static " ~ STATIC_LIBC : " "),
		[
			errnoFixObj,
			goinsuObj,
		]
	),
	Target.phony("clean", "rm -f goinsu").optional,
);

