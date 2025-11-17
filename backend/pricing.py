"""订单定价逻辑"""
from typing import Optional

from .models import OrderState, TEA_MENU

SIZE_SURCHARGES = {
    "小杯": 0.0,
    "中杯": 1.5,
    "大杯": 3.0,
}

TOPPING_PRICES = {
    "珍珠": 2.0,
    "布丁": 2.5,
    "仙草": 2.0,
    "椰果": 2.0,
    "芋圆": 3.0,
}

DEFAULT_TOPPING_PRICE = 2.0


def _get_base_price(drink_name: str) -> Optional[float]:
    for item in TEA_MENU:
        if item.name == drink_name:
            return item.base_price
    return None


def calculate_order_total(order_state: OrderState) -> Optional[float]:
    """根据订单配置计算价格"""
    if not order_state.drink_name:
        return None

    base_price = _get_base_price(order_state.drink_name)
    if base_price is None:
        return None

    total = base_price
    if order_state.size:
        total += SIZE_SURCHARGES.get(order_state.size, 0.0)

    for topping in order_state.toppings or []:
        total += TOPPING_PRICES.get(topping, DEFAULT_TOPPING_PRICE)

    return round(total, 2)
