#* RANDOM PASSWORD
resource "random_password" "this" {
  length  = 16
  special = true
}
#random_password.this.result
