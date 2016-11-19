module semantic.pack.UnPureFrame;
import ast.Function, semantic.types.InfoType;
import ast.ParamList, semantic.pack.Frame;
import std.container, ast.Var, std.conv;
import semantic.pack.Table, semantic.pack.Symbol;
import semantic.types.UndefInfo, semantic.types.VoidInfo;
import semantic.pack.FrameTable, syntax.Word;

class UnPureFrame : Frame {
    
    private string _name;
    private string _namespace;
    
    
    this (string namespace, Function func) {
	super (func);
	this._namespace = namespace;
	this._name = func.ident.str;
    }

    override FinalFrame validate (ParamList params) {
	string name = this._namespace ~ to!string (this._name.length) ~ this._name;
	name = "_YN" ~ to!string (name.length) ~ name;
	    
	Table.instance.enterFrame (name);

	Array!Var finalParams;
	foreach (it; 0 .. this._function.params.length) {
	    if (cast(TypedVar)this._function.params [it] is null) {
		auto var = this._function.params [it].setType (params.params [it].info);	    
		finalParams.insertBack (var.expression);
	    } else finalParams.insertBack (this._function.params [it].expression);
	    auto t = finalParams.back ().info.type.typeString ();
	    name ~= to!string(t.length) ~ t[0];
	}
	
	Table.instance.setCurrentSpace (name);
	auto fr = FrameTable.instance.existFinal (name);
	if (fr is null) {	
	    if (this._function.type is null) {
		Table.instance.retInfo.info = new Symbol (Word.eof (), new UndefInfo ());
	    } else {
		Table.instance.retInfo.info = this._function.type.asType ().info;
	    }	

	    auto block = this._function.block.block ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }

	    fr =  new FinalFrame (Table.instance.retInfo.info,
				       name,
				       finalParams, block);
	
	    FrameTable.instance.insert (fr);	
	    fr.last = Table.instance.quitFrame ();
	    return fr;
	}
	
	Table.instance.quitFrame ();
	return fr;
    }
    
}
