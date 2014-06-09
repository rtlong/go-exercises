package main

import "fmt"
import "os"
import "io"
import "encoding/json"
import "log"
import "strconv"

var rates map[string]map[string]float64

func loadRates(filepath string) {
	file, err := os.Open(filepath)
	if err != nil {
		log.Fatal(err)
	}
	dec := json.NewDecoder(file)
	err = dec.Decode(&rates)
	if err != nil && err != io.EOF {
		log.Fatal(err)
	}
}

func rate(from_curr string, to_curr string) (float64, error) {
	rates_from, found := rates[from_curr]
	if found {
		rate, found := rates_from[to_curr]
		if found {
			return rate, nil
		}
	}
	// otherwise, try the opposite order
	rates_to, found := rates[to_curr]
	if found {
		rate, found := rates_to[from_curr]
		if found {
			rate = 1 / rate
			return rate, nil
		}
	}
	return 0, fmt.Errorf("No rate found for conversion from %s to %s", from_curr, to_curr)
}

func main() {
	var value float64
	if len(os.Args) != 4 {
		log.Fatal("Please supply a value, its currency, and a target currency")
	}

	value, err := strconv.ParseFloat(os.Args[1], 32)
	if err != nil {
		log.Fatal(err)
	}
	from_curr, to_curr := os.Args[2], os.Args[3]

	loadRates("rates.json")

	rate, err := rate(from_curr, to_curr)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%0.2f %s\n", value*rate, to_curr)
}
