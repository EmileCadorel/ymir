module semantic.types.StaticArrayInfo;
import semantic.types.InfoType, utils.exception;
import semantic.value.Value;
import semantic.types.UndefInfo;
import semantic.types.ArrayInfo;
import semantic.types.ArrayUtils;
import semantic.types.DecimalInfo, ast.Constante;
import std.bigint;
import std.conv;

class StaticArrayInfo : ArrayInfo {

    /++ La taille du tableau statique +/
    private ulong _length;
    
    this (InfoType content, Value length) {
	super (content);
	this._length = (cast (DecimalValue) length).value.to!ulong;
	this._destruct = null;
    }
    
    this (InfoType content, ulong length) {
	super (content);
	this._length = length;
	this._destruct = null;
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
    
