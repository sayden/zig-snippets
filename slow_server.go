package main

import (
	"fmt"
	"net"
	"time"
)

const (
	CONN_HOST = "0.0.0.0"
	CONN_PORT = "8080"
	CONN_TYPE = "tcp"
)

func main() {
	l, err := net.Listen(CONN_TYPE, CONN_HOST+":"+CONN_PORT)
	if err != nil {
		panic(err)
	}
	defer l.Close()

	fmt.Println("Listening on " + CONN_HOST + ":" + CONN_PORT)

	for {
		conn, err := l.Accept()
		if err != nil {
			panic(err)
		}

		go handleRequest(conn)
	}
}

func handleRequest(conn net.Conn) {
	buf := make([]byte, 1024)
	_, err := conn.Read(buf)
	if err != nil {
		fmt.Println("Error reading:", err.Error())
	}
	defer conn.Close()

	fmt.Printf("Message received: %s\n", string(buf))

	// Respond slowwwwly
	time.Sleep(2 * time.Second)
	conn.Write([]byte("Hello from Go!"))
}
