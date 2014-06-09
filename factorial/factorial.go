package main

import "fmt"
import "os"
import "strconv"
import "math/big"
import "log"

func factorial(i int64) (*big.Int, error) {
	if i < 0 {
		return new(big.Int), fmt.Errorf("Input must be positive")
	} else if i == 0 || i == 1 {
		return big.NewInt(1), nil
	} else {
		out, _ := factorial(i - 1)
		return out.Mul(out, big.NewInt(i)), nil
	}
}

func main() {
	args := os.Args
	if len(args) != 2 {
		log.Fatal("Argument error. Give one integer")
	}
	var input int64
	input, err := strconv.ParseInt(args[1], 10, 64)
	if err != nil {
		log.Fatal("Argument error. Give one integer")
	}
	fact, err := factorial(input)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(fact)
}
