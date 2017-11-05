module ymir.semantic.impl.ConstructorInfo;
import ymir.ast._;
import ymir.semantic._;

import std.container, std.outbuffer;
import std.stdio;


class ConstructorInfo : FunctionInfo {

    /++
     Surcharge une méthode ancetre.
     +/
    private bool _override;
    
    this (Namespace space, string name, Frame info) {
	super (space, name);
	this.set (info);
	super.alone = true;
    }

    override Expression toYmir () {
	assert (false);
    }
    
    ref bool isOverride () {
	return this._override;
    }
    
}
