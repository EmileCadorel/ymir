module ymir.dtarget.DInsideIf;
import ymir.dtarget._;

import std.format;

class DInsideIf : DExpression {

    private DExpression _test;

    private DExpression _success;

    private DExpression _fail;

    this (DExpression test, DExpression success, DExpression fail) {
	this._test = test;
	this._success = success;
	this._fail = fail;
    }

    override string toString () {
	return format ("(%s ? %s : %s)",
		       this._test.toString,
		       this._success.toString,
		       this._fail.toString);
    }
    

}
