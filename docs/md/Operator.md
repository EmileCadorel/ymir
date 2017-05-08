
# Surcharge d'operateur
<hr>

Les operateurs sont surchargeable grâce au fonction templates, par réécriture.
<br>

```D
let a = ..., b = ...;

a + b; // si aucun operateur '+' entre a et b, alors on réécris en a.opBinary('+') (b);
```
<br>
## Operateur unaire
<hr>

On peut surcharger les operateurs suivants : 
	`++, --, -, *, !`


```D

struct 
| a : int
-> Test;

def opUnary (op : string) (a : Test) { // Ou def opUnary('-') ...
	static if (op == '-')
		return -a.a;
	else static assert (false, op);
}

// ...
let = - Test (10);

```
<br>
## Operateur binaire
<hr>

On peut surcharger les operateurs suivant : 
`+,	-,	*,	/,	%,	^^,	&, |,	^,	<<,	>>,  in`

La surcharge se fait en deux temps:
- Un première réecriture en `a.opBinary (op) (b)`
- Si elle n'existe pas une réecriture en `b.opBinaryRight (op) (a)`



```D

def opBinary (op : string) (a, b) {
	return mixin ('a ' + op + ' b.data);
}

```

## Operateur de comparaison
<hr>


On peut surcharge les operateurs suivants: `<, <=, >, >=`

Il existe deux cas de figure, soit la surcharge retourne un `bool`, ou un `int`.
Dans le cas ou elle retourne un int : 
- `<` : a.opTest(b) < 0
- `<=` : a.opTest(b) <= 0
- `>` : a.opTest(b) > 0
- `>=` : a.opTest(b) >= 0
<br>


```D
def opTest (op : string) (a, b) {
	return mixin ('a ' + op + ' b.data');
}

```

<br>
La surcharge des operateurs `==` et `!=`, se fait avec la fonction `opEquals`.


```D

if (a == b) ... // réecris en a.opEquals (b);
else if (a != b) // réecris en !a.opEquals (b);

```

<br>
Comme pour la surcharge binaire une deuxième réecriture est faite si la première ne fonctionne pas

<br>
## Surcharge d'appel
<hr>


Il est possible de surcharger l'operateur d'appel `f()`, pour ça il suffit de déclarer un fonction nommé `opCall`.



```D

struct 
| a : int
-> Test;


def opCall (ref a : Test, b, c, d) : ref int {
	a.a += b + c + d;
	return a.a;
}

// ...
let f = Test (0);
f (1, 1, 1) += 1;

println (f.a); // 4

```

<br>
## Surcharge d'index
<hr>

Il est également possible de surcharger l'operateur d'index `a[]`, avec la création de la fonction `opIndex`.


```D

def opIndex (ref a : string) : [char] {
	return cast:[char](a);
}

def opIndex (ref a : string, i1 : int) : [char] {
	return [a [i1]];
}

def opIndex (ref a : string, i1 : int, i2) : [char] {
	return [a [i1]] +  a [expand (i2)];
}

let a = 'salut';
let b = a[];
let c = a [0, 2, 4]; // appel avec le système variadic

```














