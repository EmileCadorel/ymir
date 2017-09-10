module ymir.ast.Self;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

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
	Table.instance.quitFrame ();
    }

    override void declareAsExtern (Module) {
    }

}
