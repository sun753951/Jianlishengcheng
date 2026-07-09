# 系统运行配置与 AI 提示词说明

## 题目对齐

本项目对应第 33 题“基于自然语言生成的智能简历生成系统设计与实现”。原题要求用户填写个人基础信息、工作经历、项目经验后，系统利用基于 Transformer 的自然语言生成模型，根据岗位要求和简历模板生成个性化简历文本，并支持多样式选择、在线编辑、PDF 下载、简历评分和优化建议。

本项目使用 HarmonyOS ArkTS / ArkUI 作为应用端交互界面，使用 Python FastAPI 作为 AI 生成、评分和 PDF 服务端。原题中的“网页端”在本项目中由 HarmonyOS 应用端承担交互和展示职责。

## 运行环境

- HarmonyOS 工程目录：`code`
- HarmonyOS 模块：`entry`
- Python 后端目录：`code/server`
- Python 版本：建议 Python 3.10 及以上
- 后端依赖：见 `server/requirements.txt`

## 后端启动

在 `code` 目录执行：

```sh
python3 -m pip install -r server/requirements.txt
python3 -m uvicorn server.app:app --host 0.0.0.0 --port 8000
```

当前 ArkTS 应用端后端地址配置为 `http://127.0.0.1:8000`。在模拟器中运行时，需要通过 HDC 反向端口转发让模拟器的 `127.0.0.1:8000` 指向 Mac 后端：

```sh
/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc \
  -t 127.0.0.1:5555 rport tcp:8000 tcp:8000
```

后端接口：

- `GET /api/health`：健康检查。
- `POST /api/resume/generate`：生成简历文本和结构化预览数据。
- `POST /api/resume/score`：从结构、内容、岗位匹配三个维度评分并返回建议。
- `POST /api/resume/export/pdf`：根据编辑后的简历文本生成 PDF。

## HarmonyOS 端运行

应用端已声明网络权限 `ohos.permission.INTERNET`，用于访问本机后端服务。

构建命令示例：

```sh
/Applications/DevEco-Studio.app/Contents/tools/node/bin/node \
  /Applications/DevEco-Studio.app/Contents/tools/hvigor/hvigor/bin/hvigor.js \
  assembleHap --mode module -p module=entry@default -p product=default --no-daemon
```

在模拟器或真机运行前，需要先启动 Python 后端。若后端不可用，应用会提示服务不可用，并使用本地规则模板作为演示降级方案。

## 数据集说明

原题要求使用公开简历文本数据集，可在 Kaggle 搜索获取。建议候选数据集：

- Resume Dataset：https://www.kaggle.com/datasets/snehaanbhawal/resume-dataset
- Resume Classification Dataset for NLP：https://www.kaggle.com/datasets/hassnainzaidi/resume-classification-dataset-for-nlp
- 54k Resume dataset structured：https://www.kaggle.com/datasets/suriyaganesh/resume-dataset-structured

当前阶段尚未将数据集提交到仓库，原因是 Kaggle 数据集可能需要登录、授权或体积较大。交付时应在文档中记录最终选用的数据集名称、来源链接、字段结构、用途和授权说明。

当前已下载并用于轻量训练准备的数据集：

- 数据集名称：54k Resume dataset structured
- 来源链接：https://www.kaggle.com/datasets/suriyaganesh/resume-dataset-structured
- 字段文件：`01_people.csv`、`03_education.csv`、`04_experience.csv`、`05_person_skills.csv` 等。
- 用途：抽取岗位名称、教育经历、工作经历和技能字段，构造小样本生成式训练数据。
- 本地处理脚本：`server/scripts/prepare_resume_dataset.py`
- 处理输出：`server/data/processed/resume_train.jsonl`，该目录已加入忽略规则，不提交完整数据文件。

## AI 模型与降级方案

后端通过 Hugging Face Transformers 接入模型，默认模型名配置为：

```text
uer/gpt2-chinese-cluecorpussmall
```

可通过环境变量覆盖：

```sh
RESUME_MODEL_NAME=<model-name>
```

如果已经完成本地轻量训练，也可以直接指定本地模型目录：

```sh
RESUME_MODEL_PATH=server/artifacts/resume_tiny_model
```

为保证普通电脑和答辩环境可运行，默认启用规则模板降级：

```sh
RESUME_DISABLE_TRANSFORMERS=1
```

如需尝试真实模型推理，可设置：

```sh
RESUME_DISABLE_TRANSFORMERS=0
```

如果模型下载、硬件性能或网络环境不足，系统会自动使用规则模板生成，并在接口返回中标记 `usedFallback=true`。

## 本地轻量训练流程

本机为 Apple M 系列 16GB 内存环境，不适合全量大模型训练。本项目采用小样本、少步数的训练流程验证“公开数据集 + Hugging Face Transformers + 本地模型产物”的闭环。

创建虚拟环境并安装依赖：

```sh
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip setuptools wheel
.venv/bin/python -m pip install -r server/requirements.txt
```

下载并处理 Kaggle 数据集：

```sh
.venv/bin/python server/scripts/prepare_resume_dataset.py --max-samples 800
```

运行轻量训练：

```sh
.venv/bin/python server/scripts/train_resume_model.py \
  --sample-limit 96 \
  --max-steps 20 \
  --output-dir server/artifacts/resume_tiny_model
```

评估生成效果：

```sh
.venv/bin/python server/scripts/evaluate_resume_model.py \
  --model-dir server/artifacts/resume_tiny_model \
  --limit 5
```

说明：默认基础模型为 `sshleifer/tiny-gpt2`，用于本地快速验证训练流程，不代表最终生成质量。若需要更好效果，应在云 GPU 上换用更大的中文或多语言模型，并提高训练样本数和训练步数。

## Prompt 模板

Prompt 存放在 `server/prompt.py`，核心约束如下：

- 只基于候选人提供的真实信息生成中文简历。
- 不得编造学历、公司、证书、工作年限、项目成果或联系方式。
- 必须包含目标岗位、模板风格、候选人信息、输出结构和真实性约束。
- 输出结构包含个人摘要、教育经历、核心技能、工作/实习经历、项目经历、自我评价。

## 指标说明

原题要求生成简历语法正确率达到 98% 以上，单份简历生成时间小于 2 秒。当前系统已记录 `generationTimeMs`，可用于统计生成耗时。语法正确率需要结合人工抽样或自动语言质量评估工具记录，当前阶段尚未完成严格量化评测。

若答辩环境无法稳定运行 Transformer 模型，应说明限制来自模型体积、硬件性能或网络下载，并展示规则模板降级生成、评分和 PDF 导出的完整闭环。

## 隐私保护

- 应用端和后端不输出完整姓名、电话、邮箱、照片路径、简历正文或项目经历到日志。
- API 请求仅传递生成、评分和导出所需字段。
- PDF 文件名使用固定安全名称 `resume.pdf`，避免在响应头中暴露个人姓名和岗位信息。
