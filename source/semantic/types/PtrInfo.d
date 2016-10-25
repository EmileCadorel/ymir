module semantic.types.PtrInfo;
import semantic.types.InfoType;

class PtrInfo : InfoType {

    private InfoType _content = null;

    this () {}

    override InfoType clone () {
	if (this._content is null)
	    return new PtrInfo ();
	else {
	    auto aux = new PtrInfo ();
	    aux._content = this._content.clone ();
	    return aux;
	}
    }
    
    override string typeString () {
	if (this._content is null) {
	    return "ptr!void";
	} else return "ptr!" ~ this._content.typeString ();
    }
}
