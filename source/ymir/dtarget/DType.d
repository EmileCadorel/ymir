module ymir.dtarget.DType;
import ymir.lint._;

class DType {

    string _name;

    this (string name) {
	this._name = name;
    }

    this (LSize size) {
	this._name = size.value;
    }
    
    string name () {
	return this._name;
    }
    
    override string toString () {
	return this._name;
    }
    
}
