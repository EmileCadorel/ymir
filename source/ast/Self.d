module ast.Self;
import ast.Declaration;
import ast.all;
import syntax.Word;
import syntax.Tokens;
import semantic.pack.Table;
import semantic.pack.Symbol;
import utils.exception;
import semantic.types.VoidInfo;

class Self : Declaration {

    private Word _ident;
    
    private Block _block;

    this (Word ident, Block bl) {
	this._ident = ident;
	this._block = bl;
    }

    override void declare () {
	Table.instance.enterFrame (Table.instance.globalNamespace, "self", 0, false);
	Table.instance.retInfo.info = new Symbol (this._ident, new VoidInfo (), true);
	auto ot = this._block.block ();
	foreach (it ; ot.insts) {
	    Table.instance.addStaticInit (it);
	}
    }

    override void declareAsExtern (Module) {
    }

}
