##Installation

```
git clone https://github.com/EmileCadorel/ymir.git
cd ymir/
make final
```

##Utilisation

```
ymir file.yr
```

### Ymir syntaxe

```D
def test () : string {
  return 'test';
}

def add (a : float, b : float) {
  return a + b;
}

def add (a : int, b : int) {
  return a + b;
}

def main () {
  println (test, add (1., .09), add (3, 7));
}
```
