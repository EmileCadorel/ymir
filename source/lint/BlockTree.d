module lint.BlockTree;
import lint.tree, std.outbuffer;

class BlockTree : Tree {

    override void toC (ref OutBuffer buf) {
	buf.writefln ("{\n}");
    }
    
}
