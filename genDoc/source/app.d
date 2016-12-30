import std.stdio;
import std.file;
import std.path;
import std.outbuffer;

void main(string [] args) {
    writeln ("MODULES =");
    foreach (string it ; dirEntries (args [1], SpanMode.breadth)) {
	string name;
	auto ext = extension (it);
	if (ext == ".d") {
	    auto buf = new OutBuffer ();
	    name = it [args [1].length .. $ - ext.length];
	    foreach (ref ch ; name) {
		if (ch == '/') buf.write ('.');
		else buf.write (ch);
	    }
	    writefln ("\t$(MODULE %s)", buf.toString);
	}
    }
}
