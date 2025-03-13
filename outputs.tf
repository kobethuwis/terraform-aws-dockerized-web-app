output "load_balancer" {
  description = "Load balancer resource"
  value       = aws_lb.lb
}

output "app_security_group" {
  description = "Security group for the application resource"
  value       = aws_security_group.app_security_group
}

output "lb_security_group" {
  description = "Security group for the load balancer resource"
  value       = aws_security_group.lb_security_group

}

output "load_balancer_listener" {
  description = "Load balancer listener resource"
  value       = aws_lb_listener.lb_listener
}

output "target_groups" {
  description = "Target group resource"
  value       = aws_lb_target_group.lb_target_group
}

output "autoscaling_group" {
  description = "Autoscaling group resource"
  value       = aws_autoscaling_group.autoscaling_group
}
