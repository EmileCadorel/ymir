module ymir.dtarget.DType;
import ymir.lint._;
import std.format;

class DType {

    private string _name;

    private bool _isConst;

    this (string name, bool isConst = false) {
	this._name = name;
	this._isConst = isConst;
    }

    this (LSize size, bool isConst = false) {
	this._name = size.value;
	this._isConst = isConst;
    }
    
    string name () {
	return this._name;
    }

    ref bool isConst () {
	return this._isConst;
    }
    
    override string toString () {
	// if (this._isConst && this._name != "void") {
	//     return format ("const (%s)", this._name);
	// } else 
	return this._name;
    }

    string simpleString () {
	return this._name;
    }
    
}
