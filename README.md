Installation
========

```
git clone https://github.com/EmileCadorel/ymir.git
cd ymir/
make install
```

Utilisation
========

```
ymir [-g] 
     [-Idir...]
     [-o outfile] infiles...
```

Ymir syntaxe
=======

```ocaml
import std.stdio;

def test () {
	while:loop1 (true) {
		let i = 0;
		while i < 89 {
			if (i == 4) break loop1;
			i ++;
		}
	}
}

def printTab (arr : [int]) {
	print ('[');
	for it in arr {
		print (it);
	}
	print (']');
}

def main () {
    let a = 10, b = 'd', c = &a, e = "salut";
    let f = [1, 2, 3];
    let g = f + [4];
    if (g.length >= 4) printTab (g);
}

```

Documentation
================

    [Doc](https://emilecadorel.github.io/ymir/docs/test.html)
    
