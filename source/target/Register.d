module target.Register;


class Register {
    
    private ulong _id;
    private int _size;

    this (ulong id, int size) {
	this._id = id;
	this._size = size;
    }
    
}
