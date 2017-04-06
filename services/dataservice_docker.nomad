job "dataservice" {
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

  group "db" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    ephemeral_disk {
      migrate = true
      size    = "500"
      sticky  = true
    }

    task "mongo" {
      driver = "docker"
      config {
        image = "mongo:3.0.14"
        port_map {
          db = 27017
        }
        network_mode = "host"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "db" {}
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
