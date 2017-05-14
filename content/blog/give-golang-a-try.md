---
author: "Pierre Zemb"
date: 2015-12-27
title: Why you really should give Golang a try!
best: false
tags: ["go","development"]
---

![image](/img/golang-a-try/golang_1.png)


As you may or may not know, [Golang](https://golang.org/) is a new programming language created by Google. It’s great for writing high-performance, concurrent server applications and tools. With it, you can easily write your own web server to render your static HTML files, or go deeper and create a REST services.

```go
package main
import "fmt"

func main() {
    fmt.Println("hello world")
}
```

Go’s Hello World

Go has many advantages over languages like good-old Java, C++ or *add your favorite language here*. Here’s some of it:

### It’s easy to read and learn

Go has what I call a “clean syntax”. Inspired by Python, There’s plenty of small things that makes Go code great.

*   [The Go Programming Language Specification](https://golang.org/ref/spec) is pretty short, and you can actually read it by yourself.
*   Concise variable declaration is awesome.

```go
int x = 0 // Java style
x := 0   // Go style
```

*   [Gofmt](http://golang.org/cmd/gofmt/) is a tool that automatically formats Go source code, so your code’ll look like others. Pretty convenient to read go code.
*   Go’s standard library is easy to use. Have a look on this code:

```go
package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc(
        "/",
        func(w http.ResponseWriter, r *http.Request) {
            fmt.Fprintln(w, "Hello, gophers!")
        },
    )
    http.ListenAndServe(":8080", nil)
}
```

It’s an web server writing ”Hello, gophers!” on your favorite web browser, powered by net/http, the official package. Pretty simple, doesn’t it?

### Fast compilation times

![image](/img/golang-a-try/golang_2.png)


Waiting times, no more. Go’s compiler is so fast that the command “go build” compile packages and dependencies and run it, giving the user the impression of running an interpreted language.

### **Easy to get packages**

For example, if we need a dependency, we just need to put it on top like this:

```go
package main
import (
    “encoding/json”
    “net/http”
    “github.com/gorilla/mux”
)
```

Just run “go get” and it’s over. Really. No more Maven, Gradle, Ant build fails. No makefile, build.xml and horrible stuff like that.

### Great standard librairies

![image](/img/golang-a-try/golang_3.png)


From HTTP server, to JSON decoding, you almost have anything you need in the standard library. [Have a look](https://golang.org/pkg/)!

### Great concurrency model

It’s easy to write concurrency app using light-weight processes called goroutines, and channels. Just add go before the call of a function to “thread it”. Here’s an example:

```go 
package main
import (
 “fmt”
 “time”
)
func say(s string) {
 for i := 0; i < 5; i++ {
 time.Sleep(100 * time.Millisecond)
 fmt.Println(s)
 }
}
func main() {
 go say(“world”)
 say(“hello”)
}

```

Gives the output:

```
hello
world
hello
world
hello
world
hello
world
hello
```

# Wow, such a language! What now?

You should head to [A tour of Go](https://tour.golang.org/welcome/1), a great website where you can learn Go without installing everything. Or go to the [official website](https://golang.org)!

Thanks for reading my story, and see you soon!

Pierre Zemb, french engineer student