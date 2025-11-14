"""测试API端点"""
import pytest
from fastapi.testclient import TestClient
from backend.main import app


class TestAPI:
    """API端点测试类"""

    @pytest.fixture
    def client(self):
        """创建测试客户端"""
        return TestClient(app)

    def test_root_endpoint(self, client):
        """测试根路径"""
        response = client.get("/")

        assert response.status_code == 200
        data = response.json()
        assert data["message"] == "Tea Order Agent System API"
        assert data["version"] == "1.0.0"
        assert "endpoints" in data

    def test_health_endpoint(self, client):
        """测试健康检查"""
        response = client.get("/health")

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"

    def test_get_orders_empty(self, client):
        """测试获取订单（空列表）"""
        response = client.get("/orders")

        assert response.status_code == 200
        data = response.json()
        assert "orders" in data
        assert "total" in data
        assert isinstance(data["orders"], list)

    def test_get_nonexistent_order(self, client):
        """测试获取不存在的订单"""
        response = client.get("/orders/99999")

        assert response.status_code == 404

    def test_get_session(self, client):
        """测试获取会话状态"""
        session_id = "test_api_session"
        response = client.get(f"/session/{session_id}")

        assert response.status_code == 200
        data = response.json()
        assert data["session_id"] == session_id
        assert "history" in data
        assert "order_state" in data
        assert "status" in data

    def test_reset_session(self, client):
        """测试重置会话"""
        session_id = "test_reset_session"
        response = client.post(f"/reset/{session_id}")

        assert response.status_code == 200
        data = response.json()
        assert data["message"] == "会话已重置"
        assert data["session_id"] == session_id

    def test_text_endpoint_without_api_key(self, client):
        """测试文本端点（无有效API key）"""
        response = client.post(
            "/text",
            data={
                "session_id": "test_text_session",
                "text": "我要一杯奶茶"
            }
        )

        # 即使API key无效，也应该返回200并有错误处理
        assert response.status_code == 200
        data = response.json()
        assert "assistant_reply" in data
        assert "order_state" in data
        assert "order_status" in data

    def test_cors_headers(self, client):
        """测试CORS头"""
        response = client.options(
            "/",
            headers={
                "Origin": "http://localhost:3000",
                "Access-Control-Request-Method": "GET"
            }
        )

        # CORS应该允许跨域请求
        assert "access-control-allow-origin" in [h.lower() for h in response.headers.keys()]


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
