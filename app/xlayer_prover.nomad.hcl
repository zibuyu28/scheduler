job "prover-job" {
  type = "service"

  group "prover-group" {
    count = 1

    # 前置任务
    task "precheck-task" {
      driver = "raw_exec"

      config {
        command = "/bin/bash"
        args    = ["/Users/oker/GolandProjects/scheduler/script/pre_xlayer_prover.sh"]  # 前置任务脚本的路径
      }

      resources {
        cpu    = 100
        memory = 128
      }
      lifecycle {
        hook = "prestart"
        sidecar = false
      }
    }

    # 主服务任务
    task "prover-task" {
      driver = "docker"

      config {
        image = "docker.io/library/xl_mock_prover:v1"
        command = "/bin/sh"
        args    = ["-c", "tail -f /dev/null"]
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
