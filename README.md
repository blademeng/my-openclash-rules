# My Private OpenClash Rules

基于 [Aethersailor/Custom_OpenClash_Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules) 的自动化派生版本。

- GitHub Actions 每 6 小时同步上游 `main` 分支最新 ini
- 同步后自动把 `private/direct-rules.ini` 内容注入到 `[custom]` 段顶部（最高优先级）
- 修改私有规则只需编辑 `private/direct-rules.ini` → push → Actions 自动跑

## OpenClash 订阅转换配置 URL

```
https://raw.githubusercontent.com/blademeng/my-openclash-rules/main/cfg/Custom_Clash.ini
```

## 目录结构

| 路径 | 说明 |
|---|---|
| `cfg/` | 自动生成的 ini（**不要手改**，每次 Actions 会覆盖） |
| `private/direct-rules.ini` | **唯一需要维护的文件**：私有 DIRECT / PROXY 规则 |
| `scripts/inject.sh` | 注入脚本（本地可跑：`bash scripts/inject.sh`） |
| `.github/workflows/sync-and-inject.yml` | 定时同步 + 注入 |

## 维护

```bash
vim private/direct-rules.ini
git add private/
git commit -m "feat: add new direct rule"
git push                  # Actions 自动触发
```
