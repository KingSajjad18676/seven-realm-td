extends Control

signal privacy_accepted

@onready var _title: Label = %TitleLabel
@onready var _body: Label = %BodyLabel
@onready var _analytics: CheckBox = %AnalyticsConsent
@onready var _privacy_link: Button = %PrivacyPolicyButton
@onready var _terms_link: Button = %TermsButton
@onready var _accept: Button = %AcceptButton


func _ready() -> void:
	_apply_localization()
	if _privacy_link:
		_privacy_link.pressed.connect(func() -> void:
			OS.shell_open(LegalLinks.PRIVACY_POLICY_URL)
		)
	if _terms_link:
		_terms_link.pressed.connect(func() -> void:
			OS.shell_open(LegalLinks.TERMS_OF_SERVICE_URL)
		)
	if _accept:
		_accept.pressed.connect(_on_accept)


func _apply_localization() -> void:
	if LocalizationService == null:
		return
	if _title:
		_title.text = LocalizationService.tr_key("privacy_title")
	if _body:
		_body.text = LocalizationService.tr_key("privacy_body")
	if _analytics:
		_analytics.text = LocalizationService.tr_key("privacy_analytics")
	if _privacy_link:
		_privacy_link.text = LocalizationService.tr_key("privacy_policy")
	if _terms_link:
		_terms_link.text = LocalizationService.tr_key("privacy_terms")
	if _accept:
		_accept.text = LocalizationService.tr_key("privacy_continue")


func _on_accept() -> void:
	if SaveSystem:
		SaveSystem.set_privacy_accepted()
		SaveSystem.set_analytics_consent(_analytics != null and _analytics.button_pressed)
	privacy_accepted.emit()
	queue_free()
