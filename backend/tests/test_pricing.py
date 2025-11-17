"""测试定价逻辑"""
from backend.pricing import calculate_order_total
from backend.models import OrderState


def test_calculate_order_total_basic():
    state = OrderState(
        drink_name="乌龙奶茶",
        size="大杯",
        sugar="三分糖",
        ice="少冰",
        toppings=["珍珠", "布丁"],
        is_complete=True,
    )
    total = calculate_order_total(state)
    assert total is not None
    # base 15 + 大杯3 + 珍珠2 + 布丁2.5 = 22.5
    assert abs(total - 22.5) < 1e-6


def test_calculate_order_total_unknown_drink():
    state = OrderState(drink_name="不存在的", size="小杯")
    assert calculate_order_total(state) is None
