module ymir.dtarget.DInstruction;
import ymir.dtarget._;
import ymir.lint._;

abstract class DInstruction : LInstList {

    protected DBlock _father;

    final ref DBlock father () {
	return this._father;
    }
    
}

