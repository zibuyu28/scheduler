#!/bin/bash

set -e

echo "check docker and docker-compose..."
if docker ps > /dev/null 2>&1; then
    echo "Docker daemon is running."
else
    echo "Docker daemon is not running."
    exit 1
fi
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed." >&2
    exit 1
fi

echo "check directory..."
#if [ ! -d "/data/xgon" ]; then
#    echo "create directory /data/x1 with admin:staff"
#    exit 1
#fi

echo "check directory belong to admin:staff..."
#if [ "$(stat -c '%U:%G' /data/xgon)" != "admin:staff" ]; then
#    echo "please change directory /data/x1 owner to admin:staff"
#    exit 1
#fi

echo "start to init prover service..."
#cd /data/xgon || exit 1

echo "check v3.0.0-RC3-fork.6.tgz file exist..."
#if [ ! -f "v3.0.0-RC3-fork.6.tgz" ]; then
#    echo "file v3.0.0-RC3-fork.6.tgz not exist"
#    exit 1
#fi


echo "start to unzip prover max config file..."
#tar -zxvf v3.0.0-RC3-fork.6.tgz

echo "start to write config.json file..."
cat > /Users/oker/GolandProjects/scheduler/mock_vol/xl_prover/config.json << EOF
{
    "proverName": "$HOSTNAME",
    "runExecutorServer": false,
    "runExecutorClient": false,
    "runExecutorClientMultithread": false,
    "runHashDBTest": false,
    "runAggregatorServer": false,
    "runAggregatorClient": true,
    "runFileGenBatchProof": false,
    "runFileGenAggregatedProof": false,
    "runFileGenFinalProof": false,
    "runFileProcessBatch": false,
    "runFileProcessBatchMultithread": false,
    "runFileExecutor": false,
    "runKeccakScriptGenerator": false,
    "runKeccakTest": false,
    "runStorageSMTest": false,
    "runBinarySMTest": false,
    "runMemAlignSMTest": false,
    "runSHA256Test": false,
    "runBlakeTest": false,
    "executeInParallel": true,
    "useMainExecGenerated": true,
    "useProcessBatchCache": false,
    "saveRequestToFile": false,
    "saveFilesInSubfolders": false,
    "saveInputToFile": false,
    "saveDbReadsToFile": false,
    "saveDbReadsToFileOnChange": false,
    "saveOutputToFile": false,
    "saveProofToFile": false,
    "saveResponseToFile": false,
    "loadDBToMemCache": false,
    "loadDBToMemCacheInParallel": false,
    "dbMTCacheSize": 1024,
    "dbProgramCacheSize": 1024,
    "dbMultiWrite": true,
    "opcodeTracer": false,
    "logRemoteDbReads": false,
    "logExecutorServerResponses": false,
    "executorServerPort": 50071,
    "executorROMLineTraces": false,
    "executorClientPort": 50071,
    "executorClientHost": "127.0.0.1",
    "hashDBServerPort": 50061,
    "aggregatorServerPort": 26669,
    "aggregatorClientPort": 8000,
    "aggregatorClientHost": "agg.x1.tech",
    "aggregatorClientMockTimeout": 10000000,
    "mapConstPolsFile": false,
    "mapConstantsTreeFile": false,
    "inputFile": "testvectors/aggregatedProof/recursive1.zkin.proof_0.json",
    "inputFile2": "testvectors/aggregatedProof/recursive1.zkin.proof_1.json",
    "outputPath": "output",
    "configPath": "config",
    "zkevmCmPols_disabled": "runtime/zkevm.commit",
    "c12aCmPols": "runtime/c12a.commit",
    "recursive1CmPols_disabled": "runtime/recursive1.commit",
    "recursive2CmPols_disabled": "runtime/recursive2.commit",
    "recursivefCmPols_disabled": "runtime/recursivef.commit",
    "finalCmPols_disabled": "runtime/final.commit",
    "publicsOutput": "public.json",
    "proofFile": "proof.json",
    "databaseURL": "postgresql://testuser:testpassN@proverhost:5432/prover_db",
    "dbNodesTableName": "state.nodes",
    "dbProgramTableName": "state.program",
    "dbConnectionsPool": true,
    "cleanerPollingPeriod": 600,
    "requestsPersistence": 3600,
    "maxExecutorThreads": 8,
    "maxProverThreads": 50,
    "maxHashDBThreads": 8,
    "dbNumberOfPoolConnections": 100,
    "dbClearCache": false,
    "dbGetTree": true,
    "dbReadOnly": false,
    "logExecutorServerInputGasThreshold": 1048576,
    "dbMetrics": true,
    "executorTimeStatistics": true,
    "dbMultiWriteSinglePosition": false,
    "ECRecoverPrecalc": false,
    "ECRecoverPrecalcNThreads": 4,
    "stateManager": true,
    "useAssociativeCache" : false
}
EOF


echo "docker login with ecr..."
