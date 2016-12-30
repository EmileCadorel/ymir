module semantic.pack.Scope;
import semantic.pack.Symbol;

import std.container, std.outbuffer, std.string;
import std.algorithm;

class Scope {

    Symbol [string] _local;
    Array!Symbol _garbage;    
    
    this () {}

    Symbol opIndex (string name) {
	auto it = (name in this._local);
	if (it !is null) return *it;
	else return null;
    }

    void opIndexAssign (Symbol data, string name) {
	this._local [name] = data;
    }

    void garbage (Symbol info) {
	this._garbage.insertBack (info);
    }

    void clear () {
	this._local.clear ();
	this._garbage.clear ();
    }    
    
    Array!Symbol quit (string namespace) {
	foreach (key, value; this._local) {
	    value.quit (namespace);
	}
	return this._garbage;
    }

}
