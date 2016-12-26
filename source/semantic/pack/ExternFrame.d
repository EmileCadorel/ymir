module semantic.pack.ExternFrame;
import semantic.types.InfoType;
import ast.ParamList, semantic.pack.Frame;
import std.container, ast.Var, std.conv;
import semantic.pack.Table, semantic.pack.Symbol;
import semantic.types.UndefInfo, semantic.types.VoidInfo;
import semantic.pack.FrameTable, syntax.Word, ast.Proto;

class ExternFrame : Frame {

    private string _name;
    private string _namespace;
    private Proto _proto;
    private string _from;
    private FrameProto _fr;
    
    this (string namespace, string from, Proto func) {
	super (namespace, null);
	this._name = func.ident.str;
	this._from = from;
	this._proto = func;
    }
    
    override ApplicationScore isApplicable (ParamList params) {
	auto score = new ApplicationScore (this._proto.ident);
	if (params.params.length == 0 && this._proto.params.length == 0) {
	    score.score = 10; return score;
	} else if (params.params.length == this._proto.params.length) {
	    foreach (it ; 0 .. params.params.length) {
		auto param = this._proto.params [it];
		InfoType info = null;
		if (cast (TypedVar) param !is null) {
		    info = (cast(TypedVar)param).getType ();
		    auto type = params.params [it].info.type.CompOp (info);
		    if (info.isSame (type)) {
			score.score += SAME;
			score.treat.insertBack (null);  
		    } else if (type !is null) {
			score.score += AFF;
			score.treat.insertBack (type);  
		    } else return null;

		} else {
		    score.score += AFF;
		    score.treat.insertBack (null);
		}
	    }
	    return score;
	}
	return null;
    }

    override FrameProto validate () {
	string name = this._name;
	if (this._from is null || this._from != "C") {
	    name = this._namespace ~ to!string (this._name.length) ~ this._name;
	    name = "_YN" ~ to!string (name.length) ~ name;
	}
	
	Table.instance.enterFrame (name, this._proto.params.length);

	Array!Var finalParams;
	foreach (it ; 0 .. this._proto.params.length) {
	    auto info = this._proto.params [it].expression;
	    finalParams.insertBack (info);
	    finalParams.back ().info.id = it + 1;
	    auto t = finalParams.back ().info.type.typeString ();
	    if (name != "main" && (this._from is null || this._from != "C"))
		name ~= super.mangle (t) ~ to!string (to!short (' '));
	}
	    
	    
	Table.instance.setCurrentSpace (name);
	
	if (this._proto.type is null) {
	    Table.instance.retInfo.info = new Symbol (Word.eof (), new VoidInfo ());
	} else {
	    Table.instance.retInfo.info = this._proto.type.asType ().info;
	}
	    
	this._fr = new FrameProto (name, Table.instance.retInfo.info, finalParams);
	Table.instance.quitFrame ();
	return this._fr;
    }

    override FrameProto validate (ParamList) {
	return validate ();
    }
        
}    
