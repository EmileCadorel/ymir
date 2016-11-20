module semantic.pack.Scope;
import semantic.pack.Symbol;

import std.container, std.outbuffer, std.string;
import std.algorithm;

class Scope {

    Symbol [string] _local;
    
    this () {}

    Symbol opIndex (string name) {
	auto it = (name in this._local);
	if (it !is null) return *it;
	else return null;
    }

    void opIndexAssign (Symbol data, string name) {
	this._local [name] = data;
    }
    
    
    void quit (string namespace) {
	foreach (key, value; this._local) {
	    value.quit (namespace);
	}
    }

}
