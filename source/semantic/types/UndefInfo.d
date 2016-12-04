module semantic.types.UndefInfo;
import semantic.types.InfoType, utils.exception;


class UndefInfo : InfoType {

    override bool isSame (InfoType) {
	return false;
    }
    
    override string typeString () {
	return "undef";
    }

    override InfoType clone () {
	return new UndefInfo ();
    }
    
}
