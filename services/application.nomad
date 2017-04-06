job "microservices_app" {
  datacenters = ["local"]
  type = "service"

  constraint {
     operator = "distinct_hosts"
     value     = "true"
  }

  update {
      stagger = "10s"
      max_parallel = 1
  }

  group "app" {
    count = 3

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    task "nodeapp" {
      driver = "docker"
      config {
        image = "ehron/node_consul_demo"
        port_map {
          http = 3000
        }
        network_mode = "host"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "nodeapp"
        tags = ["global"]
        port = "http"
        check {
          name     = "node_consul_app"
          path     = "/health"
          type     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
