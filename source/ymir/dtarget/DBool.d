module ymir.dtarget.DBool;
import ymir.dtarget._;


class DBool : DExpression {

    private bool _val;
    
    this (bool val) {
	this._val = val;
    }

    override string toString () {
	return this._val ? "true" : "false";
    }    

}
