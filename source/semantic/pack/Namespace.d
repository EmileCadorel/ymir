module semantic.pack.Namespace;
import std.container;
import std.outbuffer;
import utils.Mangler;

/++
 Classe qui contient l'emplacement courant d'un élément 
 +/
class Namespace {

    private SList!string _names;
    
    this (string name) {
	this._names.insertFront (Mangler.mangle!"file" (name));
    }

    this (Namespace namespace, string name) {
	if (namespace) {
	    this._names = namespace._names.dup;
	    this._names.insertFront (name);
	} else {
	    this._names.insertFront (Mangler.mangle!"file" (name));
	}
	
    }
    
    override bool opEquals (Object other) {
	if (auto name = cast (Namespace) other) {
	    return this._names == name._names;
	}
	return false;
    }        
    
    override string toString () {
	auto buf = new OutBuffer ();
	foreach (it ; this._names) {
	    buf.writef (".%s", it);
	}
	return buf.toString;
    }
}
