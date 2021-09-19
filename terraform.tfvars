prefix = "fullcycle"
vpc_cidr_block = "10.0.0.0/16"
instances = ["manager", "manage2","worker1"]
instance_type = "t2.micro"
key_name = "swarm"
instance_manager_nodes = ["manager2", "manage3"]
instances_workers = ["worker2", "worker3"]