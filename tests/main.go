package main

import (
	"fmt"
	"os"

	lua "github.com/yuin/gopher-lua"
)

// Runs a Lua 5.1 script (the WoW addon test harness); exit 1 on error.
func main() {
	L := lua.NewState()
	defer L.Close()
	if err := L.DoFile(os.Args[1]); err != nil {
		fmt.Println("FAIL:", err)
		os.Exit(1)
	}
}
