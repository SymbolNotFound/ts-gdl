// Copyright (c) 2025 Symbol Not Found
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// github:SymbolNotFound/ts-gdl/games/fetch.go

package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"
)

type (
	GameRepo struct {
		Name  string
		Games []string
	}

	Metadata map[string]interface{}
)

// Fetches the list of all games for ggp.org's repo.
func fetch_games(repo_name string) (GameRepo, error) {
	var repo GameRepo
	client := &http.Client{}
	url := "http://games.ggp.org/" + repo_name + "/games/"
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return repo, err
	}
	resp, err := client.Do(req)
	if err != nil {
		return repo, err
	}
	return repo, json.NewDecoder(resp.Body).Decode(&repo.Games)
}

// Fetch just the metadata json for the indicated game.
func getMetadata(repo_name, game_name string) (Metadata, error) {
	var game_meta Metadata
	client := &http.Client{}
	url := "http://games.ggp.org/" + repo_name + "/games/" + game_name + "/"
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return game_meta, err
	}
	resp, err := client.Do(req)
	if err != nil {
		return game_meta, err
	}
	defer resp.Body.Close()
	return game_meta, json.NewDecoder(resp.Body).Decode(&game_meta)
}

// Validates the metadata keys as being expected and/or required.
func checkKeys(metadata Metadata) {
	if name, ok := metadata["gameName"]; ok {
		fmt.Println("[" + name.(string) + "]")
	}

	EXPECTED_NAMES := map[string]bool{
		"curator":        true,
		"stylesheet":     true,
		"rulesheet":      true,
		"gameName":       true,
		"numRoles":       true,
		"user_interface": true,
		"description":    true,
		"version":        true,
		"roleNames":      true,
	}
	for k := range metadata {
		if _, ok := EXPECTED_NAMES[k]; !ok {
			fmt.Println("WARNING: unexpected key " + k)
		}
	}

	REQUIRED_NAMES := map[string]bool{
		"rulesheet": true,
		"numRoles":  true,
		"roleNames": true,
	}
	for k := range REQUIRED_NAMES {
		if metadata[k] != nil {
			fmt.Println("WARNING: expected to find key " + k)
		}
	}
}

// Fetch the game's KIF file and any other files referenced in its metadata.
func getGame(repo_name, game_name string) error {
	metadata, err := getMetadata(repo_name, game_name)
	if err != nil {
		return err
	}
	checkKeys(metadata)
	metadata["source"] = "games.ggp.org"
	metadata["repo"] = repo_name
	metadata["id"] = game_name

	// Make sure game's directory exists
	path := "./games/" + game_name + "_" + repo_name + "/"
	_ = os.Mkdir(path, 0755)

	writeMetadata(metadata, path+"METADATA.json")

	// Also fetch files referenced by metadata.
	FILE_ATTRS := []string{
		"rulesheet",
		"stylesheet",
		"user_interface",
		"description",
	}
	for _, attr := range FILE_ATTRS {
		if fname, ok := metadata[attr]; ok {
			fname_str := fname.(string)
			if err := fetchFile(repo_name, game_name, fname_str, path); err != nil {
				// Just print the error and continue, fetch what is available.
				fmt.Println(err)
			}
			time.Sleep(1 * time.Second)
		}
	}

	return nil
}

// Fetch the named (repo, game, file) resource to the local path.
func fetchFile(repo_name, game_name, filename, path string) error {
	fmt.Println("(fetch) " + game_name + " -> " + path + filename)
	client := &http.Client{}
	url := "http://games.ggp.org/" + repo_name + "/games/" + game_name + "/" + filename
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return err
	}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	out, err := os.Create(path + "/" + filename)
	if err != nil {
		return err
	}
	defer out.Close()

	written, err := io.Copy(out, resp.Body)
	fmt.Printf("%d bytes written\n", written)

	return err
}

func writeMetadata(metadata Metadata, file_path string) error {
	if filedata, err := json.MarshalIndent(metadata, "", "  "); err != nil {
		return err
	} else {
		return os.WriteFile(file_path, filedata, 0644)
	}
}

// Get all game files from the named repository.
func getRepo(repo_name string) {
	repo, err := fetch_games(repo_name)
	if err != nil {
		log.Fatal(err)
	}
	for i, game_name := range repo.Games {
		fmt.Printf("%3d: %s\n", i, game_name)
		if err := getGame(repo_name, game_name); err != nil {
			fmt.Println(err)
		}
		time.Sleep(1 * time.Second)
	}
}

func main() {
	getRepo("base")
	getRepo("dresden")
	getRepo("stanford")
}
