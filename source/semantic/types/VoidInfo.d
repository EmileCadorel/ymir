module semantic.types.VoidInfo;
import semantic.types.InfoType, utils.exception;


class VoidInfo : InfoType {

    override string typeString () {
	return "void";
    }
    
}
