job "microservices_app" {
  datacenters = ["local"]
  type = "service"

  constraint {
     attribute = "${attr.kernel.name}"
     value     = "linux"
  }

  update {
      stagger = "10s"
      max_parallel = 1
  }

  group "app" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    task "nodeapp" {
      driver = "docker"
      config {
        image = "node:latest"
        port_map {
          http = 8080
        }
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "8080" {}
        }
      }

      service {
        name = "nodeapp"
        tags = ["global"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
