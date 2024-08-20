

check-nomad:
	@bash script/nomad.sh check
start-nomad: check-nomad
	@sh script/nomad.sh start
log-nomad:
	@bash script/nomad.sh log
stop-nomad:
	@bash script/nomad.sh stop

build-docker:
	docker build -t xl_mock_prover:v1 -f Dockerfile.xlayer_prover .

xl-prover:
	@bash script/nomad.sh job app/xlayer_prover.nomad.hcl

.PHONY: build-docker start-nomad check-nomad log-nomad stop-nomad xl-prover
