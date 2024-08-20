package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/Knetic/govaluate"
	"github.com/spf13/cast"
)

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/register", Register)

	server := http.Server{
		Addr:    "0.0.0.0:9800",
		Handler: mux,
	}
	fmt.Printf("server listen on %s\n", server.Addr)
	go checkAll()
	server.ListenAndServe()
}

func checkAll() {
	for {
		<-time.After(time.Second * 10)
		for _, request := range checks {
			fmt.Printf("check job: %s\n", request.Job)
			err := check(request)
			if err != nil {
				fmt.Printf("check failed, err: %v\n", err)
			}
		}
	}
}

func check(r RegisterRequest) error {
	file, err := os.ReadFile(fmt.Sprintf("%s-dynamic.param", r.Job))
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return fmt.Errorf("read dynamic.param file failed, err: %v", err)
	}
	var rr = make(map[string]int32)
	err = json.Unmarshal(file, &rr)
	if err != nil {
		return fmt.Errorf("unmarshal failed, err: %v", err)
	}
	var pvalue = make(map[string]int32)
	for _, param := range r.Params {
		if _, ok := rr[param]; ok {
			pvalue[param] = rr[param]
		} else {
			pvalue[param] = 0
		}
	}
	rule := r.Rule
	for p, v := range pvalue {
		rule = strings.ReplaceAll(rule, fmt.Sprintf("${%s}", p), fmt.Sprintf("%d", v))
	}
	fmt.Printf("rule: %s\n", rule)
	expr, err := govaluate.NewEvaluableExpression(rule)
	if err != nil {
		return fmt.Errorf("new evaluable expression failed, err: %v", err)
	}

	// 计算表达式的值
	result, err := expr.Evaluate(nil)
	if err != nil {
		return fmt.Errorf("evaluate failed, err: %v", err)
	}
	ri := cast.ToInt(result)
	count, err := getCount(r.Job)
	if err != nil {
		return fmt.Errorf("get job count failed, err: %v", err)
	}
	var cmd *exec.Cmd
	var countn = count
	if ri > 0 {
		countn = countn + 1
	} else if ri < 0 && count > 1 {
		countn = countn - 1
	}
	if countn != count {
		cmd = exec.Command("/bin/bash", "-c", fmt.Sprintf("nomad job scale %s %d", r.Job, countn))
		_, err = cmd.CombinedOutput()
		if err != nil {
			return fmt.Errorf("scale job failed, err: %v", err)
		}
		fmt.Printf("scale job success, job: %s, count: %d\n", r.Job, countn)
	}
	return nil
}

func getCount(job string) (int, error) {
	cmd := exec.Command("/bin/bash", "-c", fmt.Sprintf("nomad job status -json %s | jq '.[0].Summary.Summary'|jq '[.[] | select(.Running != null) | .Running] | .[0]'", job))
	output, err := cmd.CombinedOutput()
	if err != nil {
		return 0, fmt.Errorf("get job status failed, err: %v", err)
	}
	fmt.Printf("job: %s, count: %s\n", job, output)
	return cast.ToIntE(strings.TrimSpace(string(output)))
}

func Register(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		w.Write([]byte("method not allowed"))
		return
	}
	err := register(r)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("register success"))
}

type RegisterRequest struct {
	Job    string   `json:"job"`
	Params []string `json:"params"`
	Rule   string   `json:"rule"`
}

func register(r *http.Request) error {
	all, err := io.ReadAll(r.Body)
	if err != nil {
		return fmt.Errorf("read body failed, err: %v", err)
	}
	var rr RegisterRequest
	err = json.Unmarshal(all, &rr)
	if err != nil {
		return fmt.Errorf("unmarshal failed, err: %v", err)
	}

	cmd := exec.Command("/bin/bash", "-c", fmt.Sprintf("nomad job status %s", rr.Job))
	_, err = cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("please check job exist or not, err: %v", err)
	}
	checks[rr.Job] = rr
	fmt.Printf("register success, job: %s, params: %v, rule: %s\n", rr.Job, rr.Params, rr.Rule)
	return nil
}

var checks = make(map[string]RegisterRequest)
