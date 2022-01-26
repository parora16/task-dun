network_name = "dunnhumby-vpc"

project_id   = "terra-testjamess"

subnets      =  [
        {
            subnet_name           = "dunnhumby-subnet"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "us-west1"
        }
]