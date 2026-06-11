class_name SimorghContinueModal
extends Panel

signal accepted
signal declined

@onready var _accept_btn: Button = %AcceptButton
@onready var _decline_btn: Button = %DeclineButton


func _ready() -> void:
	visible = false
	if _accept_btn:
		_accept_btn.pressed.connect(func() -> void:
			visible = false
			accepted.emit()
		)
	if _decline_btn:
		_decline_btn.pressed.connect(func() -> void:
			visible = false
			declined.emit()
		)


func show_offer() -> void:
	visible = true
	if LocalizationService:
		var title := LocalizationService.tr_key("simorgh_title")
		var body := LocalizationService.tr_key("simorgh_body")
		var accept_lbl := get_node_or_null("MarginContainer/VBox/TitleLabel") as Label
		var body_lbl := get_node_or_null("MarginContainer/VBox/BodyLabel") as Label
		if accept_lbl:
			accept_lbl.text = title
		if body_lbl:
			body_lbl.text = body
