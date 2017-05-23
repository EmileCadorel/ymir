module utils.Mangler;
import std.string, std.outbuffer;
import semantic.pack.FrameProto;
import semantic.pack.FinalFrame;
import semantic.types.StructInfo;
import semantic.pack.Namespace;
import std.format, std.conv;
import syntax.Keys;

class Mangler {

    private this () {}

    static string mangle (string type : "file") (string name) {
	auto buf = new OutBuffer ();
	foreach (it ; name) {
	    if (it == '/') buf.write (".");
	    else buf.writef ("%c", it);
	}
	return buf.toString;
    }

    static string mangle (string type : "function") (string name, FrameProto frame) {
	if (name == Keys.MAIN.descr || frame.externC) return name;
	auto namespace = frame.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("_Y%s%sF", mangle!"namespace" (namespace), mangle!"namespace" (name));
	foreach (it ; frame.vars) {
	    buf.write (it.info.type.simpleTypeString);
	}
	buf.writef ("Z%s", frame.type.type.simpleTypeString);
	return buf.toString;
    }       

    static string mangle (string type : "struct") (StructCstInfo str) {
	auto buf = new OutBuffer ();
	buf.write ("ST");
	auto name = str.namespace.toString;
	buf.writef ("%s%d%s", mangle!"namespace" (name), str.name.length, str.name);
	return buf.toString;
    }

    static string mangle (string type : "struct") (StructInfo str) {
	auto buf = new OutBuffer ();
	buf.write ("ST");
	auto name = str.namespace.toString;
	buf.writef ("%s%d%s", mangle!"namespace" (name), str.name.length, str.name);
	return buf.toString;
    }
    
    static string mangle (string type : "function") (FinalFrame frame) {
	auto name = frame.name;
	if (name == Keys.MAIN.descr) return name;
	auto namespace = frame.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("_Y%s%sF", mangle!"namespace" (namespace), mangle!"namespace" (name));
	foreach (it ; frame.vars) {
	    buf.write (it.info.type.simpleTypeString);
	}
	buf.writef ("Z%s", frame.type.type.simpleTypeString);
	return buf.toString;
    }       

    static string mangle (string type : "namespace") (string name) {
	auto buf = new OutBuffer;
	while (true) {
	    auto index = name.indexOf (".");
	    if (index != -1) {
		auto curr = mangle!"var" (name [0 .. index]);
		name = name [index + 1 .. $];
		buf.writef ("%s", curr);
	    } else {
		buf.writef ("%s", mangle!"var" (name));
		break;
	    }
	}
	return buf.toString;
    }
    
    static string mangle (string type : "var") (string name) {
	auto res = name.replace ("(", "N");
	res = res.replace (")", "N");
	res = res.replace (",", "U");
	res = res.replace ("'", "G");
	auto fin = "";
	foreach (it ; res) {
	    if ((it < 'a' || it > 'z') &&
		(it < 'A' || it > 'Z') &&
		(it < '0' ||  it > '9') &&
		(it != '_')
	    ) {
		fin ~=  to!string (to!short (it));
	    } else fin ~= to!string (it);
	}   			    
	return format ("%d%s", fin.length, fin.replace ("!", "T"));
    }

    static string mangle (string type : "tuple") (Namespace space, string name) {
	return format ("TU%s%s", mangle!"namespace" (space.toString), name);	
    }

    
    
}
