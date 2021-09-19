# output "public_ips" {
#     value = [for ec2 in module.ec2_instance: [for tag in ec2.tags_all: "${ec2.public_ip} => ${tag}"]]
# }

# output "manager_ip" {
#     value = [for ec2 in module.ec2_instance: 
#             [for tag in ec2.tags_all: ec2.public_ip] if ec2.tags_all.Name == "manager"]
# }

locals {
    manager = module.ec2_instance_manager.public_ip
    manager_nodes = join("\n",[for ec2 in module.ec2_instance_manager_nodes: ec2.public_ip])
    workers = join("\n",[for ec2 in module.ec2_instance_worker_nodes: ec2.public_ip])
    # manager_ip = [for ec2 in module.ec2_instance: 
    # [for tag in ec2.tags_all: ec2.public_ip]
    # if ec2.tags_all.Name == "manager"]

    # managerodes_ip = [for ec2 in module.ec2_instance: 
    # [for tag in ec2.tags_all: ec2.public_ip]
    # if ec2.tags_all.Name == "managernodes"]

# ${element(local.manager_ip[0],0)}
    hosts = <<HOSTS
[manager]
${local.manager}

[managernodes]
${local.manager_nodes}

[worker]
${local.workers}

[all]
[all:vars]
ansible_ssh_private_key_file=swarm.cer
ansible_user=ubuntu

HOSTS    
}

resource "local_file" "hosts" {
    filename = "ansible/hosts"
    content = "${local.hosts}"
}