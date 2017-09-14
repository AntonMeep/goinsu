import reggae;
import std.format : format;

enum ARCH = userVars.get("ARCH", "x86");

enum errnoFixObj = Target("errnofix.o",
	"%s -c %s -o $out $in"
		.format(options.cCompiler,
			ARCH == "x86" ? "-m32" : "-m64"),
	Target("errnofix.c")
);

enum goinsuObj = Target("goinsu.o",
	// TODO: remove -version=BetterC
	"%s -betterC -version=BetterC -release -O -c %s -of$out $in"
		.format(options.dCompiler,
			ARCH == "x86" ? "-m32" : "-m64"),
	Target("goinsu.d")
);

mixin build!(
	Target("goinsu",
		"%s -O %s -o $out $in"
			.format(options.cCompiler,
				ARCH == "x86" ? "-m32" : "-m64"),
		[
			errnoFixObj,
			goinsuObj,
		]
	),
	Target.phony("clean", "rm -f goinsu").optional,
);

