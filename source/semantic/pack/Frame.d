module semantic.pack.Frame;
import ast.Function, semantic.pack.Table;
import ast.Var, semantic.types.UndefInfo, semantic.pack.Symbol;
import syntax.Word;
import std.stdio, std.conv, std.container;

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
	FinalFrame fr = new FinalFrame (this._namespace, this._function);
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
	Table.instance.quitFrame ();	
    }    
    
}

class FinalFrame {

    private string _namespace;
    private Function _function;
    
    this (string namespace, Function func) {
	this._namespace = namespace;
	this._function = func;
    }
    
}
