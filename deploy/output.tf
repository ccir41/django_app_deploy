output "server-public-ip"{
    value = aws_instance.server.public_ip
}

output "ws-domain-name" {
    value = aws_instance.server.public_dns
}