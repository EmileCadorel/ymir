module ymir.dtarget.DExpression;
import ymir.dtarget._;

abstract class DExpression : DInstruction {

    private DBlock _pre;

    final ref DBlock pre () {
	return this._pre;
    }
    
}
