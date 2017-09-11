import reggae;

enum errnoFixObj = Target("errnofix.o",
			options.cCompiler ~ " -c -o $out $in",
			Target("errnofix.c"));

enum goinsuObj = Target("goinsu.o",
			// TODO: remove -version=BetterC
			"dmd -betterC -version=BetterC -release -O -c -of$out $in",
			Target("goinsu.d"));

mixin build!(Target("goinsu",
		options.cCompiler ~ " -O -o$out $in",
		[
			goinsuObj,
			errnoFixObj
		]));
