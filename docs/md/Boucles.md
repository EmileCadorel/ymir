# Boucles
  <hr>
 Ymir propose deux types de boucles :
 * Les boucles `while`
 * Les boucles `for`
 

## While
----------------
 `while` boucle jusqu'à ce que la condition soit fausse.

```Rust
let i = 0;
while i < 101 {
  if i % 2 == 0
     println ('Pair');
  else 
     println ('Impair');
  i ++;
}

```

## For
----------------
 La boucle `for` itère sur un type itérable.
 Les types itérables sont :
  - `string`
  - `array!T`
  - `range`

```Rust
for it in [1, 2, 3, 4, 5]
  print (it);

//'12345'
```

 Les `range`s sont des types créés pour pouvoir itérer sur un intervalle.
 
```Rust
for it in 0 .. 6
   print (it); // '12345'

for it in 6 .. 0
  print (it); // '654321'
```


## Label de boucle
------------------

Il est possible de labélliser une boucle. C'est utile pour le mot clé `break`, qui va pouvoir y faire appel.

```Rust
while:loop1 (true) {
	for:loop2 (it in [1, 2, 3) {
		if (it == 2) 
			break loop1; // on arrête la boucle while
	}
}

```

