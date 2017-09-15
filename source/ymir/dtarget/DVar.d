module ymir.dtarget.DVar;
import ymir.dtarget._;

class DVar : DExpression {

    private string _name;

    this (string name) {
	this._name = name;
    }

    override string toString () {
	return this._name;
    }    
}
