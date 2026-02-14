resource "fastly_ngwaf_workspace" "example" {
  name                            = "example"
  description                     = "Test NGWAF Workspace"
  mode                            = "block"
  attack_signal_thresholds {}
}

resource "fastly_ngwaf_workspace_rule" "first_rule" {
  workspace_id    = fastly_ngwaf_workspace.example.id
  type            = "request"
  description     = "Block requests from specific IP to login path"
  enabled         = true
  request_logging = "sampled"
  group_operator  = "all"

  action {
    type = "block"
  }

  condition {
    field    = "ip"
    operator = "equals"
    value    = "192.0.2.1"
  }

  condition {
    field    = "path"
    operator = "equals"
    value    = "/login"
  }
}

resource "fastly_ngwaf_workspace_rule" "exclude_xss_signal" {
  workspace_id    = fastly_ngwaf_workspace.example.id
  type            = "signal"
  description     = "Exclude XSS signal to address a false positive"
  enabled         = true
  group_operator  = "all"

  condition {
    field    = "path"
    operator = "like"
    value    = "/contact-form"
  }
  action {
    type   = "exclude_signal"
    signal = "XSS"
  }
}

resource "fastly_ngwaf_virtual_patches" "demo" {
  action            = "block"
  enabled           = true
  virtual_patch_id    = "CVE-2017-5638"
  workspace_id       = fastly_ngwaf_workspace.example.id
}
