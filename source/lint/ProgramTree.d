module lint.ProgramTree;
import lint.tree, std.container;

class ProgramTree : Tree {

    private Array!Tree _elems;

    void addElem (Tree elem) {
	this._elems.insertBack (elem);
    }
        
}
