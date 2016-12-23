import std.stdio;
import std.process, std.file, std.path;


void main(string [] args) {
    string dir = "test";
    if (args.length >= 2)
	dir = args [1];	
    foreach (string entry ; dirEntries (dir, SpanMode.shallow)) {
	if (extension (entry) == ".yr") {
	    auto pid = spawnProcess (["./ymir"] ~ [entry]);
	    wait (pid);
	    spawnProcess (["./a.out"], std.stdio.stdin, File(entry ~ ".test", "w"));
	    spawnProcess (["diff"] ~ [entry ~ ".outTest"] ~ ["test"], std.stdio.stdin,
			  File (entry ~ ".res", "w"));
	}
    }
}
