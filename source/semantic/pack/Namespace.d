module semantic.pack.Namespace;
import std.container;
import std.outbuffer;
import utils.Mangler;
import std.string;

/++
 Classe qui contient l'emplacement courant d'un élément 
 +/
class Namespace {

    private Array!string _names;
    
    this (string name) {
	auto space = Mangler.mangle!"file" (name);
	this._names.insertBack (space);
    }

    this (Namespace namespace, string name) {
	if (namespace) {
	    this._names = namespace._names.dup;
	    this._names.insertBack (name);
	} else {
	    this._names.insertBack (Mangler.mangle!"file" (name));
	}	
    }
    
    override bool opEquals (Object other) {
	if (auto name = cast (Namespace) other) {
	    if (this._names.length != name._names.length) return false;
	    foreach (it ; 0 .. this._names.length) {
		if (this._names [it] != name._names [it]) return false;
	    }
	    return true;
	}
	return false;
    }        

    bool isSubOf (Namespace other) {
	if (other !is null) {
	    if (this._names.length <= other._names.length) {
		foreach (it ; 0 .. this._names.length) {
		if (other._names [it] != this._names [it]) {
		    return false;
		}
		}
		return true;
	    }
	}
	return false;
    }

    bool isAbsSubOf (Namespace other) {
	if (this._names.length < other._names.length) {
	    foreach (it ; 0 .. this._names.length) {
		if (other._names [it] != this._names [it]) {
		    return false;
		}
	    }
	    return true;
	}
	return false;
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	foreach (it ; this._names) {	    
	    buf.write (it);
	    if (it !is this._names [$-1])
		buf.write (".");
	}
	return buf.toString;
    }
}
