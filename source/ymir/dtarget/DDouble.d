module ymir.dtarget.DDouble;
import ymir.dtarget._;

class DDouble : DExpression {
    
    private string _value;

    this (string value) {
	this._value = value;
    }

    override string toString () {
	return this._value;
    }    

}
