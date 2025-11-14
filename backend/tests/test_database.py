"""测试数据库模块"""
import os
import tempfile
import pytest
from backend.database import Database
from backend.models import OrderState


class TestDatabase:
    """数据库测试类"""

    @pytest.fixture
    def db(self):
        """创建临时数据库"""
        fd, db_path = tempfile.mkstemp(suffix='.db')
        os.close(fd)

        db = Database(db_path)
        yield db

        # 清理
        if os.path.exists(db_path):
            os.remove(db_path)

    def test_init_db(self, db):
        """测试数据库初始化"""
        conn = db.get_connection()
        cursor = conn.cursor()

        # 检查表是否存在
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='orders'")
        result = cursor.fetchone()

        assert result is not None
        assert result['name'] == 'orders'
        conn.close()

    def test_save_order(self, db):
        """测试保存订单"""
        order_state = OrderState(
            drink_name="乌龙奶茶",
            size="大杯",
            sugar="三分糖",
            ice="去冰",
            toppings=["珍珠", "布丁"],
            notes="不要太烫",
            is_complete=True
        )

        order_id = db.save_order("test_session", order_state)

        assert order_id > 0

    def test_get_order(self, db):
        """测试获取订单"""
        order_state = OrderState(
            drink_name="茉莉奶绿",
            size="中杯",
            sugar="五分糖",
            ice="少冰",
            toppings=["椰果"],
            is_complete=True
        )

        order_id = db.save_order("test_session", order_state)
        order = db.get_order(order_id)

        assert order is not None
        assert order['drink_name'] == "茉莉奶绿"
        assert order['size'] == "中杯"
        assert order['sugar'] == "五分糖"
        assert order['ice'] == "少冰"
        assert "椰果" in order['toppings']

    def test_get_nonexistent_order(self, db):
        """测试获取不存在的订单"""
        order = db.get_order(9999)
        assert order is None

    def test_get_orders_by_session(self, db):
        """测试获取会话的所有订单"""
        session_id = "test_session_123"

        # 创建多个订单
        for i in range(3):
            order_state = OrderState(
                drink_name=f"饮品{i}",
                size="大杯",
                sugar="三分糖",
                ice="去冰",
                toppings=[],
                is_complete=True
            )
            db.save_order(session_id, order_state)

        orders = db.get_orders_by_session(session_id)

        assert len(orders) == 3
        assert orders[0]['session_id'] == session_id

    def test_get_all_orders(self, db):
        """测试获取所有订单"""
        # 创建多个订单
        for i in range(5):
            order_state = OrderState(
                drink_name=f"饮品{i}",
                size="大杯",
                sugar="三分糖",
                ice="去冰",
                toppings=[],
                is_complete=True
            )
            db.save_order(f"session_{i}", order_state)

        orders = db.get_all_orders(limit=10)

        assert len(orders) == 5


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
