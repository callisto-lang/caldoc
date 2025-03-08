module caldoc.app;

import std.file;
import std.path;
import std.stdio;
import std.format;
import std.string;
import std.algorithm;

static string[] sections;
static string   outputDir;

void DocumentDir(string path) {
	string outPath = format("%s/%s", outputDir, path.baseName());

	if (!exists(outPath)) {
		mkdir(outPath);
	}

	foreach (DirEntry entry ; dirEntries(path, SpanMode.shallow)) {
		if (
			!entry.isFile() ||
			(
				(entry.name.extension() != ".cal") &&
				(entry.name.extension() != ".md")
			)
		) {
			writefln("Skipping %s", entry.name.baseName());
			continue;
		}

		if (entry.name.extension() == ".md") {
			std.file.write(
				format("%s/%s", outPath, entry.name.baseName()), readText(entry.name)
			);

			writefln("Completed %s", entry.name.baseName());
			continue; // can't use goto because "cannot goto into try block" ???
		}

		auto outFile = File(
			format("%s/%s", outPath, entry.name.baseName().setExtension("md")), "w"
		);
		outFile.writefln("# %s", entry.name.baseName().stripExtension());

		foreach (string line ; File(entry.name, "r").lines()) {
			if (!line.strip().startsWith("##")) continue;

			auto docLine = line.strip()[2 .. $].strip();
			outFile.writeln(docLine);
		}

		writefln("Completed %s", entry.name.baseName());
	}
}

static const string appUsage = "
Usage: %s [FLAGS]

Flags:
	-od PATH          - Sets output directory for generated markdown files (no default)
	--section/-s PATH - Adds a new section (a folder containing either .cal or .md files)
	--help            - Shows this usage text
	--index/-i PATH   - Sets index file (must be .md)
";

int main(string[] args) {
	string index;

	if (args.length == 0) {
		writeln("what");
		return 1;
	}
	else if (args.length == 1) {
		writefln(appUsage, args[0]);
		return 0;
	}

	for (size_t i = 1; i < args.length; ++ i) {
		switch (args[i]) {
			case "--help": {
				writefln(appUsage, args[0]);
				return 0;
			}
			case "-od": {
				++ i;

				if (i >= args.length) {
					stderr.writeln("-od requires PATH parameter");
					return 1;
				}
				if (outputDir != "") {
					stderr.writeln("Output directory set multiple times");
					return 1;
				}

				outputDir = args[i];

				if (!exists(outputDir)) {
					mkdir(outputDir);
				}
				break;
			}
			case "-s":
			case "--section": {
				++ i;

				if (i >= args.length) {
					stderr.writefln("%s requires PATH parameter", args[i - 1]);
					return 1;
				}

				sections ~= args[i];
				break;
			}
			case "-i":
			case "--index": {
				++ i;

				if (i >= args.length) {
					stderr.writeln("-od requires PATH parameter");
					return 1;
				}
				if (index != "") {
					stderr.writeln("Output directory set multiple times");
					return 1;
				}

				index = args[i];

				if (!isFile(index) || (index.extension() != ".md")) {
					stderr.writeln("Invalid index path");
					return 1;
				}
				break;
			}
			default: {
				stderr.writefln("No such flag '%s'", args[i]);
				return 1;
			}
		}
	}

	foreach (ref section ; sections) {
		try {
			DocumentDir(section);
		}
		catch (FileException e) {
			stderr.writefln("File exception: %s", e.msg);
			return 1;
		}
	}

	std.file.write(format("%s/index.md", outputDir), readText(index));

	return 0;
}
