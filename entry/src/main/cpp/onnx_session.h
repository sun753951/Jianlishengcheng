/**
 * ONNX 推理会话头文件 — P1 占位
 */
#ifndef ONNX_SESSION_H
#define ONNX_SESSION_H

#include <string>
#include <vector>

namespace OnnxInference {

struct TensorData {
    std::vector<float> data;
    std::vector<int64_t> shape;
    std::string name;
};

class OnnxSession {
public:
    OnnxSession();
    ~OnnxSession();

    // 加载 ONNX 模型
    bool LoadModel(const std::string& modelPath);

    // 执行推理
    bool Run(const std::vector<TensorData>& inputs,
             std::vector<TensorData>& outputs);

    // 释放资源
    void Release();

    bool IsLoaded() const;

private:
    bool loaded_;
};

} // namespace OnnxInference

#endif // ONNX_SESSION_H
