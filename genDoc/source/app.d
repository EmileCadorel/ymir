import std.stdio;
import std.file;
import std.path;
import std.outbuffer;
import std.algorithm;
import std.array;
import std.string;

void main(string [] args) {
    writeln ("MODULES =");
    foreach (it ; dirEntries (args [1], SpanMode.breadth)
	     .filter! (f => f.name.endsWith (".d"))
	     .map!(a => a.name)
	     .array.sort!("a < b")) {
	
	string name;
	auto ext = extension (it);
	auto buf = new OutBuffer ();
	name = it [args [1].length .. $ - ext.length];
	if (indexOf (name, '#') == -1) {
	    foreach (ref ch ; name) {
		if (ch == '/') buf.write ('.');
		else buf.write (ch);
	    }
	    writefln ("\t$(MODULE %s)", buf.toString);
	}
    }
}
