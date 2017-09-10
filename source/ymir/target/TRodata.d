module ymir.target.TRodata;
import ymir.utils.Singleton, ymir.target.TInstList;

class TData {

    static protected TInstList __insts__;    
    
    static ref TInstList insts () {
	if (__insts__ is null)
	    __insts__ = new TInstList ;
	return __insts__;
    }

}


class TRodata {

    static protected TInstList __insts__;    
    
    static ref TInstList insts () {
	if (__insts__ is null)
	    __insts__ = new TInstList ;
	return __insts__;
    }
    
}
