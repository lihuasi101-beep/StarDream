# GitHub Pages 发布

本项目统一通过 GitHub Actions 发布到 GitHub Pages。发布入口是 `.github/workflows/deploy-pages.yml`，发布产物由 `publish-github.ps1` 从根目录构建，不使用 `sites/` 下的历史快照或历史发布绑定文件。

首次使用时，将本目录推送到 GitHub 仓库，并在仓库的 Pages 设置中将构建来源设为 GitHub Actions。之后推送到 `main` 或 `master` 会自动构建并发布，也可以在 Actions 页面手动运行工作流。

本地构建检查：

```powershell
pwsh -NoProfile -File .\publish-github.ps1 -OutputPath .\github-pages-build
```

脚本会生成自包含的 Web Edition 和原版兼容模式，包含本地 DOSBox-X 运行时、两套原始语言目录及第三方许可说明；不依赖外部发布服务，原版资源按需从同一 Pages 站点加载。
