resource "openstack_objectstorage_container_v1" "k3s_backups" {
  name       = "k3s-backups"
  versioning = true
}
