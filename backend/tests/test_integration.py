"""集成测试 - 测试完整流程"""
import pytest
from fastapi.testclient import TestClient
from backend.main import app
import tempfile
import os


class TestIntegration:
    """集成测试类"""

    @pytest.fixture
    def client(self):
        """创建测试客户端"""
        return TestClient(app)

    def test_complete_order_flow(self, client):
        """测试完整的订单流程"""
        session_id = "integration_test_session"

        # 1. 检查初始会话状态
        response = client.get(f"/session/{session_id}")
        assert response.status_code == 200
        data = response.json()
        assert data["session_id"] == session_id
        assert len(data["history"]) == 0
        assert data["status"] == "collecting"

        # 2. 发送第一条消息（会因为无API key而返回错误，但流程应该正常）
        response = client.post(
            "/text",
            data={
                "session_id": session_id,
                "text": "我要一杯奶茶"
            }
        )
        assert response.status_code == 200
        data = response.json()
        assert "assistant_reply" in data
        assert "order_state" in data

        # 3. 检查会话历史已更新
        response = client.get(f"/session/{session_id}")
        assert response.status_code == 200
        data = response.json()
        # 应该有两条消息：用户和助手
        assert len(data["history"]) == 2

        # 4. 重置会话
        response = client.post(f"/reset/{session_id}")
        assert response.status_code == 200

        # 5. 验证会话已重置
        response = client.get(f"/session/{session_id}")
        assert response.status_code == 200
        data = response.json()
        assert len(data["history"]) == 0
        assert data["status"] == "collecting"

    def test_multiple_sessions(self, client):
        """测试多个会话的隔离"""
        session1 = "session_1"
        session2 = "session_2"

        # 在会话1中发送消息
        client.post(
            "/text",
            data={
                "session_id": session1,
                "text": "会话1的消息"
            }
        )

        # 在会话2中发送消息
        client.post(
            "/text",
            data={
                "session_id": session2,
                "text": "会话2的消息"
            }
        )

        # 验证两个会话是独立的
        response1 = client.get(f"/session/{session1}")
        response2 = client.get(f"/session/{session2}")

        data1 = response1.json()
        data2 = response2.json()

        assert len(data1["history"]) == 2
        assert len(data2["history"]) == 2
        assert data1["history"][0]["content"] == "会话1的消息"
        assert data2["history"][0]["content"] == "会话2的消息"

    def test_api_endpoints_sequence(self, client):
        """测试API端点调用顺序"""
        # 1. 健康检查
        response = client.get("/health")
        assert response.status_code == 200

        # 2. 获取所有订单
        response = client.get("/orders")
        assert response.status_code == 200

        # 3. 创建会话并交互
        session_id = "sequence_test"
        response = client.post(
            "/text",
            data={
                "session_id": session_id,
                "text": "测试"
            }
        )
        assert response.status_code == 200

        # 4. 查询会话
        response = client.get(f"/session/{session_id}")
        assert response.status_code == 200

        # 5. 重置会话
        response = client.post(f"/reset/{session_id}")
        assert response.status_code == 200

    def test_error_handling(self, client):
        """测试错误处理"""
        # 测试查询不存在的订单
        response = client.get("/orders/99999")
        assert response.status_code == 404

        # 测试无效的请求（缺少参数）
        response = client.post("/text", data={"session_id": "test"})
        assert response.status_code == 422  # Unprocessable Entity


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
