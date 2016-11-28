module target.TRodata;
import utils.Singleton, target.TInstList;


class TRodata {

    static protected TInstList __insts__;    
    
    static ref TInstList insts () {
	if (__insts__ is null)
	    __insts__ = new TInstList ;
	return __insts__;
    }
    
}
