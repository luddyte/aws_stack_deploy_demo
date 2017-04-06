job "dataservice" {
  datacenters = ["local"]
  type = "service"

  constraint {
     attribute = "${meta.role}"
     operator  = "="
     value     = "db"
  }

  update {
      stagger = "10s"
      max_parallel = 1
  }

  group "db" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    task "mongo" {
      driver = "raw_exec"
      config {
        command = "/usr/bin/mongod"
        args =["--config", "/etc/mongodb.conf", "--bind_ip", "0.0.0.0"]
      }

      resources {
        network {
          mbits = 10
          port "db" {
            # maybe other applications consume this service, pin the port
            static = "27017"
          }
        }
      }

      service {
        name = "mongodb"
        tags = ["global"]
        port = "db"
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
