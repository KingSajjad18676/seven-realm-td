class_name IapProvider
extends RefCounted

signal purchase_verified(product_id: String)
signal purchase_failed(product_id: String, reason: String)
signal restore_completed(product_ids: Array[String])


func start_purchase(_product_id: String) -> void:
	push_error("IapProvider.start_purchase not implemented")


func restore_purchases() -> void:
	push_error("IapProvider.restore_purchases not implemented")


class StubIapProvider extends IapProvider:
	func start_purchase(product_id: String) -> void:
		purchase_verified.emit(product_id)


	func restore_purchases() -> void:
		restore_completed.emit([])


class GodotBillingProvider extends IapProvider:
	func start_purchase(product_id: String) -> void:
		purchase_failed.emit(product_id, "GodotGooglePlayBilling plugin not configured")


	func restore_purchases() -> void:
		restore_completed.emit([])


class StoreKitProvider extends IapProvider:
	func start_purchase(product_id: String) -> void:
		purchase_failed.emit(product_id, "StoreKit plugin not configured")


	func restore_purchases() -> void:
		restore_completed.emit([])
