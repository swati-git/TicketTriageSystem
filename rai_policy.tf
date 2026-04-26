resource "azurerm_cognitive_account_rai_policy" "ai_safety" {
  name                = "rai-policy-${var.region}-triage"
  cognitive_account_id = azurerm_cognitive_account.triage_account.id
  base_policy_name    = "Microsoft.Default"


  content_filter {
    name               = "Hate"
    filter_enabled     = true
    block_enabled      = true
    severity_threshold = var.content_filter_thresholds["hate"]
    source             = "Prompt"
  }

  content_filter {
    name               = "Hate"
    filter_enabled     = true
    block_enabled      = true
    severity_threshold = var.content_filter_thresholds["hate"]
    source             = "Completion"
  }

  content_filter {
    name               = "Sexual"
    filter_enabled     = true
    block_enabled      = true
    severity_threshold = var.content_filter_thresholds["sexual"]
    source             = "Prompt"
  }
  content_filter {
    name               = "Sexual"
    filter_enabled     = true
    block_enabled      = true
    severity_threshold = var.content_filter_thresholds["sexual"]
    source             = "Completion"
  }

  content_filter {
    name               = "Violence"
    filter_enabled     = true
    block_enabled      = true
    severity_threshold = var.content_filter_thresholds["violence"]
    source             = "Prompt"
  }
  content_filter {
    name               = "Violence"
    filter_enabled     = true
    block_enabled      = true
    severity_threshold = var.content_filter_thresholds["violence"]
    source             = "Completion"
  }


  content_filter {
    name               = "SelfHarm"
    filter_enabled     = true
    block_enabled      = true
    severity_threshold = var.content_filter_thresholds["selfharm"]
    source             = "Prompt"
  }
  content_filter {
    name               = "SelfHarm"
    filter_enabled     = true
    block_enabled      = true
    severity_threshold = var.content_filter_thresholds["selfharm"]
    source             = "Completion"
  }

  # ━━━ Jailbreak Detection ━━━
  content_filter {
    name               = "Jailbreak"
    filter_enabled     = true
    block_enabled      = true
    severity_threshold = "High"  # Required by provider, not used by Azure
    source             = "Prompt"
  }

  # ━━━ Indirect Prompt Attack ━━━
  content_filter {
    name               = "Indirect Attack"
    filter_enabled     = var.enable_indirect_attack_filter
    block_enabled      = var.enable_indirect_attack_filter
    severity_threshold = "High"
    source             = "Prompt"
  }

  # ━━━ Protected Material ━━━
  content_filter {
    name               = "Protected Material Text"
    filter_enabled     = var.enable_protected_material
    block_enabled      = var.enable_protected_material
    severity_threshold = "High"
    source             = "Completion"
  }
  content_filter {
    name               = "Protected Material Code"
    filter_enabled     = var.enable_protected_material
    block_enabled      = var.enable_protected_material
    severity_threshold = "High"
    source             = "Completion"
  }
}