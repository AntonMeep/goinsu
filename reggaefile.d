import reggae;
import std.format : format;

mixin build!(
	Target("goinsu",
		"%s -O %s $in -o $out".format(options.cCompiler, userVars.get("STATIC", false) ? "-static " : " "),
		[
			Target("goinsu.o",
				"%s -betterC -release -O -c $in -of$out".format(options.dCompiler),
				Target("goinsu.d")
			),
			Target("version_.o",
				"%s -betterC -release -O -c $in -of$out".format(options.dCompiler),
				Target("version_.d",
					`bash -c "echo 'module version_; enum VERSION=\"$(git -C . describe --tags)\";' > $out"`
				),
			),
		]
	),
	Target.phony("clean", "rm -f goinsu").optional,
);
