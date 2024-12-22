resource "aws_key_pair" "threetierprojectkey" {
  key_name   = "3tierprojectkey"  // Replace with your desired key pair name
  public_key = file("~/.ssh/id_rsa.pub")  // Path to your public SSH key file
}