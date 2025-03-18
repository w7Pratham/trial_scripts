package main

import (
	"bufio"
	"encoding/csv"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

const serverListFile = "servers.csv"

type Server struct {
	Env      string
	SubEnv   string
	App      string
	LM       string
	Hostname string
}

func main() {
	for {
		showMenu()
	}
}

func showMenu() {
	fmt.Println("1. Add a server")
	fmt.Println("2. Select a server to SSH")
	fmt.Println("3. Exit")
	fmt.Print("Enter your choice: ")

	var choice int
	fmt.Scan(&choice)

	switch choice {
	case 1:
		addServer()
	case 2:
		selectServer()
	case 3:
		os.Exit(0)
	default:
		fmt.Println("Invalid choice.")
	}
}

func addServer() {
	reader := bufio.NewReader(os.Stdin)

	fmt.Print("Enter the environment (e.g., IN, UAT): ")
	env, _ := reader.ReadString('\n')
	env = strings.TrimSpace(env)

	fmt.Print("Enter the sub-environment (e.g., UAT1, UAT2): ")
	subEnv, _ := reader.ReadString('\n')
	subEnv = strings.TrimSpace(subEnv)

	fmt.Print("Enter the application (e.g., WEB): ")
	app, _ := reader.ReadString('\n')
	app = strings.TrimSpace(app)

	fmt.Print("Enter the LM (e.g., 1): ")
	lm, _ := reader.ReadString('\n')
	lm = strings.TrimSpace(lm)

	fmt.Print("Enter the hostname (e.g., 192.168.1.10): ")
	hostname, _ := reader.ReadString('\n')
	hostname = strings.TrimSpace(hostname)

	server := Server{Env: env, SubEnv: subEnv, App: app, LM: lm, Hostname: hostname}
	saveServer(server)

	fmt.Println("Server added successfully.")
}

func saveServer(server Server) {
	file, err := os.OpenFile(serverListFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	err = writer.Write([]string{server.Env, server.SubEnv, server.App, server.LM, server.Hostname})
	if err != nil {
		fmt.Println("Error writing to file:", err)
	}
}

func selectServer() {
	servers := loadServers()
	if len(servers) == 0 {
		fmt.Println("No servers available.")
		return
	}

	selectedEnv := selectOption("Environment", getUniqueValues(servers, func(s Server) string { return s.Env }))
	selectedSubEnv := selectOption("Sub-Environment", getFilteredValues(servers, selectedEnv, func(s Server) string { return s.SubEnv }))
	selectedApp := selectOption("Application", getFilteredValues(servers, selectedEnv+"-"+selectedSubEnv, func(s Server) string { return s.App }))
	selectedLM := selectOption("LM", getFilteredValues(servers, selectedEnv+"-"+selectedSubEnv+"-"+selectedApp, func(s Server) string { return s.LM }))
	selectedHostname := selectOption("Hostname", getFilteredValues(servers, selectedEnv+"-"+selectedSubEnv+"-"+selectedApp+"-"+selectedLM, func(s Server) string { return s.Hostname }))

	fmt.Printf("Connecting to %s with user u0_a315\n", selectedHostname)
	// Replace the following line with the actual SSH command, for example:
	cmd := exec.Command("ssh", "u0_a315@"+selectedHostname, "-p", "8022")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Printf("Error executing SSH command: %v\n", err)
	}
}

func loadServers() []Server {
	file, err := os.Open(serverListFile)
	if err != nil {
		fmt.Println("Error opening file:", err)
		return nil
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		fmt.Println("Error reading file:", err)
		return nil
	}

	var servers []Server
	for _, record := range records {
		servers = append(servers, Server{
			Env:      record[0],
			SubEnv:   record[1],
			App:      record[2],
			LM:       record[3],
			Hostname: record[4],
		})
	}
	return servers
}

func selectOption(prompt string, options []string) string {
	if len(options) == 0 {
		fmt.Printf("No %s available.\n", prompt)
		return ""
	}

	fmt.Printf("Step: Select %s\n", prompt)
	for i, option := range options {
		fmt.Printf("%d. %s\n", i+1, option)
	}
	fmt.Printf("Enter the number of the %s: ", prompt)

	var choice int
	fmt.Scan(&choice)
	if choice < 1 || choice > len(options) {
		fmt.Println("Invalid choice.")
		return ""
	}
	return options[choice-1]
}

func getUniqueValues(servers []Server, getValue func(Server) string) []string {
	valuesMap := make(map[string]struct{})
	for _, server := range servers {
		value := getValue(server)
		valuesMap[value] = struct{}{}
	}

	var values []string
	for value := range valuesMap {
		values = append(values, value)
	}
	return values
}

func getFilteredValues(servers []Server, filter string, getValue func(Server) string) []string {
	valuesMap := make(map[string]struct{})
	for _, server := range servers {
		if strings.HasPrefix(server.Env+"-"+server.SubEnv+"-"+server.App+"-"+server.LM, filter) {
			value := getValue(server)
			valuesMap[value] = struct{}{}
		}
	}

	var values []string
	for value := range valuesMap {
		values = append(values, value)
	}
	return values
}
