#############################################################################
#                 multiple Provider  Block                                                    
#############################################################################
# provider "google" {
#   # credentials = file("tcb-project-371706-4c5de465c0d5.json")
#   project = "tcb-project-371706" #Project A
#   region  = "asia-southeast1"
# }

# provider "google" {

#   project     = "serviceprojecta-375207" # Project B
#   region      = "us-east1"
#   alias       = "gcp-service-project"
#   credentials = file("serviceprojecta-375207-e50d223c37c5.json")
# }
# 
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.60.0"
    }
  }
}
