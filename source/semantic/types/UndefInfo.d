module semantic.types.UndefInfo;
import semantic.types.InfoType, utils.exception;


class UndefInfo : InfoType {

    override string typeString () {
	return "undef";
    }

}
