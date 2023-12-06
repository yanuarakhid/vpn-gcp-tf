#############################################################################
#                 multiple Provider  Block                                                    
#############################################################################
# provider "google" {
#   # credentials = file("tcb-project-371706-4c5de465c0d5.json")
#   project = "tcb-project-371706" #Project A
#   region  = "asia-southeast1"
# }

#############################################################################
#                  Provider  Block                                                    
#############################################################################
provider "google" {
  # credentials = file("datalabs-hs-4c5de465c0d5.json")
  project = "datalabs-hs" #Project A
  # region  = "asia-southeast1"
}
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.60.0"
    }
  }
}
