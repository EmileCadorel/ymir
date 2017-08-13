module lint.tree.Flow;
import std.container;
import lint.all;
import std.stdio;

class Flow {

    struct Edge {
	LLabel origin;
	LLabel end;
	LExp test;
    }

    private Array!Edge _edges;
    private LInstList [LLabel] _flows;
    
    this (LInstList list) {
	LLabel curr = new LLabel (); bool dir;
	this._flows [curr] = new LInstList;
	foreach (it ; list.insts) {
	    if (auto ll = cast (LLabel) it) {
		if (dir) 
		    this._edges.insertBack (Edge (curr, ll));
		curr = ll;
		dir = true;
		this._flows [curr] = new LInstList;
	    } else if (auto lg = cast (LGoto) it) {
		dir = false;		
		this._edges.insertBack (Edge (curr, lg.lbl));
		this._flows [curr] += (list);		    
	    } else if (auto lj = cast (LJump) it) {
		this._edges.insertBack (Edge (curr, lj.lbl, lj.test));
		this._flows [curr] += (it);
	    } else {
		this._flows [curr] += (it);
	    }
	}	
    }

    private LReg getReg (LExp exp) {
	if (auto reg = cast (LReg) exp) return reg;
	else if (auto lr = cast (LRegRead) exp) return getReg (lr.data);
	else assert (false, "TODO " ~ typeid (exp).toString);
    }
    
    private bool isInside (LReg left, LExp right) {
	if (auto lu = cast (LUnop) right) {
	    return isInside (left, lu.elem);
	} else if (auto lr = cast (LRegRead) right) {
	    return isInside (left, lr.data);
	} else if (auto reg = cast (LReg) right) {
	    return left.id == reg.id;
	} else if (auto lc = cast (LConst) right) {
	    return false;
	} else if (auto lc = cast (LCast) right) {
	    return isInside (left, lc.what);
	} else if (auto lc = cast (LCall) right) {
	    foreach (it ; lc.params) {
		if (isInside (left, it)) return true;
	    }
	    return false;
	} else if (auto lb = cast (LBinop) right) {
	    return isInside (left, lb.left) || isInside (left, lb.right);
	} else if (auto la = cast (LAddr) right) {
	    return isInside (left, la.exp);
	} else return false;	
    }
    
    private bool isAtRight (LReg left, LInst inst) {
	if (auto lj = cast (LJump) inst) {
	    return isInside (left, lj.test);
	} else if (auto wr = cast (LWrite) inst) {
	    return isInside (left, wr.right);
	} else if (auto ll = cast (LLocus) inst) {
	    return false;
	} else if (auto le = cast (LExp) inst) {
	    return isInside (left, le);
	} else if (auto ll = cast (LLabel) inst) {
	    return false;
	} else if (auto lg = cast (LGoto) inst) {
	    return false;
	} else assert (false, "TODO " ~ typeid(inst).toString);
    }
    
    private bool isUseFull (LWrite wr) {
	auto left = getReg (wr.left);
	foreach (key, value ; this._flows) {
	    foreach (it ; value.insts) {
		if (isAtRight (left, it)) return true;
	    }
	}
	return false;
    }

    private LInstList computeFlow () {
	auto inst = new LInstList ();
	foreach (it ; this._edges) {
	    this._flows [it.origin] += new LGoto (it.end);
	}
	
	foreach (key, value ; this._flows) {
	    writeln ("ICI ", key.toSimpleString);
	    writeln (value);
	    writeln ("LA ");
	    inst += value;
	}
	return inst;
    }
    
    /++
     Applique toutes les optimisations statique connu pour le langage intermediaire.
     Returns: la liste des instructions optimisés
     +/
    LInstList optimise () {
	foreach (key, value ; this._flows) {
	    auto inst = new LInstList ();
	    foreach (it ; value.insts) {
		if (auto wr = cast (LWrite) it) {
		    if (isUseFull (wr)) inst += wr;
		} else 
		    inst += it;
	    }
	    this._flows [key] = inst;
	}
	return this.computeFlow ();
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
