module ymir.utils.Mangler;
import ymir.semantic._;
import ymir.syntax._;
import ymir.utils._;

import std.string, std.outbuffer;
import std.format, std.conv;
import core.demangle;

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

    static string mangleD (string type : "PFunction") (PtrFuncInfo info) {
	auto buf = new OutBuffer ();
	foreach (it ; info.params) {
	    buf.writef ("%s", mangleD!"type" (it));
	}
	return format ("PF%sZ%s", buf.toString (), mangleD!"type" (info.ret));
    }

    static string mangleD (string type : "struct") (StructInfo info) {
	auto space = info.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("S%s", mangle!"namespace" (space));
	auto name = mangle!"struct" (info);
	buf.writef ("%d%s", name.length, name);
	return buf.toString ();
    }

    static string mangleD (string type : "tuple") (TupleInfo info) {
	auto buf = new OutBuffer ();
	buf.write ("S3std8typecons14__T5Tuple");
	foreach (it; info.params) {
	    buf.writef ("T%s", mangleD!"type" (it));
	}
	buf.write ("Z5Tuple");
	return buf.toString ();
    }
    
    static string mangleD (string type : "type") (InfoType type) {
	return type.matchRet (
	    (ArrayInfo info) => "A" ~ mangleD!"type" (info.content),
	    (BoolInfo info) => "b",
	    (CharInfo ch) => "a",
	    (DecimalInfo info) => info.type.sname,
	    (EnumInfo info) => mangleD!"type" (info.content),
	    (FloatInfo info) => "d",
	    (PtrFuncInfo info) => mangleD!"PFunction" (info),
	    (PtrInfo info) => "P" ~ mangleD!"type" (info.content),
	    (RangeInfo info) {
		auto type = mangleD!("type") (info.content);
		return format ("S3std8typecons14__T5TupleT%sT%sZ5Tuple", type, type);
	    },
	    (RefInfo info) => "K" ~ mangleD!"type" (info.content),
	    (StringInfo info) => "Aya",
	    (StructInfo info) => mangleD!"struct" (info),
	    (TupleInfo info) => mangleD!"tuple" (info),
	    (VoidInfo info) => "v"
	);
    }
    
    static string mangleD (string type : "function") (string name, FrameProto frame) {
	auto namespace = frame.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("_D%s%sF", mangle!"namespace" (namespace), mangle!"namespace" (name));
	foreach (it ; frame.vars) {
	    std.stdio.writeln (it.info.type, " ", mangleD!"type" (it.info.type));
	    buf.write (mangleD!"type" (it.info.type));
	}
	buf.writef ("Z%s", mangleD!"type" (frame.type.type));
	return buf.toString ();
    }
    
    static string mangle (string type : "function") (string name, FrameProto frame) {
	if (name == Keys.MAIN.descr || frame.externName == "C") return name;
	else if (frame.externName == "D") return mangleD!"function" (name, frame);
	
	auto namespace = frame.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("_Y%s%sF", mangle!"namespace" (namespace), mangle!"namespace" (name));
	foreach (it ; frame.vars) {
	    buf.write (mangle!"type" (it.info.type.simpleTypeString));
	}
	buf.writef ("Z%s", mangle!"type" (frame.type.type.simpleTypeString));
	return buf.toString;
    }       

    static string mangle (string type : "functionv") (string name, FrameProto frame) {
	if (name == Keys.MAIN.descr || frame.externName == "C") return name;
	else if (frame.externName == "D") return mangleD!"function" (name, frame);
	
	auto namespace = frame.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("_Y%s%sVF", mangle!"namespace" (namespace), mangle!"namespace" (name));
	foreach (it ; frame.vars) {
	    buf.write (mangle!"type" (it.info.type.simpleTypeString));
	}
	buf.writef ("Z%s", mangle!"type" (frame.type.type.simpleTypeString));
	return buf.toString;
    }       
   
    static string mangle (string type : "method") (string name, FrameProto frame) {
	if (name == Keys.MAIN.descr || frame.externName == "C") return name;
	else if (frame.externName == "D") return mangleD!"function" (name, frame);
	
	auto namespace = frame.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("_Y%s%sPM", mangle!"namespace" (namespace), mangle!"namespace" (name));
	foreach (it ; frame.vars) {
	    buf.write (mangle!"type" (it.info.type.simpleTypeString));
	}
	buf.writef ("Z%s", mangle!"type" (frame.type.type.simpleTypeString));
	return buf.toString;
    }       

    static string mangle (string type : "methodInside") (string name, FrameProto frame) {
	if (name == Keys.MAIN.descr || frame.externName == "C") return name;
	else if (frame.externName == "D") return mangleD!"function" (name, frame);
	
	auto namespace = frame.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("M%sPM", mangle!"namespace" (name));
	foreach (it ; frame.vars) {
	    buf.write (mangle!"type" (it.info.type.simpleTypeString));
	}
	buf.writef ("Z%s", mangle!"type" (frame.type.type.simpleTypeString));
	return buf.toString;
    }       
    
    static string mangle (string type : "struct") (StructCstInfo str) {
	auto buf = new OutBuffer ();
	buf.write ("ST");
	auto name = str.namespace.toString;
	buf.writef ("%s%s", mangle!"namespace" (name), mangle!"type" (str.name));
	return buf.toString;
    }

    static string mangle (string type : "struct") (StructInfo str) {
	auto buf = new OutBuffer ();
	buf.write ("ST");
	auto name = str.namespace.toString;
	buf.writef ("%s%s", mangle!"namespace" (name), mangle!"type" (str.name));
	return buf.toString;
    }
    
    static string mangle (string type : "function") (FinalFrame frame) {
	auto name = frame.name;
	if (name == Keys.MAIN.descr) return name;
	auto namespace = frame.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("_Y%s%sF", mangle!"namespace" (namespace), mangle!"namespace" (name));
	foreach (it ; frame.vars) {
	    buf.write (mangle!"type" (it.info.type.simpleTypeString));
	}
	buf.writef ("Z%s", mangle!"type" (frame.type.type.simpleTypeString));
	return buf.toString;
    }       

    static string mangle (string type : "functionv") (FinalFrame frame) {
	auto name = frame.name;
	if (name == Keys.MAIN.descr) return name;
	auto namespace = frame.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("_Y%s%sVF", mangle!"namespace" (namespace), mangle!"namespace" (name));
	foreach (it ; frame.vars) {
	    buf.write (mangle!"type" (it.info.type.simpleTypeString));
	}
	buf.writef ("Z%s", mangle!"type" (frame.type.type.simpleTypeString));
	return buf.toString;
    }       

    
    static string mangle (string type : "function") (Namespace namespace) {
	auto buf = new OutBuffer ();
	buf.writef ("_Y%sF", mangle!"namespace" (namespace.toString));
	buf.writef ("Zv");
	return buf.toString;
    }       

    static string mangle (string type : "method") (FinalFrame frame) {
	auto name = frame.name;
	if (name == Keys.MAIN.descr) return name;
	auto namespace = frame.namespace.toString;
	auto buf = new OutBuffer ();
	buf.writef ("_Y%s%sPM", mangle!"namespace" (namespace), mangle!"namespace" (name));
	foreach (it ; frame.vars) {
	    buf.write (mangle!"type" (it.info.type.simpleTypeString));
	}
	buf.writef ("Z%s", mangle!"type" (frame.type.type.simpleTypeString));
	return buf.toString;
    }       

    static string mangle (string type : "method") (Namespace namespace) {
	auto buf = new OutBuffer ();
	buf.writef ("_Y%sPM", mangle!"namespace" (namespace.toString));
	buf.writef ("Zv");
	return buf.toString;
    }       

    
    static string mangleD (string type : "namespace") (string name) {
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

    static string mangle (string type : "type") (string name) {
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
	return fin;
    }

    
    static string mangle (string type : "tuple") (Namespace space, string name) {
	return format ("TU%s%s", mangle!"namespace" (space.toString), name);	
    }

    
    
}
