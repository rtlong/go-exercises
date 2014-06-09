package main

import "bufio"
import "os"
import "strings"
import "fmt"

var lineCount, wordCount int

func pluralize(count int, word string) string {
	var s string
	if count != 1 {
		s = "s"
	}
	return fmt.Sprintf("%d %s%s", count, word, s)
}

func main() {
	in := bufio.NewReader(os.Stdin)
	line, _ := in.ReadString('\n')
	var err error
	for ; err == nil; line, err = in.ReadString('\n') {
		lineCount++
		wordCount += len(strings.Fields(line))
	}

	fmt.Printf("%s in %s", pluralize(wordCount, "word"), pluralize(lineCount, "line"))
}
