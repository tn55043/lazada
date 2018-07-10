package main

import (
	"encoding/json"
	"net/http"
)

type helloWorldResponse struct {
	Header headerResponse `json:"header"`
	Body   bodyResponse   `json:"body"`
}

type headerResponse struct {
	Code        int    `json:"code"`
	Description string `json:"description"`
}

type bodyResponse struct {
	Message string `json:"message"`
}

type helloWorld2Response struct {
	Message string `json:"message"`
}

type helloWorld2Resquest struct {
	Name string `json:"name"`
}

func main() {
	http.HandleFunc("/hello", helloHandle)
	http.HandleFunc("/hello2", hello2Handle)
	http.ListenAndServe(":8080", nil)
}

func hello2Handle(w http.ResponseWriter, r *http.Request) {
	//Request
	var request helloWorld2Resquest
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&request)
	if err != nil {
		http.Error(w, "Bad request", http.StatusBadRequest)
		return
	}

	//Response
	response := helloWorld2Response{Message: "Hello " + request.Name}
	encoder := json.NewEncoder(w)
	encoder.Encode(&response)
}

func helloHandle(w http.ResponseWriter, r *http.Request) {
	response := helloWorldResponse{
		headerResponse{
			Code:        200,
			Description: "Success",
		},
		bodyResponse{Message: "Hello World"},
	}

	encoder := json.NewEncoder(w)
	encoder.Encode(&response)
}
