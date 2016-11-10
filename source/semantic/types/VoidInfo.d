module semantic.types.VoidInfo;
import semantic.types.InfoType, utils.exception;


class VoidInfo : InfoType {

    override InfoType clone () {
	return new VoidInfo ();
    }
    
    override string typeString () {
	return "void";
    }
    
}
