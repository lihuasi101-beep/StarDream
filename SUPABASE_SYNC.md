# Supabase 云存档

兼容页现在支持本地优先的 Supabase 云存档：登录后，`STAR_CHS` 和 `STAR_CHT` 分别同步完整的 `STARSAVE.SSS` 与 `STARSA*.SSS` 文件集合。没有 Supabase 配置时，页面仍只使用 IndexedDB 和刷新保护镜像。

## 一次性配置

1. 在 Supabase 创建项目。
2. 在 SQL Editor 执行 [`supabase/schema.sql`](supabase/schema.sql) 中的表和 RLS 策略。
3. 在 Authentication → URL Configuration 中把 Site URL 设为：
   `https://lihuasi101-beep.github.io/StarDream/`
   同时在 Redirect URLs 中加入：
   `https://lihuasi101-beep.github.io/StarDream/compat.html`
   不要填写 `https://lihuasi101-beep.github.io/`，该根域名不是本项目的 Pages 地址，会返回 GitHub 404。
4. 在 GitHub 仓库 Settings → Secrets and variables → Actions 中新增：
   - `STARDREAM_SUPABASE_URL`：Supabase Project URL
   - `STARDREAM_SUPABASE_ANON_KEY`：Supabase 公共 anon key
5. 重新运行或触发 GitHub Pages 工作流。

这些值只作为 Pages 构建配置使用，不写入 Git；anon key 会随静态网页公开，这是 Supabase 浏览器端的正常用法，数据安全依靠 Auth 和 RLS，不使用 service role key。

## 使用方式

打开兼容页，点击“云同步”，输入邮箱并点击“发送登录链接”。在同一设备或另一设备打开邮件链接后，点击“立即同步”。启动原版时，云端时间戳较新的存档会自动注入；云端不可用时自动回退到本地存档。

云端同步是按账号隔离的，不同账号无法读取彼此存档。发生网络失败时不会删除本地存档，也不会用旧云档覆盖较新的本地档。
