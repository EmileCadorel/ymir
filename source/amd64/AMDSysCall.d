module amd64.AMDSysCall;
import target.TInst;


class AMDSysCall : TInst {

    private string _name;
    
    this (string name) {
	this._name = toReal (name);
    }

    private string toReal (string elem) {
	if (elem == "alloc") return "malloc";
	else if (elem == "print_c") return "putchar";
	else return elem;
    }
    
    override string toString () {
	return "\tcall\t" ~ this._name;
    }

}