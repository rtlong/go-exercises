package main

import "io/ioutil"
import "bytes"
import "os"
import "log"
import "fmt"

func main() {
	input, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		log.Fatal(err)
	}
	lines := bytes.Split(input, []byte("\n"))
	for i := len(lines) - 1; i >= 0; i-- {
		line := lines[i]
		if len(line) > 0 {
			fmt.Println(string(line))
		}
	}
}
