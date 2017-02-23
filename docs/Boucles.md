# Boucles

 Ymir propose deux types de boucles :
 * Les boucles _While_
 * Les boucles _For_

# While

 _While_ boucle jusqu'à ce que la condition soit fausse.

```D
let i = 0;
while i < 101 {
  if i % 2 == 0
     println ('Pair');
  else 
     println ('Impair');
}

```
# For

 La boucle _For_ itère sur un type itérable.
 Les types itérables sont :
  - string
  - array!T
  - range

```D
for it in [1, 2, 3, 4, 5]
  print (it);

//'12345'
```

 Les _Ranges_ sont des types créés pour pouvoir itérer sur un intervalle.
 
```D
for it in 0 .. 6
   print (it); // '12345'

for it in 6 .. 0
  print (it); // '654321'
```



