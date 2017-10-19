module ymir.semantic.pack.Namespace;
import ymir.utils._;

import std.container;
import std.outbuffer;
import std.string;

/++
 Classe qui contient l'emplacement courant d'un élément 
 +/
class Namespace {

    private Array!string _names;

    private this () {}
    
    this (string name) {
	auto space = Mangler.mangle!"file" (name);
	auto index = space.indexOf (".");
	while (index != -1) {
	    auto str = space [0 .. index];
	    space = space [index + 1 .. $];
	    this._names.insertBack (str);
	    index = space.indexOf (".");
	}
	this._names.insertBack (space);
    }

    this (Namespace namespace, string name) {
	if (namespace) {
	    this (name);
	    this._names = namespace._names.dup ~ this._names;	    
	} else {
	    this (name);
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

    Namespace addSuffix (string suff) {
	Array!string aux, news;
	foreach (it ; this._names) {	    
	    aux.insertBack (it ~ suff);	    
	}
	auto space = new Namespace ();
	space._names = aux;
	return space;
    }

    string directory () {
	auto buf = new OutBuffer ();
	foreach (it ; this._names [0 .. $ - 1]) {
	    buf.writef ("%s/", it);
	}
	return buf.toString ();
    }
    
    string asFile (string ext) {
	auto buf = new OutBuffer ();
	foreach (it ; this._names) {
	    buf.write (it);
	    if (it !is this._names [$ - 1]) buf.write ("/");
	}
	buf.write (ext);
	return buf.toString ();
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
