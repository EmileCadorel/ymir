
def bullSort (T) (a : [T]) {
    for (it in 0u .. (a.length - 1ul)) {
	for (it_ in it .. (a.length - 1ul)) {
	    if (a [it_] > a [it_ + 1ul]) {
		let aux = a [it_];
		a [it_] = a [it_ + 1ul];
		a [it_ + 1ul] = aux;
	    }
	}
    }
}
