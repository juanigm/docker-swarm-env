# 1) instalar azcopy en cada vm
# 2) almacenar en un archivo .txt llamado manager, el token para los manager

#     docker swarm join-token manager | sed -n 's/.docker//p' > manager.txt

# 3) almacenear en un archivo .txt llamado worker, el token para los worker

#     docker swarm join-token worker | sed -n 's/.docker//p' > worker.txt

# 4) subir los dos archivos a un blob

#      azcopy copy 'worker.txt' 'https://testblobnashe.blob.core.windows.net/blob/manager.txt?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2024-08-07T23:11:36Z&st=2024-08-07T15:11:36Z&spr=https&sig=Y4G416nB6huPsyAxWEv4%2BNTgsCrycV1WeF%2Boj9D2um0%3D'
#      azcopy copy 'manager.txt' 'https://testblobnashe.blob.core.windows.net/blob/worker.txt?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2024-08-07T23:11:36Z&st=2024-08-07T15:11:36Z&spr=https&sig=Y4G416nB6huPsyAxWEv4%2BNTgsCrycV1WeF%2Boj9D2um0%3D'

# 5) por cada vm descargar el blob

#     azcopy copy 'https://testblobnashe.blob.core.windows.net/blob/worker.txt?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2024-08-07T23:11:36Z&st=2024-08-07T15:11:36Z&spr=https&sig=Y4G416nB6huPsyAxWEv4%2BNTgsCrycV1WeF%2Boj9D2um0%3D' 'worker.txt'
#     azcopy copy 'https://testblobnashe.blob.core.windows.net/blob/manager.txt?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2024-08-07T23:11:36Z&st=2024-08-07T15:11:36Z&spr=https&sig=Y4G416nB6huPsyAxWEv4%2BNTgsCrycV1WeF%2Boj9D2um0%3D' 'manager.txt'
# 6) almacenar el contenido en una variable de entorno

#      export WORKER=$(cat 'worker.txt')
#       export MANAGER=$(cat 'manager.txt')

# 7) ejectuar docker $variable

#      docker $WORKER
#      docker $MANAGER


resource "null_resource" "upload_data" {

  for_each = {for instance in var.instance_set: instance.name => instance}
  connection {
    type     = "ssh"
    user     = "adminuser"
    private_key = tls_private_key.secureadmin_ssh.private_key_openssh
    host     = azurerm_linux_virtual_machine.vm[each.key].public_ip_address
  }

  provisioner "remote-exec" {
     inline = each.value.node-type == "main" ? [
        "docker swarm join-token manager | sed -n 's/.docker//p' > manager.txt", 
        "docker swarm join-token worker | sed -n 's/.docker//p' > worker.txt",
        "azcopy copy 'worker.txt' 'https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.container.name}/worker.txt${data.azurerm_storage_account_sas.terraform.sas}'",
        "azcopy copy 'manager.txt' 'https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.container.name}/manager.txt${data.azurerm_storage_account_sas.terraform.sas}'"
        ] : null
  }
  

  depends_on = [ null_resource.test]
  
}

resource "null_resource" "download_data" {

  for_each = {for instance in var.instance_set: instance.name => instance}
  connection {
    type     = "ssh"
    user     = "adminuser"
    private_key = tls_private_key.secureadmin_ssh.private_key_openssh
    host     = azurerm_linux_virtual_machine.vm[each.key].public_ip_address
  }
# '${data.azurerm_storage_account_blob_container_sas.example.sas}/${azurerm_storage_container.container.name}'
  provisioner "remote-exec" {
     inline = each.value.node-type == "manager" ? [
        "azcopy copy 'https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.container.name}/manager.txt${data.azurerm_storage_account_sas.terraform.sas}' 'manager.txt'", 
        "export MANAGER=$(cat 'manager.txt')",
        "docker $MANAGER"] : each.value.node-type == "worker" ? [
        "azcopy copy 'https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.container.name}/worker.txt${data.azurerm_storage_account_sas.terraform.sas}' 'worker.txt'",
        "export WORKER=$(cat 'worker.txt')",
        "docker $WORKER"] : null
  }

  depends_on = [ null_resource.upload_data]
  
}