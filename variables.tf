variable "region" {
  type    = string
  default = "southindia"
}

variable "content_filter_thresholds" {
  type        = map(string)
  description = "Severity threshold per category: Low, Medium, High"
  default = {
    hate     = "Medium"
    sexual   = "Medium"
    violence = "Medium"
    selfharm = "Low"
  }
}

variable "enable_protected_material" {
  type    = bool
  default = true
}