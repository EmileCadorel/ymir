module lint.tree.Flow;
import std.container;
import lint.LInstList, lint.LJump, lint.LGoto, lint.LLabel;
import lint.LExp;

class Flow {

    struct Edge {
	LLabel origin;
	LLabel end;
	LExp test;
    }

    Array!Edge _edges;
    
    
    this (LInstList list) {
	LLabel curr; bool dir;
	foreach (it ; list.insts) {
	    if (auto ll = cast (LLabel) it) {
		if (dir && curr) 
		    this._edges.insertBack (Edge (curr, ll));
		curr = ll;
		dir = true;
	    } else if (auto lg = cast (LGoto) it) {
		dir = false;
		if (curr)
		    this._edges.insertBack (Edge (curr, lg.lbl));
	    } else if (auto lj = cast (LJump) it) {
		if (curr)
		    this._edges.insertBack (Edge (curr, lj.lbl, lj.test));
	    }	    
	}	
    }


    string toDot (string name) {
	import std.outbuffer;
	auto g = new OutBuffer ();
	g.writefln ("digraph %s {", name);
	foreach (it ; this._edges) {
	    if (it.test)
		g.writefln ("%s -> %s [label=\"%s\"]", it.origin.toSimpleString, it.end.toSimpleString, it.test.toString);
	    else
		g.writefln ("%s -> %s", it.origin.toSimpleString, it.end.toSimpleString);
	}
	g.writefln ("}");
	return g.toString;
    }
    
    
    

}
