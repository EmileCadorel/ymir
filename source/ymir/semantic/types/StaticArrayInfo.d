module ymir.semantic.types.StaticArrayInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.bigint;
import std.conv;

class StaticArrayInfo : ArrayInfo {

    /++ La taille du tableau statique +/
    private ulong _length;
    
    this (InfoType content, Value length) {
	super (content);
	this._length = (cast (DecimalValue) length).value.to!ulong;
    }
    
    this (InfoType content, ulong length) {
	super (content);
	this._length = length;
    }
    

    override InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto arr = new StaticArrayInfo (this._content.clone (), this._length);
	    arr.lintInst = &ArrayUtils.InstAffectRightStatic;
	    return arr;
	}
	return null;
    }

    override protected InfoType Length () {	
	auto elem = new DecimalInfo (DecimalConst.ULONG);
	elem.value = new DecimalValue (BigInt (this._length));
	return elem;
    }
    
    ulong length () {
	return this._length;
    }
    
}
    
