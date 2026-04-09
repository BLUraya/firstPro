terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}


resource "kubernetes_deployment" "weather_app" {
  metadata {
    name = "weather-app"
    labels = { app = "weather-app" }
  }

  spec {
    replicas = 2
    selector {
      match_labels = { app = "weather-app" }
    }
    template {
      metadata {
        labels = { app = "weather-app" }
      }
      spec {
        container {
          image = "bluraya55/my-app" 
          name  = "weather-container"
          port { container_port = 5000 }
        }
      }
    }
  }
}


resource "kubernetes_service" "weather_service" {
  metadata {
    name = "weather-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.weather_app.metadata[0].labels.app
    }
    port {
      port        = 5000          
      target_port = 5000          
      node_port   = 30080       
    }
    type = "NodePort"
  }
}