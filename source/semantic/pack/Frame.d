module semantic.pack.Frame;
import ast.Function, semantic.pack.Table;
import ast.Var, semantic.types.UndefInfo, semantic.pack.Symbol;
import syntax.Word, ast.Block, semantic.pack.FrameTable;
import std.stdio, std.conv, std.container, std.outbuffer;
import semantic.types.VoidInfo;

class PureFrame {

    private string _name;
    private string _namespace;
    private Function _function;
    
    this (string namespace, Function func) {
	this._name = func.ident.str;
	this._namespace = namespace;
	this._function = func;
    }

    void validate () {
	string name = this._name;
	if (this._namespace != "") {
	    name = this._namespace ~ to!string (this._name.length) ~ this._name;
	}
	Table.instance.enterFrame (this._namespace ~
				   to!string (this._name.length) ~
				   this._name);

	Array!Var finalParams;
	foreach (it ; this._function.params) {
	    finalParams.insertBack (it.expression);
	}
	
	if (this._function.type is null) {
	    Table.instance.retInfo.info = new Symbol (Word.eof (), new UndefInfo ());
	} else {
	    Table.instance.retInfo.info = this._function.type.asType ().info;
	}	

	auto block = this._function.block.block ();
	if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
	    Table.instance.retInfo.info.type = new VoidInfo ();
	}

	FrameTable.instance.insert (new FinalFrame (Table.instance.retInfo.info,
						    name,
						    finalParams, block));
	Table.instance.quitFrame ();
    }    
    
}

class FinalFrame {

    private Symbol _type;
    private string _name;
    private Array!Var _vars;
    private Block _block;
    
    this (Symbol type, string name, Array!Var vars, Block block) {
	this._type = type;
	this._vars = vars;
	this._block = block;
	this._name = name;
    }
    
    string name () {
	return this._name;
    }

    Symbol type () {
	return this._type;
    }

    Array!Var vars () {
	return this._vars;
    }

    Block block () {
	return this._block;
    }
}
